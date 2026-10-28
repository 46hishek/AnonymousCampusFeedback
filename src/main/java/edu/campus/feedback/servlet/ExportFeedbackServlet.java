
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;

/** Downloads the feedback matching the dashboard filters as a CSV file. */
@WebServlet("/export-feedback")
public class ExportFeedbackServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        if (!AdminAuth.isLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/admin-login.jsp");
            return;
        }

        String search = request.getParameter("search");
        String category = request.getParameter("category");
        search = search == null ? "" : search.trim();
        category = category == null ? "" : category.trim();

        String sql = """
            SELECT id, category, rating, comments, status, created_at
            FROM feedback
            WHERE (? = '' OR category = ?)
              AND (
                    ? = ''
                    OR category LIKE ?
                    OR comments LIKE ?
                  )
            ORDER BY created_at DESC, id DESC
            """;

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"campus-feedback-"
            + LocalDate.now() + ".csv\"");

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            String pattern = AdminDashboardServlet.likePattern(search);

            statement.setString(1, category);
            statement.setString(2, category);
            statement.setString(3, search);
            statement.setString(4, pattern);
            statement.setString(5, pattern);

            PrintWriter out = response.getWriter();

            // Byte-order mark so Excel opens the file as UTF-8.
            out.print('﻿');
            out.print("ID,Category,Rating,Comments,Status,Date Submitted\r\n");

            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    Timestamp created = result.getTimestamp("created_at");

                    out.print(result.getInt("id"));
                    out.print(',');
                    out.print(csv(result.getString("category")));
                    out.print(',');
                    out.print(result.getInt("rating"));
                    out.print(',');
                    out.print(csv(result.getString("comments")));
                    out.print(',');
                    out.print(csv(result.getString("status")));
                    out.print(',');
                    out.print(csv(created == null ? "" : created.toString()));
                    out.print("\r\n");
                }
            }

            out.flush();

        } catch (SQLException e) {
            throw new ServletException("Unable to export feedback.", e);
        }
    }

    /**
     * Quotes a CSV value. Values starting with = + - @ get a leading
     * apostrophe so Excel cannot run them as formulas.
     */
    static String csv(String value) {
        if (value == null) {
            return "";
        }

        String text = value.replace("\r", " ").replace("\n", " ");

        if (!text.isEmpty() && "=+-@\t".indexOf(text.charAt(0)) >= 0) {
            text = "'" + text;
        }

        return "\"" + text.replace("\"", "\"\"") + "\"";
    }
}
