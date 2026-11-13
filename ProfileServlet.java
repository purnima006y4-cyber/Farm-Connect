package com.farmconnect.controller;

import com.farmconnect.dao.OrderDAO;
import com.farmconnect.dao.ProductDAO;
import com.farmconnect.dao.UserDAO;
import com.farmconnect.model.FarmerProfile;
import com.farmconnect.model.User;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProfileServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer userId = (Integer) req.getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            req.setAttribute("user", user);
            String role = user.getUserRole();

            if ("CUSTOMER".equalsIgnoreCase(role)) {
                int totalOrders = orderDAO.countOrdersByCustomer(userId);
                BigDecimal totalSpent = orderDAO.getTotalSpentByCustomer(userId);
                req.setAttribute("totalOrders", totalOrders);
                req.setAttribute("totalSpent", totalSpent != null ? totalSpent : BigDecimal.ZERO);
            } else if ("FARMER".equalsIgnoreCase(role)) {
                FarmerProfile fp = userDAO.findFarmerProfileByUserId(userId);
                int activeProducts = productDAO.countActiveByFarmer(userId);
                int totalOrders = orderDAO.countOrdersByFarmer(userId);
                double avgRating = productDAO.getAverageRatingForFarmer(userId);

                req.setAttribute("farmerProfile", fp);
                req.setAttribute("activeProducts", activeProducts);
                req.setAttribute("totalOrders", totalOrders);
                req.setAttribute("avgRating", avgRating);
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                int totalUsers = userDAO.findAll().size();
                int pendingFarmers = userDAO.countPendingFarmers();
                req.setAttribute("totalUsers", totalUsers);
                req.setAttribute("pendingFarmers", pendingFarmers);
            }

            // Move flash messages from session to request
            HttpSession session = req.getSession(false);
            if (session != null) {
                String successMsg = (String) session.getAttribute("profileSuccess");
                if (successMsg != null) {
                    req.setAttribute("successMessage", successMsg);
                    session.removeAttribute("profileSuccess");
                }
                String errorMsg = (String) session.getAttribute("profileError");
                if (errorMsg != null) {
                    req.setAttribute("errorMessage", errorMsg);
                    session.removeAttribute("profileError");
                }
            }

            req.getRequestDispatcher("/jsp/common/profile.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading profile for user " + userId, e);
            req.setAttribute("error", "Database error loading profile.");
            req.getRequestDispatcher("/jsp/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer userId = (Integer) req.getAttribute("userId");
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        try {
            User user = userDAO.findById(userId);
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            if ("updateProfile".equalsIgnoreCase(action)) {
                String name = req.getParameter("name");
                String phone = req.getParameter("phone");

                if (name == null || name.trim().isEmpty()) {
                    session.setAttribute("profileError", "Name cannot be empty.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                if ("FARMER".equalsIgnoreCase(user.getUserRole())) {
                    String farmName = req.getParameter("farmName");
                    String location = req.getParameter("location");
                    String pincode = req.getParameter("pincode");

                    userDAO.updateFarmerProfile(userId, name.trim(), phone != null ? phone.trim() : "",
                            farmName != null ? farmName.trim() : "",
                            location != null ? location.trim() : "",
                            pincode != null ? pincode.trim() : "");
                } else {
                    userDAO.updateCustomerProfile(userId, name.trim(), phone != null ? phone.trim() : "");
                }

                // Update session name cache
                session.setAttribute("fc_userName_" + userId, name.trim());
                session.setAttribute("profileSuccess", "Profile updated successfully!");
                resp.sendRedirect(req.getContextPath() + "/profile");

            } else if ("changePassword".equalsIgnoreCase(action)) {
                String currentPassword = req.getParameter("currentPassword");
                String newPassword = req.getParameter("newPassword");
                String confirmPassword = req.getParameter("confirmPassword");

                if (currentPassword == null || !BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
                    session.setAttribute("profileError", "Current password is incorrect.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                if (newPassword == null || newPassword.length() < 8) {
                    session.setAttribute("profileError", "New password must be at least 8 characters long.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                if (!newPassword.equals(confirmPassword)) {
                    session.setAttribute("profileError", "New passwords do not match.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    return;
                }

                String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
                userDAO.updatePassword(userId, newHash);
                session.setAttribute("profileSuccess", "Password changed successfully!");
                resp.sendRedirect(req.getContextPath() + "/profile");

            } else {
                resp.sendRedirect(req.getContextPath() + "/profile");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating profile for user " + userId, e);
            session.setAttribute("profileError", "Database error updating profile.");
            resp.sendRedirect(req.getContextPath() + "/profile");
        }
    }
}
