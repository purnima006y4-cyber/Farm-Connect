package com.farmconnect.model;

import java.math.BigDecimal;

/** POJO for a single line item in an order. unit_price captures price at purchase time. */
public class OrderItem {
    private int itemId;
    private int orderId;
    private int productId;
    private int quantity;
    private BigDecimal unitPrice;
    private String productName; // joined
    private String imagePath;   // joined

    public OrderItem() {}

    public int getItemId() { return itemId; }
    public void setItemId(int itemId) { this.itemId = itemId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    /** Convenience: unit_price * quantity. */
    public BigDecimal getLineTotal() {
        return unitPrice != null ? unitPrice.multiply(new BigDecimal(quantity)) : BigDecimal.ZERO;
    }
}
