
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.AppConfig;
import edu.campus.feedback.util.DBConnection;
import edu.campus.feedback.util.RateLimiter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/submit-feedback")
public class FeedbackServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * Limits spam. The address is kept only in memory for 10 minutes and is
     * never stored, so feedback stays anonymous.
     */
    private static final RateLimiter SUBMISSIONS = new RateLimiter(
        AppConfig.getInt("feedback.rate.limit", 10), 10L * 60 * 1000);

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String clientKey = AdminAuth.clientKey(request);

        if (SUBMISSIONS.isBlocked(clientKey)) {
            response.sendError(
                429,
                "Too many submissions. Please try again in a few minutes."
            );
            return;
        }

        String category = request.getParameter("category");
        String ratingValue = request.getParameter("rating");
        String comments = request.getParameter("comments");

        if (category == null || ratingValue == null
                || comments == null
                || category.isBlank()
                || comments.isBlank()) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Please complete all feedback fields."
            );
            return;
        }

        int rating;

        try {
            rating = Integer.parseInt(ratingValue);
        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid rating."
            );
            return;
        }

        if (rating < 1 || rating > 5
                || comments.length() > 2000
                || !category.matches(
                    "Teaching|Infrastructure|Library|Cleanliness|Other")) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid feedback details."
            );
            return;
        }

        String sql = """
            INSERT INTO feedback (category, rating, comments)
            VALUES (?, ?, ?)
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, category);
            statement.setInt(2, rating);
            statement.setString(3, comments.trim());

            statement.executeUpdate();
            SUBMISSIONS.record(clientKey);

            response.sendRedirect(
                request.getContextPath() + "/index.jsp?submitted=1"
            );

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to save feedback.", e
            );
        }
    }
}
