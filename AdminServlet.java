package com.farmconnect.controller;

import com.farmconnect.dao.*;
import com.farmconnect.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet(urlPatterns = {
        "/admin/dashboard",
        "/admin/farmers",
        "/admin/categories",
        "/admin/products",
        "/admin/orders",
        "/admin/complaints",
        "/admin/users",
        "/admin/reports"
})
public class AdminServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/dashboard":
                    showDashboard(req, resp);
                    break;
                case "/admin/farmers":
                    showFarmers(req, resp);
                    break;
                case "/admin/categories":
                    showCategories(req, resp);
                    break;
                case "/admin/products":
                    showProducts(req, resp);
                    break;
                case "/admin/orders":
                    showOrders(req, resp);
                    break;
                case "/admin/complaints":
                    showComplaints(req, resp);
                    break;
                case "/admin/users":
                    showUsers(req, resp);
                    break;
                case "/admin/reports":
                    showReports(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin GET error", e);
            req.setAttribute("error", "Database error occurred.");
            req.getRequestDispatcher("/jsp/admin/dashboard.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/admin/farmers":
                    handleFarmerAction(req, resp);
                    break;
                case "/admin/categories":
                    handleCategoryAction(req, resp);
                    break;
                case "/admin/complaints":
                    handleComplaintAction(req, resp);
                    break;
                case "/admin/users":
                    handleUserAction(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Admin POST error", e);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("farmerCount", userDAO.countByRole("FARMER"));
        req.setAttribute("customerCount", userDAO.countByRole("CUSTOMER"));
        req.setAttribute("pendingCount", userDAO.countPendingFarmers());
        req.setAttribute("totalOrders", orderDAO.countAll());
        req.setAttribute("totalRevenue", orderDAO.totalRevenue());
        req.setAttribute("recentOrders", orderDAO.findAll(1, 10));
        req.getRequestDispatcher("/jsp/admin/dashboard.jsp").forward(req, resp);
    }

    private void showFarmers(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("farmers", userDAO.findAllFarmerProfiles());
        req.getRequestDispatcher("/jsp/admin/farmers.jsp").forward(req, resp);
    }

    private void showCategories(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("categories", categoryDAO.findAll());
        req.getRequestDispatcher("/jsp/admin/categories.jsp").forward(req, resp);
    }

    private void showProducts(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        req.setAttribute("products", productDAO.findAll(page, 20));
        req.setAttribute("page", page);
        req.getRequestDispatcher("/jsp/admin/products.jsp").forward(req, resp);
    }

    private void showOrders(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        req.setAttribute("orders", orderDAO.findAll(page, 20));
        req.setAttribute("page", page);
        req.getRequestDispatcher("/jsp/admin/orders.jsp").forward(req, resp);
    }

    private void showComplaints(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("complaints", complaintDAO.findAll());
        req.getRequestDispatcher("/jsp/admin/complaints.jsp").forward(req, resp);
    }

    private void showUsers(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("customers", userDAO.findByRole("CUSTOMER"));
        req.getRequestDispatcher("/jsp/admin/users.jsp").forward(req, resp);
    }

    private void showReports(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("monthlySales", orderDAO.getMonthlySalesReport());
        req.setAttribute("topProducts", productDAO.getTopProducts(10));
        req.getRequestDispatcher("/jsp/admin/reports.jsp").forward(req, resp);
    }

    private void handleFarmerAction(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String action = req.getParameter("action");
        int userId = 0;
        try { userId = Integer.parseInt(req.getParameter("userId")); } catch (Exception ignored) {}

        if (userId > 0) {
            if ("approve".equalsIgnoreCase(action)) {
                userDAO.approveFarmer(userId);
            } else if ("reject".equalsIgnoreCase(action) || "block".equalsIgnoreCase(action)) {
                userDAO.updateStatus(userId, "BLOCKED");
            } else if ("unblock".equalsIgnoreCase(action)) {
                userDAO.updateStatus(userId, "ACTIVE");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/farmers");
    }

    private void handleCategoryAction(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException, ServletException {
        String action = req.getParameter("action");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        name = name != null ? name.trim() : "";
        description = description != null ? description.trim() : "";

        if ("add".equalsIgnoreCase(action)) {
            if (name.isEmpty()) {
                req.setAttribute("error", "Category name is required.");
                showCategories(req, resp);
                return;
            }
            categoryDAO.insert(name, description);
        } else if ("delete".equalsIgnoreCase(action)) {
            int categoryId = 0;
            try { categoryId = Integer.parseInt(req.getParameter("categoryId")); } catch (Exception ignored) {}
            if (categoryId > 0) {
                try {
                    categoryDAO.delete(categoryId);
                } catch (SQLException e) {
                    req.setAttribute("error", "Cannot delete category that is referenced by existing products.");
                    showCategories(req, resp);
                    return;
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    private void handleComplaintAction(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String action = req.getParameter("action");
        int complaintId = 0;
        try { complaintId = Integer.parseInt(req.getParameter("complaintId")); } catch (Exception ignored) {}

        if (complaintId > 0) {
            if ("resolve".equalsIgnoreCase(action)) {
                complaintDAO.updateStatus(complaintId, "RESOLVED");
            } else if ("close".equalsIgnoreCase(action)) {
                complaintDAO.updateStatus(complaintId, "CLOSED");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/complaints");
    }

    private void handleUserAction(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        String action = req.getParameter("action");
        int userId = 0;
        try { userId = Integer.parseInt(req.getParameter("userId")); } catch (Exception ignored) {}

        if (userId > 0) {
            if ("block".equalsIgnoreCase(action)) {
                userDAO.updateStatus(userId, "BLOCKED");
            } else if ("unblock".equalsIgnoreCase(action)) {
                userDAO.updateStatus(userId, "ACTIVE");
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
