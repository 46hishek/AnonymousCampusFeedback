
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/** Marks feedback as Reviewed, or sets it back to Pending. */
@WebServlet("/update-feedback-status")
public class UpdateFeedbackStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String dashboardUrl = AdminAuth.dashboardUrl(request);

        if (!AdminAuth.isLoggedIn(request)) {
            response.sendRedirect(
                    request.getContextPath() + "/admin-login.jsp");
            return;
        }

        if (!AdminAuth.csrfValid(request)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid security token. Refresh the dashboard and try again.");
            return;
        }

        int feedbackId;

        try {
            feedbackId = Integer.parseInt(
                    request.getParameter("feedbackId"));

            if (feedbackId <= 0) {
                response.sendRedirect(dashboardUrl);
                return;
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(dashboardUrl);
            return;
        }

        // Only these two values are allowed. Missing = "Reviewed" so older
        // forms keep working.
        String newStatus = request.getParameter("status");

        if (newStatus == null || newStatus.isBlank()) {
            newStatus = "Reviewed";
        }

        if (!"Reviewed".equals(newStatus) && !"Pending".equals(newStatus)) {
            response.sendRedirect(dashboardUrl);
            return;
        }

        String sql = "UPDATE feedback SET status = ? WHERE id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, newStatus);
            statement.setInt(2, feedbackId);
            statement.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to update feedback status.", e);
        }

        response.sendRedirect(dashboardUrl);
    }
}
