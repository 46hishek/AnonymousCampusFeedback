
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin-dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    static final int PAGE_SIZE = 10;

    /** Escapes % and _ so a search for "100%" matches the literal text. */
    static String likePattern(String text) {
        return "%" + text.replace("\\", "\\\\")
                         .replace("%", "\\%")
                         .replace("_", "\\_") + "%";
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Only logged-in admins can access the dashboard.
        if (session == null || session.getAttribute("adminUsername") == null) {
            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp"
            );
            return;
        }

        // Generate or reuse the CSRF token.
        String csrfToken = AdminAuth.csrfToken(session);

        // The dashboard shows live data, so the browser must not cache it.
        response.setHeader("Cache-Control", "no-store");

        request.setAttribute("csrfToken", csrfToken);

        String search = request.getParameter("search");
        String category = request.getParameter("category");

        if (search == null) {
            search = "";
        }

        if (category == null) {
            category = "";
        }

        search = search.trim();
        category = category.trim();

        int page = 1;
        try {
            page = Math.max(1, Integer.parseInt(
                String.valueOf(request.getParameter("page")).trim()));
        } catch (NumberFormatException e) {
            page = 1;
        }

        request.setAttribute("search", search);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("adminUsername",
            session.getAttribute("adminUsername"));

        List<FeedbackRecord> feedbackList = new ArrayList<>();
        List<CategoryStat> categoryStats = new ArrayList<>();

        // Keep all five rating levels visible, including zero counts.
        Map<Integer, Integer> ratingCounts = new LinkedHashMap<>();

        for (int rating = 1; rating <= 5; rating++) {
            ratingCounts.put(rating, 0);
        }

        int totalFeedback = 0;
        int pendingFeedback = 0;
        int reviewedFeedback = 0;
        double averageRating = 0.0;

        String statsSql = """
            SELECT
                COUNT(*) AS total,
                COALESCE(SUM(
                    CASE WHEN status = 'Pending' THEN 1 ELSE 0 END
                ), 0) AS pending,
                COALESCE(SUM(
                    CASE WHEN status = 'Reviewed' THEN 1 ELSE 0 END
                ), 0) AS reviewed,
                COALESCE(AVG(rating), 0) AS average_rating
            FROM feedback
            """;

        String categoriesSql = """
            SELECT category, COUNT(*) AS total
            FROM feedback
            GROUP BY category
            ORDER BY total DESC, category ASC
            """;

        String ratingsSql = """
            SELECT rating, COUNT(*) AS total
            FROM feedback
            GROUP BY rating
            """;

        String feedbackSql = """
            SELECT id, category, rating, comments, status, created_at
            FROM feedback
            WHERE (? = '' OR category = ?)
              AND (
                    ? = ''
                    OR category LIKE ?
                    OR comments LIKE ?
                  )
            ORDER BY created_at DESC, id DESC
            LIMIT ? OFFSET ?
            """;

        String countSql = """
            SELECT COUNT(*) AS total
            FROM feedback
            WHERE (? = '' OR category = ?)
              AND (
                    ? = ''
                    OR category LIKE ?
                    OR comments LIKE ?
                  )
            """;

        int matchingTotal = 0;
        int totalPages = 1;

        try (Connection connection = DBConnection.getConnection()) {

            // Overall dashboard statistics.
            try (PreparedStatement statement =
                     connection.prepareStatement(statsSql);
                 ResultSet result = statement.executeQuery()) {

                if (result.next()) {
                    totalFeedback = result.getInt("total");
                    pendingFeedback = result.getInt("pending");
                    reviewedFeedback = result.getInt("reviewed");
                    averageRating = result.getDouble("average_rating");
                }
            }

            // Feedback count for each category.
            try (PreparedStatement statement =
                     connection.prepareStatement(categoriesSql);
                 ResultSet result = statement.executeQuery()) {

                while (result.next()) {
                    CategoryStat stat = new CategoryStat();
                    stat.category = result.getString("category");
                    stat.count = result.getInt("total");
                    categoryStats.add(stat);
                }
            }

            // Number of feedback entries for each rating.
            try (PreparedStatement statement =
                     connection.prepareStatement(ratingsSql);
                 ResultSet result = statement.executeQuery()) {

                while (result.next()) {
                    int rating = result.getInt("rating");
                    int count = result.getInt("total");

                    if (ratingCounts.containsKey(rating)) {
                        ratingCounts.put(rating, count);
                    }
                }
            }

            String searchPattern = likePattern(search);

            // How many records match the current search and category.
            try (PreparedStatement statement =
                     connection.prepareStatement(countSql)) {

                statement.setString(1, category);
                statement.setString(2, category);
                statement.setString(3, search);
                statement.setString(4, searchPattern);
                statement.setString(5, searchPattern);

                try (ResultSet result = statement.executeQuery()) {
                    if (result.next()) {
                        matchingTotal = result.getInt("total");
                    }
                }
            }

            totalPages = Math.max(1,
                (matchingTotal + PAGE_SIZE - 1) / PAGE_SIZE);
            page = Math.min(page, totalPages);

            // One page of matching feedback for the table.
            try (PreparedStatement statement =
                     connection.prepareStatement(feedbackSql)) {

                statement.setString(1, category);
                statement.setString(2, category);
                statement.setString(3, search);
                statement.setString(4, searchPattern);
                statement.setString(5, searchPattern);
                statement.setInt(6, PAGE_SIZE);
                statement.setInt(7, (page - 1) * PAGE_SIZE);

                try (ResultSet result = statement.executeQuery()) {
                    while (result.next()) {
                        FeedbackRecord record = new FeedbackRecord();

                        record.id = result.getInt("id");
                        record.category = result.getString("category");
                        record.rating = result.getInt("rating");
                        record.comments = result.getString("comments");
                        record.status = result.getString("status");

                        Timestamp timestamp = result.getTimestamp("created_at");
                        record.createdAt = timestamp == null
                            ? ""
                            : timestamp.toString();

                        feedbackList.add(record);
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load admin dashboard data.", e
            );
        }

        request.setAttribute("totalFeedback", totalFeedback);
        request.setAttribute("pendingFeedback", pendingFeedback);
        request.setAttribute("reviewedFeedback", reviewedFeedback);
        request.setAttribute("averageRating", averageRating);

        request.setAttribute("categoryStats", categoryStats);
        request.setAttribute("ratingCounts", ratingCounts);
        request.setAttribute("feedbackList", feedbackList);
        request.setAttribute("matchingTotal", matchingTotal);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);

        request.getRequestDispatcher("/admin-dashboard.jsp")
               .forward(request, response);
    }

    public static class CategoryStat {
        public String category;
        public int count;
    }

    public static class FeedbackRecord {
        public int id;
        public String category;
        public int rating;
        public String comments;
        public String status;
        public String createdAt;
    }
}
