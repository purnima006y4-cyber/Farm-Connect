package com.farmconnect.controller;

import com.farmconnect.dao.CategoryDAO;
import com.farmconnect.dao.ProductDAO;
import com.farmconnect.dao.ReviewDAO;
import com.farmconnect.model.Product;
import com.farmconnect.util.FileUploadUtil;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
 
@WebServlet(urlPatterns = {
        "/products",
        "/product",
        "/farmer/products",
        "/farmer/products/add",
        "/farmer/products/edit",
        "/farmer/products/delete",
        "/images/*"
})
public class ProductServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(ProductServlet.class.getName());

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        // Serve uploaded images safely
        if ("/images".equals(path) || path.startsWith("/images/")) {
            serveImage(req, resp);
            return;
        }

        try {
            switch (path) {
                case "/products":
                    handleBrowse(req, resp);
                    break;
                case "/product":
                    handleProductDetail(req, resp);
                    break;
                case "/farmer/products":
                    handleFarmerProductList(req, resp);
                    break;
                case "/farmer/products/add":
                    handleFarmerShowAdd(req, resp);
                    break;
                case "/farmer/products/edit":
                    handleFarmerShowEdit(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "ProductServlet GET error on path: " + path, e);
            req.setAttribute("error", "Database error occurred.");
            req.getRequestDispatcher("/jsp/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/farmer/products/add":
                    handleFarmerAddProduct(req, resp);
                    break;
                case "/farmer/products/edit":
                    handleFarmerEditProduct(req, resp);
                    break;
                case "/farmer/products/delete":
                    handleFarmerDeleteProduct(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "ProductServlet POST error", e);
            resp.sendRedirect(req.getContextPath() + "/farmer/products");
        }
    }

    private void handleBrowse(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        String query = req.getParameter("name");
        if (query == null || query.trim().isEmpty()) {
            query = req.getParameter("search");
        }
        String categoryStr = req.getParameter("category");
        String season = req.getParameter("season");
        String location = req.getParameter("location");
        String pincode = req.getParameter("pincode");
        boolean verifiedOnly = "true".equalsIgnoreCase(req.getParameter("verifiedOnly"));
        String sort = req.getParameter("sort");
        String minPriceStr = req.getParameter("minPrice");
        String maxPriceStr = req.getParameter("maxPrice");

        int page = 1;
        try {
            page = Integer.parseInt(req.getParameter("page"));
        } catch (Exception ignored) {}

        Integer categoryId = null;
        try {
            if (categoryStr != null && !categoryStr.trim().isEmpty()) {
                categoryId = Integer.parseInt(categoryStr.trim());
            }
        } catch (Exception ignored) {}

        BigDecimal minPrice = null;
        try {
            if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
                minPrice = new BigDecimal(minPriceStr.trim());
            }
        } catch (Exception ignored) {}

        BigDecimal maxPrice = null;
        try {
            if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
                maxPrice = new BigDecimal(maxPriceStr.trim());
            }
        } catch (Exception ignored) {}

        List<Product> products = productDAO.search(query, categoryId, season, location, pincode, verifiedOnly, sort, minPrice, maxPrice, page, 12);
        req.setAttribute("products", products);
        req.setAttribute("categories", categoryDAO.findAll());
        req.setAttribute("page", page);
        req.setAttribute("nameQuery", query != null ? query : "");
        req.setAttribute("selectedCategory", categoryId);
        req.setAttribute("selectedSeason", season != null ? season : "");
        req.setAttribute("selectedLocation", location != null ? location : "");
        req.setAttribute("selectedPincode", pincode != null ? pincode : "");
        req.setAttribute("verifiedOnly", verifiedOnly);
        req.setAttribute("selectedSort", sort != null ? sort : "");
        req.setAttribute("minPrice", minPriceStr != null ? minPriceStr : "");
        req.setAttribute("maxPrice", maxPriceStr != null ? maxPriceStr : "");

        req.getRequestDispatcher("/jsp/customer/home.jsp").forward(req, resp);
    }

    private void handleProductDetail(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        int id = 0;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (Exception ignored) {}

        if (id <= 0) {
            resp.sendRedirect(req.getContextPath() + "/products");
            return;
        }

        Product product = productDAO.findById(id);
        if (product == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Product not found");
            return;
        }

        req.setAttribute("product", product);
        req.setAttribute("reviews", reviewDAO.findByProduct(id));
        req.getRequestDispatcher("/jsp/customer/product-details.jsp").forward(req, resp);
    }

    private void handleFarmerProductList(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        int farmerId = (int) req.getAttribute("userId");
        req.setAttribute("products", productDAO.findByFarmer(farmerId));
        req.setAttribute("lowStock", productDAO.findLowStock(farmerId, 10));
        req.getRequestDispatcher("/jsp/farmer/my-products.jsp").forward(req, resp);
    }

    private void handleFarmerShowAdd(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        req.setAttribute("categories", categoryDAO.findAll());
        req.getRequestDispatcher("/jsp/farmer/add-product.jsp").forward(req, resp);
    }

    private void handleFarmerShowEdit(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {
        int farmerId = (int) req.getAttribute("userId");
        int productId = 0;
        try {
            productId = Integer.parseInt(req.getParameter("id"));
        } catch (Exception ignored) {}

        Product product = productDAO.findById(productId);
        // Server-side ownership check
        if (product == null || product.getFarmerId() != farmerId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized: Not your product.");
            return;
        }

        req.setAttribute("product", product);
        req.setAttribute("categories", categoryDAO.findAll());
        req.getRequestDispatcher("/jsp/farmer/edit-product.jsp").forward(req, resp);
    }

    private void handleFarmerAddProduct(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int farmerId = (int) req.getAttribute("userId");

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> items = upload.parseRequest(req);

        String name = "";
        int categoryId = 0;
        BigDecimal price = BigDecimal.ZERO;
        int quantity = 0;
        Date harvestDate = null;
        String season = "ALL";
        String imagePath = null;

        for (FileItem item : items) {
            if (item.isFormField()) {
                switch (item.getFieldName()) {
                    case "name":
                        name = item.getString("UTF-8").trim();
                        break;
                    case "categoryId":
                        try { categoryId = Integer.parseInt(item.getString()); } catch (Exception ignored) {}
                        break;
                    case "price":
                        try { price = new BigDecimal(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "quantity":
                        try { quantity = Integer.parseInt(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "harvestDate":
                        try { harvestDate = Date.valueOf(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "season":
                        season = item.getString("UTF-8").trim();
                        break;
                }
            } else if ("image".equals(item.getFieldName()) && item.getSize() > 0) {
                imagePath = FileUploadUtil.saveImage(item);
            }
        }

        if (name.isEmpty() || price.compareTo(BigDecimal.ZERO) <= 0 || quantity < 0) {
            req.setAttribute("error", "Invalid product details. Price must be > 0 and Quantity >= 0.");
            handleFarmerShowAdd(req, resp);
            return;
        }

        productDAO.insert(farmerId, categoryId, name, price, quantity, harvestDate, imagePath, season);
        resp.sendRedirect(req.getContextPath() + "/farmer/products");
    }

    private void handleFarmerEditProduct(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        int farmerId = (int) req.getAttribute("userId");

        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> items = upload.parseRequest(req);

        int productId = 0;
        String name = "";
        int categoryId = 0;
        BigDecimal price = BigDecimal.ZERO;
        int quantity = 0;
        Date harvestDate = null;
        String season = "ALL";
        String imagePath = null;
        String existingImage = null;

        for (FileItem item : items) {
            if (item.isFormField()) {
                switch (item.getFieldName()) {
                    case "productId":
                        try { productId = Integer.parseInt(item.getString()); } catch (Exception ignored) {}
                        break;
                    case "name":
                        name = item.getString("UTF-8").trim();
                        break;
                    case "categoryId":
                        try { categoryId = Integer.parseInt(item.getString()); } catch (Exception ignored) {}
                        break;
                    case "price":
                        try { price = new BigDecimal(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "quantity":
                        try { quantity = Integer.parseInt(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "harvestDate":
                        try { harvestDate = Date.valueOf(item.getString().trim()); } catch (Exception ignored) {}
                        break;
                    case "season":
                        season = item.getString("UTF-8").trim();
                        break;
                    case "existingImage":
                        existingImage = item.getString("UTF-8").trim();
                        break;
                }
            } else if ("image".equals(item.getFieldName()) && item.getSize() > 0) {
                imagePath = FileUploadUtil.saveImage(item);
            }
        }

        if (imagePath == null || imagePath.isEmpty()) {
            imagePath = existingImage;
        }

        // Server-side ownership check: productDAO.update enforces WHERE product_id=? AND farmer_id=?
        productDAO.update(productId, farmerId, categoryId, name, price, quantity, harvestDate, imagePath, season);
        resp.sendRedirect(req.getContextPath() + "/farmer/products");
    }

    private void handleFarmerDeleteProduct(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, IOException {
        int farmerId = (int) req.getAttribute("userId");
        int productId = 0;
        try {
            productId = Integer.parseInt(req.getParameter("productId"));
        } catch (Exception ignored) {}

        if (productId > 0) {
            productDAO.delete(productId, farmerId);
        }
        resp.sendRedirect(req.getContextPath() + "/farmer/products");
    }

    private void serveImage(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String filename = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
        // Security: Prevent directory traversal
        if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        File file = new File(FileUploadUtil.getUploadDir(), filename);
        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mimeType = req.getServletContext().getMimeType(file.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        resp.setContentType(mimeType);
        resp.setContentLengthLong(file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
