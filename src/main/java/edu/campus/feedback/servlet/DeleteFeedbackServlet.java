
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

/** Permanently deletes one feedback entry (spam or inappropriate content). */
@WebServlet("/delete-feedback")
public class DeleteFeedbackServlet extends HttpServlet {

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
        } catch (NumberFormatException e) {
            response.sendRedirect(dashboardUrl);
            return;
        }

        if (feedbackId <= 0) {
            response.sendRedirect(dashboardUrl);
            return;
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "DELETE FROM feedback WHERE id = ?")) {

            statement.setInt(1, feedbackId);
            statement.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("Unable to delete feedback.", e);
        }

        response.sendRedirect(dashboardUrl);
    }
}
