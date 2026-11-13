package com.farmconnect.controller;

import com.farmconnect.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;


@WebServlet("/dbtest")
public class DbTestServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DbTestServlet.class.getName());

    private static final String[] SCHEMA_TABLES = {
        "USERS", "FARMER_PROFILE", "CATEGORY", "PRODUCT",
        "ORDERS", "ORDER_ITEM", "CART_ITEM", "REVIEW", "COMPLAINT"
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String configuredUrl = DBConnection.getUrl();
        String configuredUser = DBConnection.getUsername();

        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>FarmConnect - Database Diagnostics</title>");
        out.println("<style>");
        out.println("body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 2rem; background: #f8fafc; color: #1e293b; }");
        out.println(".card { max-width: 720px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }");
        out.println(".success { color: #166534; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 1rem; border-radius: 6px; margin: 1rem 0; }");
        out.println(".error { color: #991b1b; background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 6px; margin: 1rem 0; }");
        out.println(".info-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }");
        out.println(".info-table th { text-align: left; padding: 0.5rem; background: #f1f5f9; font-size: 0.85rem; color: #475569; border-bottom: 1px solid #cbd5e1; }");
        out.println(".info-table td { padding: 0.55rem 0.5rem; border-bottom: 1px solid #e2e8f0; font-size: 0.92rem; }");
        out.println(".info-table td:first-child { font-weight: 600; color: #334155; }");
        out.println(".badge-ok { color: #166534; font-weight: bold; }");
        out.println(".badge-err { color: #dc2626; font-weight: bold; }");
        out.println(".btn { display: inline-block; padding: 0.5rem 1rem; background: #16a34a; color: white; text-decoration: none; border-radius: 4px; margin-top: 1.5rem; font-weight: 500; }");
        out.println("</style></head><body>");

        out.println("<div class='card'>");
        out.println("<h2>🌾 FarmConnect Database Diagnostics</h2>");

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Get current connected user via SELECT USER FROM DUAL
            String currentUser = "UNKNOWN";
            try (PreparedStatement ps = conn.prepareStatement("SELECT USER FROM DUAL");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentUser = rs.getString(1);
                }
            }

            // 2. Query Oracle version banner (fallback to meta if no privilege on v$version)
            String oracleVersion = "Unknown";
            try (PreparedStatement ps = conn.prepareStatement("SELECT banner FROM v$version WHERE ROWNUM = 1");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    oracleVersion = rs.getString(1);
                }
            } catch (SQLException e) {
                try {
                    oracleVersion = conn.getMetaData().getDatabaseProductVersion();
                } catch (Exception ex) {
                    oracleVersion = "Unavailable (user lacks SELECT on v$version)";
                }
            }

            // 3. Inspect each table in SCHEMA_TABLES with row counts
            Map<String, Integer> tableStatus = new LinkedHashMap<>();
            boolean allTablesExist = true;

            for (String tableName : SCHEMA_TABLES) {
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM " + tableName);
                     ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        tableStatus.put(tableName, rs.getInt(1));
                    }
                } catch (SQLException e) {
                    tableStatus.put(tableName, -1); // -1 indicates missing/inaccessible
                    allTablesExist = false;
                }
            }

            out.println("<div class='success'>");
            out.println("<strong>✓ Database Connection Successful!</strong><br>");
            out.println("Connected as <strong>" + escapeHtml(currentUser) + "</strong>");
            out.println("</div>");

            out.println("<h3>Connection Details</h3>");
            out.println("<table class='info-table'>");
            out.println("<tr><td style='width:35%'>Configured URL</td><td>" + escapeHtml(configuredUrl) + "</td></tr>");
            out.println("<tr><td>Configured Username</td><td>" + escapeHtml(configuredUser) + "</td></tr>");
            out.println("<tr><td>Connected Session User</td><td>" + escapeHtml(currentUser) + "</td></tr>");
            out.println("<tr><td>Oracle Version</td><td>" + escapeHtml(oracleVersion) + "</td></tr>");
            out.println("</table>");

            out.println("<h3 style='margin-top: 1.5rem;'>Database Schema Status (9 Tables)</h3>");
            out.println("<table class='info-table'>");
            out.println("<tr><th>Table Name</th><th>Status</th><th>Row Count</th></tr>");
            for (Map.Entry<String, Integer> entry : tableStatus.entrySet()) {
                String tbl = entry.getKey();
                int rows = entry.getValue();
                out.println("<tr>");
                out.println("<td>" + escapeHtml(tbl) + "</td>");
                if (rows >= 0) {
                    out.println("<td><span class='badge-ok'>✓ Found</span></td>");
                    out.println("<td>" + rows + " rows</td>");
                } else {
                    out.println("<td><span class='badge-err'>✗ Missing</span></td>");
                    out.println("<td>-</td>");
                }
                out.println("</tr>");
            }
            out.println("</table>");

            if (!allTablesExist) {
                out.println("<p style='margin-top: 1.25rem; color: #b45309; font-size: 0.9rem; background: #fffbeb; padding: 0.75rem; border-radius: 6px; border: 1px solid #fef3c7;'>");
                out.println("⚠️ One or more tables are missing. Please import the schema in SQL*Plus:<br>");
                out.println("<code>sqlplus " + escapeHtml(currentUser) + "/&lt;password&gt;@XE @sql/schema.sql</code><br>");
                out.println("<code>sqlplus " + escapeHtml(currentUser) + "/&lt;password&gt;@XE @sql/sample_data.sql</code>");
                out.println("</p>");
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database diagnostics failed", e);

            String diagnosticMessage = getDiagnosticMessage(e);

            out.println("<div class='error'>");
            out.println("<strong>✗ Connection Failed</strong><br>");
            out.println(escapeHtml(diagnosticMessage));
            out.println("</div>");

            out.println("<table class='info-table'>");
            out.println("<tr><td style='width:35%'>Configured URL</td><td>" + escapeHtml(configuredUrl) + "</td></tr>");
            out.println("<tr><td>Configured Username</td><td>" + escapeHtml(configuredUser) + "</td></tr>");
            out.println("<tr><td>Password Status</td><td>[PROTECTED - NOT DISPLAYED]</td></tr>");
            out.println("</table>");

            out.println("<p style='margin-top: 1.25rem; font-size: 0.85rem; color: #64748b;'>");
            out.println("Check <code>src/main/resources/db.properties</code> to update credentials and restart Tomcat.");
            out.println("</p>");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected diagnostics error", e);
            out.println("<div class='error'>");
            out.println("<strong>✗ Connection Failed:</strong> Unable to initialize database connection. Verify db.properties.");
            out.println("</div>");
        }

        out.println("<a href='" + req.getContextPath() + "/products' class='btn'>Back to FarmConnect</a>");
        out.println("</div></body></html>");
    }

    private String getDiagnosticMessage(SQLException e) {
        int errorCode = e.getErrorCode();
        String message = e.getMessage() != null ? e.getMessage() : "";

        if (message.contains("Please set real db.username and db.password")) {
            return "Configuration error: " + message;
        }

        switch (errorCode) {
            case 1017:
                return "Invalid username or password (ORA-01017). Please verify db.username and db.password in db.properties.";
            case 12505:
            case 12514:
                return "Database SID or Service Name not found (ORA-" + errorCode + "). For Oracle 10g XE, ensure the URL ends with :XE (e.g., jdbc:oracle:thin:@localhost:1521:XE).";
            case 12541:
                return "TNS listener is not running or unreachable (ORA-12541). Verify that OracleServiceXE and OracleXETnsListener services are running.";
            default:
                if (message.contains("The Network Adapter could not establish the connection")
                        || message.contains("Connection refused")) {
                    return "Database connection refused. Check that Oracle 10g XE service is running on the configured host and port.";
                }
                return "Database error (" + (errorCode != 0 ? "ORA-" + errorCode + ": " : "") + "Connection failed). Please check server logs.";
        }
    }

    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
}
