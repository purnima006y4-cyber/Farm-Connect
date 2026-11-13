package com.farmconnect.dao;

import com.farmconnect.model.Category;
import com.farmconnect.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the CATEGORY table. CRUD operations for admin.
 */
public class CategoryDAO {

    /** List all categories ordered by name. */
    public List<Category> findAll() throws SQLException {
        String sql = "SELECT category_id, name, description FROM CATEGORY ORDER BY name";
        List<Category> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    /** Find a category by primary key. Returns null if not found. */
    public Category findById(int id) throws SQLException {
        String sql = "SELECT category_id, name, description FROM CATEGORY WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Insert a new category. @return generated category_id */
    public int insert(String name, String description) throws SQLException {
        String sql = "INSERT INTO CATEGORY (name, description) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"CATEGORY_ID"})) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("category_id not generated");
    }

    /** Update category name and description. */
    public void update(int id, String name, String description) throws SQLException {
        String sql = "UPDATE CATEGORY SET name = ?, description = ? WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    /** Delete a category (will fail via FK if products reference it). */
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM CATEGORY WHERE category_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private Category map(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setCategoryId(rs.getInt("category_id"));
        c.setName(rs.getString("name"));
        c.setDescription(rs.getString("description"));
        return c;
    }
}
