package com.farmconnect.model;

/**
 * Profile details for a farmer user.
 * One-to-one with USERS (user_role=FARMER).
 */
public class FarmerProfile {
    private int farmerId;
    private int userId;
    private String farmName;
    private String location;
    private String pincode;
    private String verified; // Y or N
    private String farmerName; // joined from USERS
    private String email;      // joined from USERS
    private String phone;      // joined from USERS
    private String status;     // from USERS (ACTIVE/PENDING/BLOCKED)

    public FarmerProfile() {}

    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getPincode() { return pincode; }
    public void setPincode(String pincode) { this.pincode = pincode; }

    public String getVerified() { return verified; }
    public void setVerified(String verified) { this.verified = verified; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
