package com.farmconnect.controller;

import com.farmconnect.dao.ProductDAO;
import com.farmconnect.dao.UserDAO;
import com.farmconnect.model.FarmerProfile;
import com.farmconnect.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet("/farmer-profile")
public class FarmerProfileServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(FarmerProfileServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        int farmerUserId = 0;
        try {
            if (idParam != null && !idParam.trim().isEmpty()) {
                farmerUserId = Integer.parseInt(idParam.trim());
            }
        } catch (NumberFormatException ignored) {}

        if (farmerUserId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        try {
            FarmerProfile profile = userDAO.findFarmerProfileByUserId(farmerUserId);
            if (profile == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Farmer profile not found.");
                return;
            }

            List<Product> products = productDAO.findAvailableByFarmer(farmerUserId);
            double avgRating = productDAO.getAverageRatingForFarmer(farmerUserId);

            req.setAttribute("farmerProfile", profile);
            req.setAttribute("products", products);
            req.setAttribute("avgRating", avgRating);
            req.setAttribute("totalProducts", products.size());

            req.getRequestDispatcher("/jsp/customer/farmer-public-profile.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading public farmer profile for userId " + farmerUserId, e);
            req.setAttribute("error", "Database error loading farmer profile.");
            req.getRequestDispatcher("/jsp/common/error.jsp").forward(req, resp);
        }
    }
}
