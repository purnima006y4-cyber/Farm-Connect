package com.farmconnect.dao;

import com.farmconnect.model.Review;
import com.farmconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the REVIEW table.
 * Enforces business rule:
 * - Only a customer with a DELIVERED order containing that product may review it.
 * - One review per customer per product (enforced by DB UNIQUE constraint on product_id, user_id).
 */
public class ReviewDAO {

    /**
     * Check if a customer is eligible to review a product.
     * Eligible = Customer has placed an order containing this product that is DELIVERED.
     */
    public boolean canReview(int userId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM ORDERS o "
                   + "JOIN ORDER_ITEM oi ON o.order_id = oi.order_id "
                   + "WHERE o.customer_id = ? AND oi.product_id = ? AND o.status = 'DELIVERED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Check if user has already reviewed this product.
     */
    public boolean hasReviewed(int userId, int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM REVIEW WHERE user_id = ? AND product_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Insert a review. Caller verifies eligibility.
     */
    public void insert(int productId, int userId, int rating, String reviewText) throws SQLException {
        String sql = "INSERT INTO REVIEW (product_id, user_id, rating, review_text) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, reviewText);
            ps.executeUpdate();
        }
    }

    /**
     * Get all reviews for a product with user details.
     */
    public List<Review> findByProduct(int productId) throws SQLException {
        String sql = "SELECT r.review_id, r.product_id, r.user_id, r.rating, r.review_text, "
                   + "u.name AS user_name, p.name AS product_name "
                   + "FROM REVIEW r "
                   + "JOIN USERS u ON r.user_id = u.user_id "
                   + "JOIN PRODUCT p ON r.product_id = p.product_id "
                   + "WHERE r.product_id = ? "
                   + "ORDER BY r.review_id DESC";
        List<Review> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    private Review map(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("review_id"));
        r.setProductId(rs.getInt("product_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRating(rs.getInt("rating"));
        r.setReviewText(rs.getString("review_text"));
        r.setUserName(rs.getString("user_name"));
        r.setProductName(rs.getString("product_name"));
        return r;
    }
}
