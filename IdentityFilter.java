package com.farmconnect.filter;

import com.farmconnect.dao.CartDAO;
import com.farmconnect.dao.OrderDAO;
import com.farmconnect.dao.UserDAO;
import com.farmconnect.model.User;
import com.farmconnect.util.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;

/**
 * Filter that runs on every request (/*) to establish user identity
 * and populate navigation request attributes without blocking or redirecting.
 */
@WebFilter(filterName = "IdentityFilter", urlPatterns = {"/*"})
public class IdentityFilter implements Filter {

    private static final Logger LOGGER = Logger.getLogger(IdentityFilter.class.getName());
    public static final String COOKIE_NAME = "auth_token";

    private final UserDAO userDAO = new UserDAO();
    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Fast skip for static design & upload resources
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        String token = extractAuthCookie(req);
        if (token != null) {
            try {
                Claims claims = JwtUtil.parseToken(token);
                int userId = JwtUtil.getUserId(claims);
                String role = JwtUtil.getRole(claims);

                req.setAttribute("userId", userId);
                req.setAttribute("role", role);

                // Efficiently retrieve & cache display name & email in session
                String userName = null;
                String userEmail = null;
                HttpSession session = req.getSession(false);
                if (session != null) {
                    userName = (String) session.getAttribute("fc_userName_" + userId);
                    userEmail = (String) session.getAttribute("fc_userEmail_" + userId);
                }
                if (userName == null || userEmail == null) {
                    try {
                        User user = userDAO.findById(userId);
                        if (user != null) {
                            userName = user.getName();
                            userEmail = user.getEmail();
                            if (session == null) {
                                session = req.getSession(true);
                            }
                            session.setAttribute("fc_userName_" + userId, userName);
                            session.setAttribute("fc_userEmail_" + userId, userEmail);
                        }
                    } catch (Exception e) {
                        LOGGER.warning("IdentityFilter: Failed to load user details: " + e.getMessage());
                    }
                }
                if (userName != null) {
                    req.setAttribute("userName", userName);
                }
                if (userEmail != null) {
                    req.setAttribute("userEmail", userEmail);
                }

                // Role-specific badges and counters
                if ("CUSTOMER".equalsIgnoreCase(role)) {
                    try {
                        int cartCount = cartDAO.findByUser(userId).size();
                        req.setAttribute("cartCount", cartCount);
                    } catch (Exception ignored) {}
                } else if ("FARMER".equalsIgnoreCase(role)) {
                    try {
                        int placedCount = orderDAO.countPlacedOrdersForFarmer(userId);
                        req.setAttribute("placedOrdersCount", placedCount);
                    } catch (Exception ignored) {}
                } else if ("ADMIN".equalsIgnoreCase(role)) {
                    try {
                        int pendingCount = userDAO.countPendingFarmers();
                        req.setAttribute("pendingApprovalsCount", pendingCount);
                    } catch (Exception ignored) {}
                }

            } catch (JwtException e) {
                LOGGER.fine("IdentityFilter: Invalid or expired token: " + e.getMessage());
                // Non-blocking; stale cookie will be cleared on logout or auth-protected filter
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isStaticResource(String path) {
        if (path.startsWith("/css/") || path.startsWith("/js/")
                || path.startsWith("/assets/") || path.startsWith("/images/")
                || path.equals("/favicon.svg") || path.equals("/favicon.ico")) {
            return true;
        }
        String lower = path.toLowerCase();
        return lower.endsWith(".css") || lower.endsWith(".js")
                || lower.endsWith(".png") || lower.endsWith(".jpg")
                || lower.endsWith(".jpeg") || lower.endsWith(".gif")
                || lower.endsWith(".svg") || lower.endsWith(".ico")
                || lower.endsWith(".woff") || lower.endsWith(".woff2");
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
