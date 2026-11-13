package com.farmconnect.filter;

import com.farmconnect.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Filter that protects /farmer/*, /customer/*, and /admin/* URL patterns.
 * 
 * Responsibilities:
 * 1. Reads the JWT from the "auth_token" HttpOnly cookie.
 * 2. Verifies the token signature and expiry via JwtUtil.
 * 3. Enforces Role-Based Access Control (RBAC):
 *    - /farmer/*   requires FARMER role
 *    - /customer/* requires CUSTOMER role
 *    - /admin/*    requires ADMIN role
 * 4. Missing/invalid/expired token -> redirects to /login.
 * 5. Wrong role -> HTTP 403 Forbidden.
 * 6. Attaches userId and role as request attributes for downstream servlets.
 */
@WebFilter(urlPatterns = {"/farmer/*", "/customer/*", "/admin/*"})
public class AuthFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(AuthFilter.class.getName());
    public static final String COOKIE_NAME = "auth_token";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String token = extractAuthCookie(req);
        if (token == null) {
            LOGGER.fine("AuthFilter: No auth token found, redirecting to login");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Claims claims;
        try {
            claims = JwtUtil.parseToken(token);
        } catch (JwtException e) {
            LOGGER.fine("AuthFilter: Invalid or expired token: " + e.getMessage());
            // Expire stale cookie
            Cookie expiredCookie = new Cookie(COOKIE_NAME, "");
            expiredCookie.setPath("/");
            expiredCookie.setMaxAge(0);
            resp.addCookie(expiredCookie);

            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = JwtUtil.getUserId(claims);
        String role = JwtUtil.getRole(claims);

        String requestURI = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = requestURI.substring(contextPath.length());

        // Check role against URL prefix
        if (path.startsWith("/farmer/") && !"FARMER".equalsIgnoreCase(role)) {
            LOGGER.warning("Access denied: User " + userId + " with role " + role + " attempted to access " + path);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Farmer role required.");
            return;
        }

        if (path.startsWith("/customer/") && !"CUSTOMER".equalsIgnoreCase(role)) {
            LOGGER.warning("Access denied: User " + userId + " with role " + role + " attempted to access " + path);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Customer role required.");
            return;
        }

        if (path.startsWith("/admin/") && !"ADMIN".equalsIgnoreCase(role)) {
            LOGGER.warning("Access denied: User " + userId + " with role " + role + " attempted to access " + path);
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Admin role required.");
            return;
        }

        // Put authenticated identity into request attributes
        req.setAttribute("userId", userId);
        req.setAttribute("role", role);

        chain.doFilter(request, response);
    }

    private String extractAuthCookie(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) {
            return null;
        }
        for (Cookie c : cookies) {
            if (COOKIE_NAME.equals(c.getName()) || "jwt".equals(c.getName())) {
                return c.getValue();
            }
        }
        return null;
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}
