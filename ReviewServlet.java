package com.farmconnect.controller;

import com.farmconnect.dao.ComplaintDAO;
import com.farmconnect.dao.OrderDAO;
import com.farmconnect.dao.ReviewDAO;
import com.farmconnect.model.Order;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet(urlPatterns = {"/customer/review", "/customer/complaint", "/customer/complaints"})
public class ReviewServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ReviewServlet.class.getName());

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = (int) req.getAttribute("userId");
        String path = req.getServletPath();

        if ("/customer/complaints".equals(path)) {
            try {
                req.setAttribute("complaints", complaintDAO.findByUser(userId));
                req.getRequestDispatcher("/jsp/customer/complaints.jsp").forward(req, resp);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to load complaints", e);
                resp.sendRedirect(req.getContextPath() + "/customer/orders");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = (int) req.getAttribute("userId");
        String path = req.getServletPath();

        try {
            if ("/customer/review".equals(path)) {
                handleSubmitReview(req, resp, userId);
            } else if ("/customer/complaint".equals(path)) {
                handleRaiseComplaint(req, resp, userId);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "ReviewServlet POST error", e);
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
        }
    }

    private void handleSubmitReview(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, IOException, ServletException {
        int productId = 0;
        int rating = 0;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
            rating = Integer.parseInt(req.getParameter("rating"));
        } catch (Exception ignored) {}

        String reviewText = req.getParameter("reviewText");
        reviewText = reviewText != null ? reviewText.trim() : "";

        if (productId <= 0 || rating < 1 || rating > 5) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        // Business rule 1: only customers with a DELIVERED order containing that product may review it
        if (!reviewDAO.canReview(userId, productId)) {
            req.setAttribute("error", "You can only review products from orders that have been DELIVERED.");
            resp.sendRedirect(req.getContextPath() + "/product?id=" + productId);
            return;
        }

        // Business rule 2: one review per user per product
        if (reviewDAO.hasReviewed(userId, productId)) {
            req.setAttribute("error", "You have already reviewed this product.");
            resp.sendRedirect(req.getContextPath() + "/product?id=" + productId);
            return;
        }

        reviewDAO.insert(productId, userId, rating, reviewText);
        resp.sendRedirect(req.getContextPath() + "/product?id=" + productId);
    }

    private void handleRaiseComplaint(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, IOException {
        int orderId = 0;
        try {
            orderId = Integer.parseInt(req.getParameter("orderId"));
        } catch (Exception ignored) {}

        String message = req.getParameter("message");
        message = message != null ? message.trim() : "";

        if (orderId <= 0 || message.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customer/orders");
            return;
        }

        // Server-side ownership check: customer can only complain against their own order
        Order order = orderDAO.findById(orderId);
        if (order == null || order.getCustomerId() != userId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized: Order does not belong to you.");
            return;
        }

        complaintDAO.insert(userId, orderId, message);
        resp.sendRedirect(req.getContextPath() + "/customer/complaints");
    }
}
