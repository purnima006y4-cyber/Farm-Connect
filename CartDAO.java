package com.farmconnect.dao;

import com.farmconnect.model.CartItem;
import com.farmconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the CART_ITEM table.
 * Cart items are per user and product.
 * Enforces stock validation so quantities above available stock are rejected.
 */
public class CartDAO {

    /** Retrieve all cart items for a user with joined product and farmer details. */
    public List<CartItem> findByUser(int userId) throws SQLException {
        String sql = "SELECT ci.cart_id, ci.user_id, ci.product_id, ci.quantity, "
                   + "p.name AS product_name, p.price, p.quantity AS available_quantity, "
                   + "p.image_path, p.farmer_id, p.status, u.name AS farmer_name "
                   + "FROM CART_ITEM ci "
                   + "JOIN PRODUCT p ON ci.product_id = p.product_id "
                   + "JOIN USERS u ON p.farmer_id = u.user_id "
                   + "WHERE ci.user_id = ? "
                   + "ORDER BY ci.cart_id";
        List<CartItem> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    /**
     * Add product to cart or update quantity if already present.
     * Validates that quantity does not exceed available stock.
     */
    public void addOrUpdate(int userId, int productId, int qty) throws SQLException {
        // 1. Verify available stock
        String checkStockSql = "SELECT quantity FROM PRODUCT WHERE product_id = ? AND status = 'AVAILABLE'";
        int available = 0;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkStockSql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalArgumentException("Product is no longer available.");
                }
                available = rs.getInt("quantity");
            }
        }

        if (qty > available) {
            throw new IllegalArgumentException("Only " + available + " available.");
        }

        // 2. Check if item is already in user's cart
        String checkCartSql = "SELECT cart_id, quantity FROM CART_ITEM WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkCartSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Update
                    updateQuantity(userId, productId, qty);
                } else {
                    // Insert
                    insert(userId, productId, qty);
                }
            }
        }
    }

    private void insert(int userId, int productId, int qty) throws SQLException {
        String sql = "INSERT INTO CART_ITEM (user_id, product_id, quantity) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.setInt(3, qty);
            ps.executeUpdate();
        }
    }

    public void updateQuantity(int userId, int productId, int qty) throws SQLException {
        String sql = "UPDATE CART_ITEM SET quantity = ? WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, userId);
            ps.setInt(3, productId);
            ps.executeUpdate();
        }
    }

    public void remove(int userId, int productId) throws SQLException {
        String sql = "DELETE FROM CART_ITEM WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }

    /**
     * Clear all items from a customer's cart in a shared transaction.
     */
    public void clearCart(Connection conn, int userId) throws SQLException {
        String sql = "DELETE FROM CART_ITEM WHERE user_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public int countItems(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CART_ITEM WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private CartItem map(ResultSet rs) throws SQLException {
        CartItem ci = new CartItem();
        ci.setCartId(rs.getInt("cart_id"));
        ci.setUserId(rs.getInt("user_id"));
        ci.setProductId(rs.getInt("product_id"));
        ci.setQuantity(rs.getInt("quantity"));
        ci.setProductName(rs.getString("product_name"));
        ci.setPrice(rs.getBigDecimal("price"));
        ci.setAvailableQuantity(rs.getInt("available_quantity"));
        ci.setImagePath(rs.getString("image_path"));
        ci.setFarmerName(rs.getString("farmer_name"));
        ci.setFarmerId(rs.getInt("farmer_id"));
        ci.setStatus(rs.getString("status"));
        return ci;
    }
}
