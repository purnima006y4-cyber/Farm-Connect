package com.farmconnect.model;

import java.math.BigDecimal;

/** POJO for a cart line item. Joined with PRODUCT for display. */
public class CartItem {
    private int cartId;
    private int userId;
    private int productId;
    private int quantity;
    // Joined from PRODUCT
    private String productName;
    private BigDecimal price;
    private int availableQuantity;
    private String imagePath;
    private String farmerName;
    private int farmerId;
    private String status;

    public CartItem() {}

    public int getCartId() { return cartId; }
    public void setCartId(int cartId) { this.cartId = cartId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getAvailableQuantity() { return availableQuantity; }
    public void setAvailableQuantity(int availableQuantity) { this.availableQuantity = availableQuantity; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    /** Convenience: price * quantity. */
    public BigDecimal getLineTotal() {
        return price != null ? price.multiply(new BigDecimal(quantity)) : BigDecimal.ZERO;
    }
}
