package com.farmconnect.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 * POJO for an order. One order per farmer per checkout.
 * Status lifecycle: PLACED->CONFIRMED->PACKED->OUT_FOR_DELIVERY->DELIVERED,
 * or CANCELLED/REJECTED.
 */
public class Order {
    private int orderId;
    private int customerId;
    private int farmerId;
    private BigDecimal totalAmount;
    private String status;
    private String address;
    private Timestamp orderDate;
    private Date expectedDeliveryDate;
    // Joined fields
    private String customerName;
    private String farmerName;
    private List<OrderItem> items;

    public Order() {}

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Timestamp getOrderDate() { return orderDate; }
    public void setOrderDate(Timestamp orderDate) { this.orderDate = orderDate; }

    public Date getExpectedDeliveryDate() { return expectedDeliveryDate; }
    public void setExpectedDeliveryDate(Date expectedDeliveryDate) { this.expectedDeliveryDate = expectedDeliveryDate; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getFarmerName() { return farmerName; }
    public void setFarmerName(String farmerName) { this.farmerName = farmerName; }

    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
}
