package com.farmconnect.controller;

import com.farmconnect.dao.CartDAO;
import com.farmconnect.dao.OrderDAO;
import com.farmconnect.dao.ProductDAO;
import com.farmconnect.model.CartItem;
import com.farmconnect.model.Order;
import com.farmconnect.model.OrderItem;
import com.farmconnect.util.JwtUtil;
import io.jsonwebtoken.Claims;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet(urlPatterns = {
        "/checkout",
        "/customer/orders",
        "/customer/order",
        "/customer/orders/cancel",
        "/farmer/orders",
        "/farmer/order",
        "/farmer/orders/advance",
        "/farmer/orders/reject",
        "/farmer/dashboard",
        "/farmer/sales"
})
public class OrderServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(OrderServlet.class.getName());

    private final OrderDAO orderDAO = new OrderDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        Integer userId = getUserId(req);
        String role = getRole(req);

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/checkout":
                    handleShowCheckout(req, resp, userId);
                    break;
                case "/customer/orders":
                    handleCustomerOrders(req, resp, userId);
                    break;
                case "/customer/order":
                    handleCustomerOrderDetail(req, resp, userId);
                    break;
                case "/farmer/orders":
                    handleFarmerOrders(req, resp, userId);
                    break;
                case "/farmer/order":
                    handleFarmerOrderDetail(req, resp, userId);
                    break;
                case "/farmer/dashboard":
                    handleFarmerDashboard(req, resp, userId);
                    break;
                case "/farmer/sales":
                    handleFarmerSales(req, resp, userId);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "OrderServlet GET error on path: " + path, e);
            req.setAttribute("error", "Database error occurred.");
            req.getRequestDispatcher("/jsp/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        Integer userId = getUserId(req);
        String role = getRole(req);

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/checkout":
                    handleCheckout(req, resp, userId);
                    break;
                case "/customer/orders/cancel":
                    handleCancelOrder(req, resp, userId, role);
                    break;
                case "/farmer/orders/advance":
                    handleAdvanceOrder(req, resp, userId);
                    break;
                case "/farmer/orders/reject":
                    handleRejectOrder(req, resp, userId, role);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "OrderServlet POST error: " + e.getMessage(), e);
            req.setAttribute("error", e.getMessage());
            if ("/checkout".equals(path)) {
                try {
                    handleShowCheckout(req, resp, userId);
                } catch (SQLException sqle) {
                    resp.sendRedirect(req.getContextPath() + "/cart");
                }
            } else if (path.startsWith("/farmer/")) {
                resp.sendRedirect(req.getContextPath() + "/farmer/orders");
            } else {
                resp.sendRedirect(req.getContextPath() + "/customer/orders");
            }
        }
    }

    private void handleShowCheckout(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, ServletException, IOException {
        List<CartItem> items = cartDAO.findByUser(userId);
        if (items.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        BigDecimal total = BigDecimal.ZERO;
        for (CartItem ci : items) {
            total = total.add(ci.getLineTotal());
        }

        req.setAttribute("cartItems", items);
        req.setAttribute("cartTotal", total);
        req.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(req, resp);
    }

    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp, int customerId)
            throws Exception {
        String address = req.getParameter("address");
        if (address == null || address.trim().isEmpty()) {
            req.setAttribute("error", "Please provide a valid delivery address.");
            handleShowCheckout(req, resp, customerId);
            return;
        }

        // Run the atomic checkout transaction in OrderDAO
        orderDAO.checkout(customerId, address);

        // PRG pattern: redirect after successful POST
        resp.sendRedirect(req.getContextPath() + "/customer/orders?success=true");
    }

    private void handleCustomerOrders(HttpServletRequest req, HttpServletResponse resp, int customerId)
            throws SQLException, ServletException, IOException {
        List<Order> orders = orderDAO.findByCustomer(customerId);
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/jsp/customer/my-orders.jsp").forward(req, resp);
    }

    private void handleCustomerOrderDetail(HttpServletRequest req, HttpServletResponse resp, int customerId)
            throws SQLException, ServletException, IOException {
        int orderId = 0;
        try {
            orderId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception ignored) {}

        Order order = orderDAO.findById(orderId);
        // Ownership check
        if (order == null || order.getCustomerId() != customerId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized: Not your order.");
            return;
        }

        req.setAttribute("order", order);
        req.setAttribute("items", order.getItems());
        req.getRequestDispatcher("/jsp/customer/order-detail.jsp").forward(req, resp);
    }

    private void handleFarmerOrders(HttpServletRequest req, HttpServletResponse resp, int farmerId)
            throws SQLException, ServletException, IOException {
        List<Order> orders = orderDAO.findByFarmer(farmerId);
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/jsp/farmer/orders.jsp").forward(req, resp);
    }

    private void handleFarmerOrderDetail(HttpServletRequest req, HttpServletResponse resp, int farmerId)
            throws SQLException, ServletException, IOException {
        int orderId = 0;
        try {
            orderId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception ignored) {}

        Order order = orderDAO.findById(orderId);
        // Ownership check: farmer can only see orders where farmer_id is his
        if (order == null || order.getFarmerId() != farmerId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized: Not your order.");
            return;
        }

        req.setAttribute("order", order);
        req.setAttribute("items", order.getItems());
        req.getRequestDispatcher("/jsp/farmer/order-detail.jsp").forward(req, resp);
    }

    private void handleFarmerDashboard(HttpServletRequest req, HttpServletResponse resp, int farmerId)
            throws SQLException, ServletException, IOException {
        req.setAttribute("totalSales", orderDAO.getTotalSalesByFarmer(farmerId));
        List<Order> farmerOrders = orderDAO.findByFarmer(farmerId);
        req.setAttribute("totalOrders", farmerOrders.size());
        req.setAttribute("recentOrders", farmerOrders.size() > 5 ? farmerOrders.subList(0, 5) : farmerOrders);
        req.setAttribute("lowStock", productDAO.findLowStock(farmerId, 10));
        req.getRequestDispatcher("/jsp/farmer/dashboard.jsp").forward(req, resp);
    }

    private void handleFarmerSales(HttpServletRequest req, HttpServletResponse resp, int farmerId)
            throws SQLException, ServletException, IOException {
        req.setAttribute("monthlySales", orderDAO.getMonthlySales(farmerId));
        req.getRequestDispatcher("/jsp/farmer/sales.jsp").forward(req, resp);
    }

    private void handleCancelOrder(HttpServletRequest req, HttpServletResponse resp, int userId, String role)
            throws Exception {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        orderDAO.cancelOrReject(orderId, userId, role);
        resp.sendRedirect(req.getContextPath() + "/customer/orders");
    }

    private void handleAdvanceOrder(HttpServletRequest req, HttpServletResponse resp, int farmerId)
            throws Exception {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        orderDAO.advanceStatus(orderId, farmerId);
        resp.sendRedirect(req.getContextPath() + "/farmer/orders");
    }

    private void handleRejectOrder(HttpServletRequest req, HttpServletResponse resp, int userId, String role)
            throws Exception {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        orderDAO.cancelOrReject(orderId, userId, role);
        resp.sendRedirect(req.getContextPath() + "/farmer/orders");
    }

    private Integer getUserId(HttpServletRequest req) {
        Object attr = req.getAttribute("userId");
        if (attr instanceof Integer) return (Integer) attr;
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("auth_token".equals(c.getName()) || "jwt".equals(c.getName())) {
                    try {
                        Claims claims = JwtUtil.parseToken(c.getValue());
                        return JwtUtil.getUserId(claims);
                    } catch (Exception ignored) {}
                }
            }
        }
        return null;
    }

    private String getRole(HttpServletRequest req) {
        Object attr = req.getAttribute("role");
        if (attr instanceof String) return (String) attr;
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("auth_token".equals(c.getName()) || "jwt".equals(c.getName())) {
                    try {
                        Claims claims = JwtUtil.parseToken(c.getValue());
                        return JwtUtil.getRole(claims);
                    } catch (Exception ignored) {}
                }
            }
        }
        return "CUSTOMER";
    }
}
