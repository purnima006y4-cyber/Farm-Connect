package com.farmconnect.dao;

import com.farmconnect.model.CartItem;
import com.farmconnect.model.Order;
import com.farmconnect.model.OrderItem;
import com.farmconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.util.logging.Logger;

/**
 * DAO for ORDERS and ORDER_ITEM tables.
 *
 * CHECKOUT TRANSACTION (Core Business Logic):
 * 1. setAutoCommit(false) to manage a single JDBC transaction.
 * 2. Groups cart lines by farmer.
 * 3. Computes order totals on the server from DB prices (never trusts browser prices).
 * 4. Inserts ONE ORDERS row per farmer.
 * 5. Inserts ORDER_ITEM rows capturing unit_price at time of purchase.
 * 6. Reduces stock atomically with optimistic concurrency:
 *    UPDATE PRODUCT SET quantity = quantity - ?,
 *           status = CASE WHEN quantity - ? <= 0 THEN 'OUT_OF_STOCK' ELSE 'AVAILABLE' END
 *    WHERE product_id = ? AND quantity >= ?
 * 7. If 0 rows updated (product out of stock), rolls back and throws an exception.
 * 8. Clears the customer's cart only after all items and orders succeed, then commits.
 *
 * ORDER LIFECYCLE:
 * - PLACED -> CONFIRMED -> PACKED -> OUT_FOR_DELIVERY -> DELIVERED
 * - Farmer can advance status along this path, or REJECT (restores stock).
 * - Customer can CANCEL only while status is PLACED (restores stock).
 */
public class OrderDAO {

    private static final Logger LOGGER = Logger.getLogger(OrderDAO.class.getName());

    /**
     * Executes checkout in a single JDBC transaction.
     *
     * @param customerId Customer ID
     * @param address Shipping address
     * @throws Exception If out of stock, cart is empty, or DB error occurs.
     */
    public void checkout(int customerId, String address) throws Exception {
        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.findByUser(customerId);

        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Cart is empty.");
        }
        if (address == null || address.trim().isEmpty()) {
            throw new IllegalArgumentException("Delivery address is required.");
        }

        // Group cart lines by farmer
        Map<Integer, List<CartItem>> itemsByFarmer = new LinkedHashMap<>();
        for (CartItem item : cartItems) {
            itemsByFarmer.computeIfAbsent(item.getFarmerId(), k -> new ArrayList<>()).add(item);
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (Map.Entry<Integer, List<CartItem>> entry : itemsByFarmer.entrySet()) {
                    int farmerId = entry.getKey();
                    List<CartItem> farmerItems = entry.getValue();

                    // Calculate total from DB prices
                    BigDecimal total = BigDecimal.ZERO;
                    for (CartItem ci : farmerItems) {
                        BigDecimal lineTotal = ci.getPrice().multiply(BigDecimal.valueOf(ci.getQuantity()));
                        total = total.add(lineTotal);
                    }

                    // 1. Insert order for this farmer
                    int orderId = insertOrderHeader(conn, customerId, farmerId, total, address.trim());

                    // 2. Insert order items & reduce stock
                    for (CartItem ci : farmerItems) {
                        insertOrderItem(conn, orderId, ci.getProductId(), ci.getQuantity(), ci.getPrice());

                        // Atomic stock reduction with overselling guard (quantity >= ?)
                        int updatedRows = reduceProductStock(conn, ci.getProductId(), ci.getQuantity());
                        if (updatedRows == 0) {
                            // Concurrency failure or out of stock
                            conn.rollback();
                            throw new IllegalStateException("Product '" + ci.getProductName() + "' is out of stock or insufficient quantity. Checkout cancelled.");
                        }
                    }
                }

                // 3. Clear cart in the same transaction
                cartDAO.clearCart(conn, customerId);

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                LOGGER.severe("Checkout failed, transaction rolled back: " + e.getMessage());
                throw e;
            }
        }
    }

    private int insertOrderHeader(Connection conn, int customerId, int farmerId, BigDecimal total, String address) throws SQLException {
        String sql = "INSERT INTO ORDERS (customer_id, farmer_id, total_amount, status, address, order_date, expected_delivery_date) "
                   + "VALUES (?, ?, ?, 'PLACED', ?, SYSTIMESTAMP, SYSDATE + 5)";
        try (PreparedStatement ps = conn.prepareStatement(sql, new String[]{"ORDER_ID"})) {
            ps.setInt(1, customerId);
            ps.setInt(2, farmerId);
            ps.setBigDecimal(3, total);
            ps.setString(4, address);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Failed to generate order_id");
    }

    private void insertOrderItem(Connection conn, int orderId, int productId, int qty, BigDecimal unitPrice) throws SQLException {
        String sql = "INSERT INTO ORDER_ITEM (order_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, productId);
            ps.setInt(3, qty);
            ps.setBigDecimal(4, unitPrice);
            ps.executeUpdate();
        }
    }

    private int reduceProductStock(Connection conn, int productId, int qty) throws SQLException {
        String sql = "UPDATE PRODUCT SET quantity = quantity - ?, "
                   + "status = CASE WHEN quantity - ? <= 0 THEN 'OUT_OF_STOCK' ELSE 'AVAILABLE' END "
                   + "WHERE product_id = ? AND quantity >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, qty);
            ps.setInt(3, productId);
            ps.setInt(4, qty);
            return ps.executeUpdate();
        }
    }

    /**
     * Advance order status along the valid lifecycle:
     * PLACED -> CONFIRMED -> PACKED -> OUT_FOR_DELIVERY -> DELIVERED
     */
    public void advanceStatus(int orderId, int farmerId) throws Exception {
        Order order = findById(orderId);
        if (order == null || order.getFarmerId() != farmerId) {
            throw new SecurityException("Unauthorized: Not your order.");
        }

        Map<String, String> nextStatusMap = new HashMap<>();
        nextStatusMap.put("PLACED", "CONFIRMED");
        nextStatusMap.put("CONFIRMED", "PACKED");
        nextStatusMap.put("PACKED", "OUT_FOR_DELIVERY");
        nextStatusMap.put("OUT_FOR_DELIVERY", "DELIVERED");

        String nextStatus = nextStatusMap.get(order.getStatus());
        if (nextStatus == null) {
            throw new IllegalStateException("Cannot advance order from status: " + order.getStatus());
        }

        String sql = "UPDATE ORDERS SET status = ? WHERE order_id = ? AND farmer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nextStatus);
            ps.setInt(2, orderId);
            ps.setInt(3, farmerId);
            ps.executeUpdate();
        }
    }

    /**
     * Cancel (by customer) or Reject (by farmer).
     * Restores inventory for all items in a transaction.
     */
    public void cancelOrReject(int orderId, int userId, String role) throws Exception {
        Order order = findById(orderId);
        if (order == null) {
            throw new IllegalArgumentException("Order not found");
        }

        boolean isCustomer = "CUSTOMER".equalsIgnoreCase(role) && order.getCustomerId() == userId;
        boolean isFarmer = "FARMER".equalsIgnoreCase(role) && order.getFarmerId() == userId;

        if (!isCustomer && !isFarmer) {
            throw new SecurityException("Unauthorized: Access denied to this order.");
        }

        String newStatus;
        if (isCustomer) {
            if (!"PLACED".equals(order.getStatus())) {
                throw new IllegalStateException("Customers can only cancel orders in PLACED status.");
            }
            newStatus = "CANCELLED";
        } else {
            if (!"PLACED".equals(order.getStatus()) && !"CONFIRMED".equals(order.getStatus())) {
                throw new IllegalStateException("Farmers can only reject orders in PLACED or CONFIRMED status.");
            }
            newStatus = "REJECTED";
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Update status
                String updateOrderSql = "UPDATE ORDERS SET status = ? WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }

                // Restore stock
                List<OrderItem> items = findItems(orderId);
                String restoreStockSql = "UPDATE PRODUCT SET quantity = quantity + ?, status = 'AVAILABLE' WHERE product_id = ?";
                for (OrderItem item : items) {
                    try (PreparedStatement ps = conn.prepareStatement(restoreStockSql)) {
                        ps.setInt(1, item.getQuantity());
                        ps.setInt(2, item.getProductId());
                        ps.executeUpdate();
                    }
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public List<Order> findByCustomer(int customerId) throws SQLException {
        String sql = "SELECT o.order_id, o.customer_id, o.farmer_id, o.total_amount, o.status, "
                   + "o.address, o.order_date, o.expected_delivery_date, "
                   + "uc.name AS customer_name, uf.name AS farmer_name "
                   + "FROM ORDERS o "
                   + "JOIN USERS uc ON o.customer_id = uc.user_id "
                   + "JOIN USERS uf ON o.farmer_id = uf.user_id "
                   + "WHERE o.customer_id = ? ORDER BY o.order_date DESC";
        return queryOrders(sql, customerId);
    }

    public List<Order> findByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT o.order_id, o.customer_id, o.farmer_id, o.total_amount, o.status, "
                   + "o.address, o.order_date, o.expected_delivery_date, "
                   + "uc.name AS customer_name, uf.name AS farmer_name "
                   + "FROM ORDERS o "
                   + "JOIN USERS uc ON o.customer_id = uc.user_id "
                   + "JOIN USERS uf ON o.farmer_id = uf.user_id "
                   + "WHERE o.farmer_id = ? ORDER BY o.order_date DESC";
        return queryOrders(sql, farmerId);
    }

    public List<Order> findAll(int page, int pageSize) throws SQLException {
        int offset = (Math.max(1, page) - 1) * pageSize;
        int maxRow = offset + pageSize;
        int minRow = offset;
        String sql = "SELECT * FROM ("
                   + "  SELECT a.*, ROWNUM rn FROM ("
                   + "    SELECT o.order_id, o.customer_id, o.farmer_id, o.total_amount, o.status, "
                   + "    o.address, o.order_date, o.expected_delivery_date, "
                   + "    uc.name AS customer_name, uf.name AS farmer_name "
                   + "    FROM ORDERS o "
                   + "    JOIN USERS uc ON o.customer_id = uc.user_id "
                   + "    JOIN USERS uf ON o.farmer_id = uf.user_id "
                   + "    ORDER BY o.order_date DESC"
                   + "  ) a WHERE ROWNUM <= ?"
                   + ") WHERE rn > ?";
        return queryOrders(sql, maxRow, minRow);
    }

    public Order findById(int orderId) throws SQLException {
        String sql = "SELECT o.order_id, o.customer_id, o.farmer_id, o.total_amount, o.status, "
                   + "o.address, o.order_date, o.expected_delivery_date, "
                   + "uc.name AS customer_name, uf.name AS farmer_name "
                   + "FROM ORDERS o "
                   + "JOIN USERS uc ON o.customer_id = uc.user_id "
                   + "JOIN USERS uf ON o.farmer_id = uf.user_id "
                   + "WHERE o.order_id = ?";
        List<Order> list = queryOrders(sql, orderId);
        if (list.isEmpty()) return null;
        Order order = list.get(0);
        order.setItems(findItems(orderId));
        return order;
    }

    public List<OrderItem> findItems(int orderId) throws SQLException {
        String sql = "SELECT oi.item_id, oi.order_id, oi.product_id, oi.quantity, oi.unit_price, "
                   + "p.name AS product_name, p.image_path "
                   + "FROM ORDER_ITEM oi "
                   + "JOIN PRODUCT p ON oi.product_id = p.product_id "
                   + "WHERE oi.order_id = ?";
        List<OrderItem> items = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setItemId(rs.getInt("item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setProductName(rs.getString("product_name"));
                    item.setImagePath(rs.getString("image_path"));
                    items.add(item);
                }
            }
        }
        return items;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM ORDERS";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public BigDecimal totalRevenue() throws SQLException {
        String sql = "SELECT NVL(SUM(total_amount), 0) FROM ORDERS WHERE status = 'DELIVERED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    public BigDecimal getTotalSalesByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT NVL(SUM(total_amount), 0) FROM ORDERS "
                   + "WHERE farmer_id = ? AND status NOT IN ('CANCELLED', 'REJECTED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    public int countPlacedOrdersForFarmer(int farmerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ORDERS WHERE farmer_id = ? AND status = 'PLACED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countOrdersByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ORDERS WHERE farmer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countOrdersByCustomer(int customerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ORDERS WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public BigDecimal getTotalSpentByCustomer(int customerId) throws SQLException {
        String sql = "SELECT NVL(SUM(total_amount), 0) FROM ORDERS WHERE customer_id = ? AND status NOT IN ('CANCELLED', 'REJECTED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    public List<Map<String, Object>> getMonthlySales(int farmerId) throws SQLException {
        String sql = "SELECT * FROM ("
                   + "  SELECT TO_CHAR(order_date, 'YYYY-MM') AS month_label, "
                   + "  SUM(total_amount) AS total_sales, COUNT(*) AS order_count "
                   + "  FROM ORDERS "
                   + "  WHERE farmer_id = ? AND status NOT IN ('CANCELLED', 'REJECTED') "
                   + "  GROUP BY TO_CHAR(order_date, 'YYYY-MM') "
                   + "  ORDER BY month_label DESC"
                   + ") WHERE ROWNUM <= 12";
        List<Map<String, Object>> result = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("month", rs.getString("month_label"));
                    map.put("totalSales", rs.getBigDecimal("total_sales"));
                    map.put("orderCount", rs.getInt("order_count"));
                    result.add(map);
                }
            }
        }
        return result;
    }

    public List<Map<String, Object>> getMonthlySalesReport() throws SQLException {
        String sql = "SELECT * FROM ("
                   + "  SELECT TO_CHAR(order_date, 'YYYY-MM') AS month_label, "
                   + "  SUM(total_amount) AS total_sales, COUNT(*) AS order_count "
                   + "  FROM ORDERS "
                   + "  WHERE status NOT IN ('CANCELLED', 'REJECTED') "
                   + "  GROUP BY TO_CHAR(order_date, 'YYYY-MM') "
                   + "  ORDER BY month_label DESC"
                   + ") WHERE ROWNUM <= 12";
        List<Map<String, Object>> result = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new LinkedHashMap<>();
                map.put("month", rs.getString("month_label"));
                map.put("totalSales", rs.getBigDecimal("total_sales"));
                map.put("orderCount", rs.getInt("order_count"));
                result.add(map);
            }
        }
        return result;
    }

    private List<Order> queryOrders(String sql, Object... params) throws SQLException {
        List<Order> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        }
        return list;
    }

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setCustomerId(rs.getInt("customer_id"));
        o.setFarmerId(rs.getInt("farmer_id"));
        o.setTotalAmount(rs.getBigDecimal("total_amount"));
        o.setStatus(rs.getString("status"));
        o.setAddress(rs.getString("address"));
        o.setOrderDate(rs.getTimestamp("order_date"));
        o.setExpectedDeliveryDate(rs.getDate("expected_delivery_date"));
        o.setCustomerName(rs.getString("customer_name"));
        o.setFarmerName(rs.getString("farmer_name"));
        return o;
    }
}
