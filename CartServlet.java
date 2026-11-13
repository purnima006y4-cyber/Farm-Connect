package com.farmconnect.controller;

import com.farmconnect.dao.CartDAO;
import com.farmconnect.model.CartItem;
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

 
@WebServlet(urlPatterns = {"/cart", "/cart/add", "/cart/update", "/cart/remove"})
public class CartServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CartServlet.class.getName());
    private final CartDAO cartDAO = new CartDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer userId = getAuthenticatedUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<CartItem> items = cartDAO.findByUser(userId);
            BigDecimal total = BigDecimal.ZERO;
            for (CartItem ci : items) {
                total = total.add(ci.getLineTotal());
            }

            req.setAttribute("cartItems", items);
            req.setAttribute("cartTotal", total);
            req.getRequestDispatcher("/jsp/customer/cart.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Cart load error", e);
            req.setAttribute("error", "Failed to load shopping cart.");
            req.getRequestDispatcher("/jsp/customer/cart.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer userId = getAuthenticatedUserId(req);
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        try {
            switch (path) {
                case "/cart/add":
                    handleAdd(req, resp, userId);
                    break;
                case "/cart/update":
                    handleUpdate(req, resp, userId);
                    break;
                case "/cart/remove":
                    handleRemove(req, resp, userId);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/cart");
                    break;
            }
        } catch (IllegalArgumentException e) {
            // Stock violation e.g. "Only N available"
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Cart modification error", e);
            resp.sendRedirect(req.getContextPath() + "/cart");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, IOException {
        int productId = 0;
        int quantity = 1;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
            quantity = Integer.parseInt(req.getParameter("quantity"));
        } catch (Exception ignored) {}

        if (productId > 0 && quantity > 0) {
            cartDAO.addOrUpdate(userId, productId, quantity);
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, IOException {
        int productId = 0;
        int quantity = 1;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
            quantity = Integer.parseInt(req.getParameter("quantity"));
        } catch (Exception ignored) {}

        if (productId > 0 && quantity > 0) {
            cartDAO.addOrUpdate(userId, productId, quantity);
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws SQLException, IOException {
        int productId = 0;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
        } catch (Exception ignored) {}

        if (productId > 0) {
            cartDAO.remove(userId, productId);
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    /** Helper to extract authenticated customer ID from request attribute or JWT cookie */
    private Integer getAuthenticatedUserId(HttpServletRequest req) {
        Object attr = req.getAttribute("userId");
        if (attr instanceof Integer) {
            return (Integer) attr;
        }

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
}
