package com.farmconnect.model;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * POJO for a product listed by a farmer.
 * status: AVAILABLE or OUT_OF_STOCK (auto-set when quantity=0).
 * season: SUMMER, MONSOON, WINTER, ALL.
 */
public class Product {
    private int productId;
    private int farmerId;
    private int categoryId;
    private String name;
    private BigDecimal price;
    private int quantity;
    private Date harvestDate;
    private String imagePath;
    private String status;
    private String season;
    // Joined fields
    private String categoryName;
    private String farmerName;
    private String farmName;
    private String farmerLocation;
    private String farmerPincode;
    private String farmerVerified;
    private double avgRating;
    private long daysSinceHarvest;

    public Product() {}

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public Date getHarvestDate() { return harvestDate; }
    public void setHarvestDate(Date harvestDate) { this.harvestDate = harvestDate; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSeason() { return season; }
    public void setSeason(String season) { this.season = season; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }

    public String getFarmerLocation() { return farmerLocation; }
    public void setFarmerLocation(String farmerLocation) { this.farmerLocation = farmerLocation; }

    public String getFarmerPincode() { return farmerPincode; }
    public void setFarmerPincode(String farmerPincode) { this.farmerPincode = farmerPincode; }

    public String getFarmerVerified() { return farmerVerified; }
    public void setFarmerVerified(String farmerVerified) { this.farmerVerified = farmerVerified; }

    public double getAvgRating() { return avgRating; }
    public void setAvgRating(double avgRating) { this.avgRating = avgRating; }

    public long getDaysSinceHarvest() { return daysSinceHarvest; }
    public void setDaysSinceHarvest(long daysSinceHarvest) { this.daysSinceHarvest = daysSinceHarvest; }
}
