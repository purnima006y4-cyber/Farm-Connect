package com.farmconnect.dao;

import com.farmconnect.model.Complaint;
import com.farmconnect.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the COMPLAINT table.
 * All queries use PreparedStatement to guard against SQL injection.
 * Customers can raise complaints against their own orders.
 * Admins can list complaints and update their resolution status.
 */
public class ComplaintDAO {

    /**
     * Insert a new complaint for an order.
     */
    public void insert(int userId, int orderId, String message) throws SQLException {
        String sql = "INSERT INTO COMPLAINT (user_id, order_id, message, status) VALUES (?, ?, ?, 'OPEN')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, orderId);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }

    /**
     * List all complaints in reverse chronological order (for Admin).
     */
    public List<Complaint> findAll() throws SQLException {
        String sql = "SELECT c.complaint_id, c.user_id, c.order_id, c.message, c.status, "
                   + "u.name AS user_name, u.email AS user_email "
                   + "FROM COMPLAINT c "
                   + "JOIN USERS u ON c.user_id = u.user_id "
                   + "ORDER BY c.complaint_id DESC";
        List<Complaint> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        }
        return list;
    }

    /**
     * Find complaints raised by a specific customer.
     */
    public List<Complaint> findByUser(int userId) throws SQLException {
        String sql = "SELECT c.complaint_id, c.user_id, c.order_id, c.message, c.status, "
                   + "u.name AS user_name, u.email AS user_email "
                   + "FROM COMPLAINT c "
                   + "JOIN USERS u ON c.user_id = u.user_id "
                   + "WHERE c.user_id = ? "
                   + "ORDER BY c.complaint_id DESC";
        List<Complaint> list = new ArrayList<>();
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
     * Update complaint status (OPEN, RESOLVED, CLOSED) - executed by Admin.
     */
    public void updateStatus(int complaintId, String status) throws SQLException {
        String sql = "UPDATE COMPLAINT SET status = ? WHERE complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, complaintId);
            ps.executeUpdate();
        }
    }

    private Complaint map(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setComplaintId(rs.getInt("complaint_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setOrderId(rs.getInt("order_id"));
        c.setMessage(rs.getString("message"));
        c.setStatus(rs.getString("status"));
        c.setUserName(rs.getString("user_name"));
        c.setUserEmail(rs.getString("user_email"));
        return c;
    }
}
