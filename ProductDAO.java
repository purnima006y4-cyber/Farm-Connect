package com.farmconnect.dao;

import com.farmconnect.model.Product;
import com.farmconnect.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * DAO for the PRODUCT table.
 * All queries use PreparedStatement to prevent SQL injection.
 * Farmers can only update or delete products they own (WHERE farmer_id = ?).
 */
public class ProductDAO {

    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    /**
     * Search and filter products for customers (backward-compatible signature).
     */
    public List<Product> search(String nameQuery, Integer categoryId, String season,
                                String location, String pincode, boolean verifiedOnly,
                                int page, int pageSize) throws SQLException {
        return search(nameQuery, categoryId, season, location, pincode, verifiedOnly, null, null, null, page, pageSize);
    }

    /**
     * Search and filter products with sorting and price bounds.
     */
    public List<Product> search(String nameQuery, Integer categoryId, String season,
                                String location, String pincode, boolean verifiedOnly,
                                String sort, BigDecimal minPrice, BigDecimal maxPrice,
                                int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name AS category_name, u.name AS farmer_name, "
                + "fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "NVL(AVG(r.rating), 0) AS avg_rating, "
                + "TRUNC(SYSDATE) - TRUNC(p.harvest_date) AS days_since_harvest "
                + "FROM PRODUCT p "
                + "JOIN USERS u ON p.farmer_id = u.user_id "
                + "JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "LEFT JOIN REVIEW r ON r.product_id = p.product_id "
                + "WHERE p.status = 'AVAILABLE' AND u.status = 'ACTIVE' ");

        List<Object> params = new ArrayList<>();

        if (nameQuery != null && !nameQuery.trim().isEmpty()) {
            sql.append("AND UPPER(p.name) LIKE UPPER(?) ");
            params.add("%" + nameQuery.trim() + "%");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (season != null && !season.trim().isEmpty() && !"ALL".equalsIgnoreCase(season)) {
            sql.append("AND (p.season = ? OR p.season = 'ALL') ");
            params.add(season);
        }
        if (location != null && !location.trim().isEmpty()) {
            sql.append("AND UPPER(fp.location) LIKE UPPER(?) ");
            params.add("%" + location.trim() + "%");
        }
        if (pincode != null && !pincode.trim().isEmpty()) {
            sql.append("AND fp.pincode = ? ");
            params.add(pincode.trim());
        }
        if (verifiedOnly) {
            sql.append("AND fp.verified = 'Y' ");
        }
        if (minPrice != null && minPrice.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append("AND p.price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice != null && maxPrice.compareTo(BigDecimal.ZERO) > 0) {
            sql.append("AND p.price <= ? ");
            params.add(maxPrice);
        }

        sql.append("GROUP BY p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name, u.name, fp.farm_name, fp.location, fp.pincode, fp.verified ");

        String orderClause = "ORDER BY p.product_id DESC";
        if ("price_asc".equalsIgnoreCase(sort)) {
            orderClause = "ORDER BY p.price ASC, p.product_id DESC";
        } else if ("price_desc".equalsIgnoreCase(sort)) {
            orderClause = "ORDER BY p.price DESC, p.product_id DESC";
        } else if ("rating".equalsIgnoreCase(sort)) {
            orderClause = "ORDER BY NVL(AVG(r.rating), 0) DESC, p.product_id DESC";
        }
        sql.append(orderClause);

        int offset = (Math.max(1, page) - 1) * pageSize;
        int maxRow = offset + pageSize;
        int minRow = offset;

        String wrappedSql = "SELECT * FROM (SELECT a.*, ROWNUM rn FROM ("
                + sql.toString()
                + ") a WHERE ROWNUM <= ?) WHERE rn > ?";
        params.add(maxRow);
        params.add(minRow);

        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(wrappedSql)) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFull(rs));
                }
            }
        }
        return list;
    }

    /** Find all available products for a specific farmer (for public farmer profile). */
    public List<Product> findAvailableByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name AS category_name, u.name AS farmer_name, "
                + "fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "NVL(AVG(r.rating), 0) AS avg_rating, "
                + "TRUNC(SYSDATE) - TRUNC(p.harvest_date) AS days_since_harvest "
                + "FROM PRODUCT p "
                + "JOIN USERS u ON p.farmer_id = u.user_id "
                + "JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "LEFT JOIN REVIEW r ON r.product_id = p.product_id "
                + "WHERE p.farmer_id = ? AND p.status = 'AVAILABLE' "
                + "GROUP BY p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name, u.name, fp.farm_name, fp.location, fp.pincode, fp.verified "
                + "ORDER BY p.product_id DESC";
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFull(rs));
                }
            }
        }
        return list;
    }

    /** Calculate overall average rating across all products for a farmer. */
    public double getAverageRatingForFarmer(int farmerId) throws SQLException {
        String sql = "SELECT NVL(AVG(r.rating), 0) FROM REVIEW r "
                   + "JOIN PRODUCT p ON r.product_id = p.product_id "
                   + "WHERE p.farmer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble(1) : 0.0;
            }
        }
    }

    /** Count active/available produce listings for a farmer. */
    public int countActiveByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM PRODUCT WHERE farmer_id = ? AND status = 'AVAILABLE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Find product by ID with joined category, farmer, rating, and days since harvest. */
    public Product findById(int productId) throws SQLException {
        String sql = "SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name AS category_name, u.name AS farmer_name, "
                + "fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "NVL(AVG(r.rating), 0) AS avg_rating, "
                + "TRUNC(SYSDATE) - TRUNC(p.harvest_date) AS days_since_harvest "
                + "FROM PRODUCT p "
                + "JOIN USERS u ON p.farmer_id = u.user_id "
                + "JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "LEFT JOIN REVIEW r ON r.product_id = p.product_id "
                + "WHERE p.product_id = ? "
                + "GROUP BY p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name, u.name, fp.farm_name, fp.location, fp.pincode, fp.verified";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapFull(rs);
                }
            }
        }
        return null;
    }

    /** All products belonging to a specific farmer. */
    public List<Product> findByFarmer(int farmerId) throws SQLException {
        String sql = "SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name AS category_name, u.name AS farmer_name, "
                + "fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "NVL(AVG(r.rating), 0) AS avg_rating, "
                + "TRUNC(SYSDATE) - TRUNC(p.harvest_date) AS days_since_harvest "
                + "FROM PRODUCT p "
                + "JOIN USERS u ON p.farmer_id = u.user_id "
                + "JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "LEFT JOIN REVIEW r ON r.product_id = p.product_id "
                + "WHERE p.farmer_id = ? "
                + "GROUP BY p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name, u.name, fp.farm_name, fp.location, fp.pincode, fp.verified "
                + "ORDER BY p.product_id DESC";
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFull(rs));
                }
            }
        }
        return list;
    }

    /**
     * Insert a new product.
     * Status is automatically set to AVAILABLE if quantity > 0, else OUT_OF_STOCK.
     */
    public void insert(int farmerId, int categoryId, String name, BigDecimal price,
                       int quantity, Date harvestDate, String imagePath, String season)
            throws SQLException {
        String sql = "INSERT INTO PRODUCT (farmer_id, category_id, name, price, quantity, "
                   + "harvest_date, image_path, status, season) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String status = quantity == 0 ? "OUT_OF_STOCK" : "AVAILABLE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            if (categoryId > 0) ps.setInt(2, categoryId); else ps.setNull(2, Types.INTEGER);
            ps.setString(3, name);
            ps.setBigDecimal(4, price);
            ps.setInt(5, quantity);
            ps.setDate(6, harvestDate);
            ps.setString(7, imagePath);
            ps.setString(8, status);
            ps.setString(9, season != null ? season : "ALL");
            ps.executeUpdate();
        }
    }

    /**
     * Update an existing product.
     * Enforces server-side ownership by checking farmer_id in WHERE clause.
     */
    public void update(int productId, int farmerId, int categoryId, String name, BigDecimal price,
                       int quantity, Date harvestDate, String imagePath, String season)
            throws SQLException {
        String status = quantity == 0 ? "OUT_OF_STOCK" : "AVAILABLE";
        String sql = "UPDATE PRODUCT SET category_id = ?, name = ?, price = ?, quantity = ?, "
                   + "harvest_date = ?, image_path = ?, status = ?, season = ? "
                   + "WHERE product_id = ? AND farmer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (categoryId > 0) ps.setInt(1, categoryId); else ps.setNull(1, Types.INTEGER);
            ps.setString(2, name);
            ps.setBigDecimal(3, price);
            ps.setInt(4, quantity);
            ps.setDate(5, harvestDate);
            ps.setString(6, imagePath);
            ps.setString(7, status);
            ps.setString(8, season != null ? season : "ALL");
            ps.setInt(9, productId);
            ps.setInt(10, farmerId);
            ps.executeUpdate();
        }
    }

    /**
     * Soft-delete: mark product OUT_OF_STOCK and zero quantity.
     * WHERE farmer_id = ? enforces ownership.
     */
    public void delete(int productId, int farmerId) throws SQLException {
        String sql = "UPDATE PRODUCT SET status = 'OUT_OF_STOCK', quantity = 0 "
                   + "WHERE product_id = ? AND farmer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, farmerId);
            ps.executeUpdate();
        }
    }

    /** Find low stock products (quantity < threshold) for low-stock alerts. */
    public List<Product> findLowStock(int farmerId, int threshold) throws SQLException {
        String sql = "SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "p.harvest_date, p.image_path, p.status, p.season, "
                + "c.name AS category_name, u.name AS farmer_name, "
                + "fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "0 AS avg_rating, 0 AS days_since_harvest "
                + "FROM PRODUCT p "
                + "JOIN USERS u ON p.farmer_id = u.user_id "
                + "JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "WHERE p.farmer_id = ? AND p.quantity < ? AND p.status = 'AVAILABLE' "
                + "ORDER BY p.quantity ASC";
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            ps.setInt(2, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFull(rs));
                }
            }
        }
        return list;
    }

    /** All products with pagination (for Admin). */
    public List<Product> findAll(int page, int pageSize) throws SQLException {
        int offset = (Math.max(1, page) - 1) * pageSize;
        int maxRow = offset + pageSize;
        int minRow = offset;
        String sql = "SELECT * FROM ("
                + "  SELECT a.*, ROWNUM rn FROM ("
                + "    SELECT p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "    p.harvest_date, p.image_path, p.status, p.season, "
                + "    c.name AS category_name, u.name AS farmer_name, "
                + "    fp.farm_name, fp.location AS farmer_location, fp.pincode AS farmer_pincode, fp.verified AS farmer_verified, "
                + "    NVL(AVG(r.rating), 0) AS avg_rating, "
                + "    TRUNC(SYSDATE) - TRUNC(p.harvest_date) AS days_since_harvest "
                + "    FROM PRODUCT p "
                + "    JOIN USERS u ON p.farmer_id = u.user_id "
                + "    JOIN FARMER_PROFILE fp ON fp.user_id = p.farmer_id "
                + "    LEFT JOIN CATEGORY c ON p.category_id = c.category_id "
                + "    LEFT JOIN REVIEW r ON r.product_id = p.product_id "
                + "    GROUP BY p.product_id, p.farmer_id, p.category_id, p.name, p.price, p.quantity, "
                + "    p.harvest_date, p.image_path, p.status, p.season, "
                + "    c.name, u.name, fp.farm_name, fp.location, fp.pincode, fp.verified "
                + "    ORDER BY p.product_id DESC"
                + "  ) a WHERE ROWNUM <= ?"
                + ") WHERE rn > ?";
        List<Product> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maxRow);
            ps.setInt(2, minRow);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapFull(rs));
                }
            }
        }
        return list;
    }

    /** Top products by units sold (for Admin Reports). */
    public List<Map<String, Object>> getTopProducts(int limit) throws SQLException {
        String sql = "SELECT * FROM ("
                   + "  SELECT p.name, SUM(oi.quantity) AS total_sold "
                   + "  FROM ORDER_ITEM oi "
                   + "  JOIN PRODUCT p ON oi.product_id = p.product_id "
                   + "  GROUP BY p.name "
                   + "  ORDER BY total_sold DESC"
                   + ") WHERE ROWNUM <= ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("name", rs.getString("name"));
                    map.put("totalSold", rs.getLong("total_sold"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    private Product mapFull(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("product_id"));
        p.setFarmerId(rs.getInt("farmer_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setName(rs.getString("name"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setQuantity(rs.getInt("quantity"));
        p.setHarvestDate(rs.getDate("harvest_date"));
        p.setImagePath(rs.getString("image_path"));
        p.setStatus(rs.getString("status"));
        p.setSeason(rs.getString("season"));
        p.setCategoryName(rs.getString("category_name"));
        p.setFarmerName(rs.getString("farmer_name"));
        p.setFarmName(rs.getString("farm_name"));
        p.setFarmerLocation(rs.getString("farmer_location"));
        p.setFarmerPincode(rs.getString("farmer_pincode"));
        p.setFarmerVerified(rs.getString("farmer_verified"));
        p.setAvgRating(rs.getDouble("avg_rating"));
        p.setDaysSinceHarvest(rs.getLong("days_since_harvest"));
        return p;
    }
}
