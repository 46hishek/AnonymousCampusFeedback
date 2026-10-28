
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * One-time page to create the FIRST administrator.
 *
 * It only works while the admin_users table is empty AND the request comes
 * from the same computer as the server (localhost). After the first admin
 * exists the page answers 404.
 */
@WebServlet("/admin-setup")
public class AdminSetupServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private boolean setupAllowed(HttpServletRequest request)
            throws SQLException {

        if (!AdminAuth.isLoopback(request)) {
            return false;
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                 "SELECT COUNT(*) FROM admin_users");
             ResultSet result = statement.executeQuery()) {

            return result.next() && result.getInt(1) == 0;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try {
            if (!setupAllowed(request)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException(
                "Could not check the administrator table. "
                + "Is MySQL running and database/schema.sql imported?", e);
        }

        response.setHeader("Cache-Control", "no-store");
        request.setAttribute("csrfToken",
            AdminAuth.csrfToken(request.getSession(true)));
        request.getRequestDispatcher("/admin-setup.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        try {
            if (!setupAllowed(request)) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        } catch (SQLException e) {
            throw new ServletException(
                "Could not check the administrator table.", e);
        }

        HttpSession session = request.getSession(true);

        if (!AdminAuth.csrfValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Invalid security token. Reload the page and try again.");
            return;
        }

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        String error = null;

        if (!username.matches("[A-Za-z0-9_]{4,50}")) {
            error = "Username must be 4-50 characters: letters, numbers "
                  + "or underscore.";
        } else if (email.length() > 254
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            error = "Please enter a valid e-mail address.";
        } else if (password == null || password.length() < 12
                || password.length() > 72) {
            error = "Password must be between 12 and 72 characters.";
        } else if (!password.equals(confirm)) {
            error = "The two passwords do not match.";
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("username", username);
            request.setAttribute("email", email);
            request.setAttribute("csrfToken", AdminAuth.csrfToken(session));
            request.getRequestDispatcher("/admin-setup.jsp")
                   .forward(request, response);
            return;
        }

        String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(12));

        // Inserts only when no administrator exists yet (race-safe).
        String sql = """
            INSERT INTO admin_users (username, email, password_hash)
            SELECT ?, ?, ? FROM DUAL
            WHERE NOT EXISTS (SELECT 1 FROM admin_users)
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.setString(2, email);
            statement.setString(3, passwordHash);

            if (statement.executeUpdate() != 1) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to create the administrator account.", e);
        }

        session.invalidate();
        response.sendRedirect(
            request.getContextPath() + "/admin-login.jsp?setup=1");
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
