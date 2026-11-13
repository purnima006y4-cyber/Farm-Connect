package com.farmconnect.controller;

import com.farmconnect.dao.UserDAO;
import com.farmconnect.model.User;
import com.farmconnect.util.JwtUtil;
import com.farmconnect.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

 
@WebServlet(urlPatterns = {"/login", "/register", "/logout"})
public class AuthServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AuthServlet.class.getName());
    public static final String COOKIE_NAME = "auth_token";

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/logout".equals(path)) {
            handleLogout(req, resp);
            return;
        }

        // Redirect already logged-in users to their role homepage
        Object roleAttr = req.getAttribute("role");
        if (roleAttr != null) {
            String role = roleAttr.toString();
            if ("ADMIN".equalsIgnoreCase(role)) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                return;
            } else if ("FARMER".equalsIgnoreCase(role)) {
                resp.sendRedirect(req.getContextPath() + "/farmer/dashboard");
                return;
            } else {
                resp.sendRedirect(req.getContextPath() + "/products");
                return;
            }
        }

        if ("/register".equals(path)) {
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
        } else {
            String msg = req.getParameter("msg");
            if ("logged_out".equals(msg)) {
                req.setAttribute("message", "You have been logged out successfully.");
            }
            req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/register".equals(path)) {
            handleRegister(req, resp);
        } else {
            handleLogin(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
            return;
        }

        email = email.trim();

        try {
            User user = userDAO.findByEmail(email);

            // Generic error message for both non-existent user and bad password to prevent user enumeration
            if (user == null || !PasswordUtil.verify(password, user.getPasswordHash())) {
                req.setAttribute("error", "Invalid credentials.");
                req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
                return;
            }

            // Check account status
            if ("PENDING".equalsIgnoreCase(user.getStatus())) {
                req.setAttribute("error", "Your account is pending admin approval.");
                req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
                return;
            }
            if ("BLOCKED".equalsIgnoreCase(user.getStatus())) {
                req.setAttribute("error", "Your account has been blocked. Please contact admin.");
                req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
                return;
            }

            // Issue JWT token with 1-hour expiration
            String token = JwtUtil.generateToken(user.getUserId(), user.getUserRole());

            // Build cookie with HttpOnly, SameSite=Strict, Path=/, MaxAge=3600
            Cookie cookie = new Cookie(COOKIE_NAME, token);
            cookie.setHttpOnly(true);
            cookie.setPath("/");
            cookie.setMaxAge(3600);
            if (req.isSecure()) {
                cookie.setSecure(true);
            }
            resp.addCookie(cookie);

            // SameSite=Strict attribute via header
            String cookieHeader = String.format("%s=%s; HttpOnly; SameSite=Strict; Path=/; Max-Age=3600%s",
                    COOKIE_NAME, token, req.isSecure() ? "; Secure" : "");
            resp.addHeader("Set-Cookie", cookieHeader);

            // Role-based Post-Redirect-Get
            switch (user.getUserRole().toUpperCase()) {
                case "ADMIN":
                    resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    break;
                case "FARMER":
                    resp.sendRedirect(req.getContextPath() + "/farmer/dashboard");
                    break;
                case "CUSTOMER":
                default:
                    resp.sendRedirect(req.getContextPath() + "/products");
                    break;
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Login database error", e);
            req.setAttribute("error", "Database connection problem. Please contact admin.");
            req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected login error", e);
            req.setAttribute("error", "Database connection problem. Please contact admin.");
            req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");
        String role = req.getParameter("role");

        name = name != null ? name.trim() : "";
        email = email != null ? email.trim() : "";
        phone = phone != null ? phone.trim() : "";
        role = role != null ? role.trim().toUpperCase() : "CUSTOMER";

        // Server-side validation
        if (name.isEmpty() || email.isEmpty() || password == null || password.length() < 8) {
            req.setAttribute("error", "All fields are required and password must be at least 8 characters.");
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
            return;
        }

        if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            req.setAttribute("error", "Please provide a valid email address.");
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
            return;
        }

        if (!"FARMER".equals(role) && !"CUSTOMER".equals(role)) {
            req.setAttribute("error", "Invalid user role specified.");
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
            return;
        }

        try {
            if (userDAO.emailExists(email)) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
                return;
            }

            // Hash password with BCrypt cost factor 12
            String hash = PasswordUtil.hash(password);

            if ("FARMER".equals(role)) {
                String farmName = req.getParameter("farmName");
                String location = req.getParameter("location");
                String pincode = req.getParameter("pincode");

                farmName = farmName != null ? farmName.trim() : "";
                location = location != null ? location.trim() : "";
                pincode = pincode != null ? pincode.trim() : "";

                if (farmName.isEmpty()) {
                    req.setAttribute("error", "Farm name is required for farmer registration.");
                    req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
                    return;
                }

                userDAO.registerFarmer(name, email, hash, phone, farmName, location, pincode);
                req.setAttribute("message", "Registration submitted! Your farmer account is PENDING admin approval.");
            } else {
                userDAO.registerCustomer(name, email, hash, phone);
                req.setAttribute("message", "Registration successful! You can now log in.");
            }

            req.getRequestDispatcher("/jsp/common/login.jsp").forward(req, resp);

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Registration database error", e);
            if (e.getErrorCode() == 1 || (e.getMessage() != null && e.getMessage().contains("ORA-00001"))) {
                req.setAttribute("error", "Email already registered.");
            } else {
                req.setAttribute("error", "Database connection problem. Please contact admin.");
            }
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected registration error", e);
            req.setAttribute("error", "Database connection problem. Please contact admin.");
            req.getRequestDispatcher("/jsp/common/register.jsp").forward(req, resp);
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Cookie cookie = new Cookie(COOKIE_NAME, "");
        cookie.setPath("/");
        cookie.setMaxAge(0);
        cookie.setHttpOnly(true);
        resp.addCookie(cookie);

        Cookie jwtCookie = new Cookie("jwt", "");
        jwtCookie.setPath("/");
        jwtCookie.setMaxAge(0);
        jwtCookie.setHttpOnly(true);
        resp.addCookie(jwtCookie);

        String cookieHeader = String.format("%s=; HttpOnly; SameSite=Strict; Path=/; Max-Age=0%s",
                COOKIE_NAME, req.isSecure() ? "; Secure" : "");
        resp.addHeader("Set-Cookie", cookieHeader);

        javax.servlet.http.HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        resp.sendRedirect(req.getContextPath() + "/login?msg=logged_out");
    }
}
