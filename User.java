package com.farmconnect.model;

import java.sql.Timestamp;

/**
 * POJO representing a user in the system.
 * Roles: FARMER, CUSTOMER, ADMIN.
 * Status: ACTIVE, PENDING (awaiting admin approval), BLOCKED.
 */
public class User {
    private int userId;
    private String name;
    private String email;
    private String passwordHash;
    private String userRole; // FARMER, CUSTOMER, ADMIN
    private String phone;
    private String status;   // ACTIVE, PENDING, BLOCKED
    private Timestamp createdAt;

    public User() {}

    // Getters and setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
