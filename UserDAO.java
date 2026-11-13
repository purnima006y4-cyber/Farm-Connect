package com.farmconnect.dao;

import com.farmconnect.model.FarmerProfile;
import com.farmconnect.model.User;
import com.farmconnect.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * DAO for USERS and FARMER_PROFILE tables.
 * All queries use PreparedStatement to prevent SQL injection.
 */
public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    /**
     * Find a user by email. Returns null if not found.
     * Used during login to fetch the stored hash for BCrypt verification.
     */
    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, user_role, phone, status, created_at "
                   + "FROM USERS WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    /** Find a user by primary key. Returns null if not found. */
    public User findById(int userId) throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, user_role, phone, status, created_at "
                   + "FROM USERS WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    /**
     * Register a new CUSTOMER user (status = ACTIVE).
     * @return the generated user_id
     */
    public int registerCustomer(String name, String email, String passwordHash, String phone)
            throws SQLException {
        String sql = "INSERT INTO USERS (name, email, password_hash, user_role, phone, status) "
                   + "VALUES (?, ?, ?, 'CUSTOMER', ?, 'ACTIVE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"USER_ID"})) {
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            ps.setString(4, phone);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Failed to get generated user_id after insert");
    }

    /**
     * Register a new FARMER user (status = PENDING) and create their FARMER_PROFILE.
     * Both inserts are wrapped in a single transaction.
     * @return the generated user_id
     */
    public int registerFarmer(String name, String email, String passwordHash, String phone,
                              String farmName, String location, String pincode)
            throws SQLException {
        String insertUser    = "INSERT INTO USERS (name, email, password_hash, user_role, phone, status) "
                             + "VALUES (?, ?, ?, 'FARMER', ?, 'PENDING')";
        String insertProfile = "INSERT INTO FARMER_PROFILE (user_id, farm_name, location, pincode, verified) "
                             + "VALUES (?, ?, ?, ?, 'N')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int userId;
                try (PreparedStatement ps = conn.prepareStatement(insertUser, new String[]{"USER_ID"})) {
                    ps.setString(1, name);
                    ps.setString(2, email);
                    ps.setString(3, passwordHash);
                    ps.setString(4, phone);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("No user_id generated");
                        userId = keys.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(insertProfile)) {
                    ps.setInt(1, userId);
                    ps.setString(2, farmName);
                    ps.setString(3, location);
                    ps.setString(4, pincode);
                    ps.executeUpdate();
                }
                conn.commit();
                return userId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /** Check whether an email is already registered. */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM USERS WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Update a user's status (ACTIVE, PENDING, BLOCKED) — used by admin.
     */
    public void updateStatus(int userId, String status) throws SQLException {
        String sql = "UPDATE USERS SET status = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /** List all users with a given role, newest first. */
    public List<User> findByRole(String role) throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, user_role, phone, status, created_at "
                   + "FROM USERS WHERE user_role = ? ORDER BY created_at DESC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapUser(rs));
            }
        }
        return list;
    }

    /** Get all farmers with their profiles joined (for admin panel). */
    public List<FarmerProfile> findAllFarmerProfiles() throws SQLException {
        String sql = "SELECT fp.farmer_id, fp.user_id, fp.farm_name, fp.location, fp.pincode, fp.verified, "
                   + "u.name AS farmer_name, u.email, u.phone, u.status "
                   + "FROM FARMER_PROFILE fp JOIN USERS u ON fp.user_id = u.user_id "
                   + "ORDER BY u.created_at DESC";
        List<FarmerProfile> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapFarmerProfile(rs));
            }
        }
        return list;
    }

    /** Get farmer profile by user_id. Returns null if not found. */
    public FarmerProfile findFarmerProfileByUserId(int userId) throws SQLException {
        String sql = "SELECT fp.farmer_id, fp.user_id, fp.farm_name, fp.location, fp.pincode, fp.verified, "
                   + "u.name AS farmer_name, u.email, u.phone, u.status "
                   + "FROM FARMER_PROFILE fp JOIN USERS u ON fp.user_id = u.user_id "
                   + "WHERE fp.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapFarmerProfile(rs);
            }
        }
        return null;
    }

    /** Approve a farmer: set user status=ACTIVE and verified=Y in FARMER_PROFILE. */
    public void approveFarmer(int userId) throws SQLException {
        String sql1 = "UPDATE USERS SET status = 'ACTIVE' WHERE user_id = ?";
        String sql2 = "UPDATE FARMER_PROFILE SET verified = 'Y' WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /** Count users by role (for admin dashboard). */
    public int countByRole(String role) throws SQLException {
        String sql = "SELECT COUNT(*) FROM USERS WHERE user_role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Count pending farmer registrations. */
    public int countPendingFarmers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM USERS WHERE user_role = 'FARMER' AND status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Update customer name and phone. */
    public void updateCustomerProfile(int userId, String name, String phone) throws SQLException {
        String sql = "UPDATE USERS SET name = ?, phone = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    /** Update farmer profile and user details in a single transaction. */
    public void updateFarmerProfile(int userId, String name, String phone,
                                   String farmName, String location, String pincode) throws SQLException {
        String sqlUsers = "UPDATE USERS SET name = ?, phone = ? WHERE user_id = ?";
        String sqlProfile = "UPDATE FARMER_PROFILE SET farm_name = ?, location = ?, pincode = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlUsers)) {
                    ps.setString(1, name);
                    ps.setString(2, phone);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(sqlProfile)) {
                    ps.setString(1, farmName);
                    ps.setString(2, location);
                    ps.setString(3, pincode);
                    ps.setInt(4, userId);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /** Update user password hash. */
    public void updatePassword(int userId, String newHash) throws SQLException {
        String sql = "UPDATE USERS SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /** List all users for admin panel. */
    public List<User> findAll() throws SQLException {
        String sql = "SELECT user_id, name, email, password_hash, user_role, phone, status, created_at "
                   + "FROM USERS ORDER BY created_at DESC";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapUser(rs));
        }
        return list;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setUserRole(rs.getString("user_role"));
        u.setPhone(rs.getString("phone"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }

    private FarmerProfile mapFarmerProfile(ResultSet rs) throws SQLException {
        FarmerProfile fp = new FarmerProfile();
        fp.setFarmerId(rs.getInt("farmer_id"));
        fp.setUserId(rs.getInt("user_id"));
        fp.setFarmName(rs.getString("farm_name"));
        fp.setLocation(rs.getString("location"));
        fp.setPincode(rs.getString("pincode"));
        fp.setVerified(rs.getString("verified"));
        fp.setFarmerName(rs.getString("farmer_name"));
        fp.setEmail(rs.getString("email"));
        fp.setPhone(rs.getString("phone"));
        fp.setStatus(rs.getString("status"));
        return fp;
    }
}
