
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
import jakarta.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/admin-login")
public class AdminLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** Failed sign-ins allowed per address in 15 minutes (in memory only). */
    private static final RateLimiter FAILED_LOGINS = new RateLimiter(
        AppConfig.getInt("login.rate.limit", 5), 15L * 60 * 1000);

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String clientKey = AdminAuth.clientKey(request);

        if (FAILED_LOGINS.isBlocked(clientKey)) {
            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp?error=2"
            );
            return;
        }

        if (username == null || password == null
                || username.isBlank() || password.isEmpty()) {
            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp?error=1"
            );
            return;
        }

        String sql = """
            SELECT id, username, password_hash
            FROM admin_users
            WHERE username = ?
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, username.trim());

            try (ResultSet result = statement.executeQuery()) {

                if (result.next()) {
                    String storedHash =
                        result.getString("password_hash");

                    if (storedHash != null
                            && BCrypt.checkpw(password, storedHash)) {

                        FAILED_LOGINS.clear(clientKey);

                        HttpSession oldSession = request.getSession(false);

                        if (oldSession != null) {
                            oldSession.invalidate();
                        }

                        HttpSession session = request.getSession(true);
                        request.changeSessionId();

                        session.setAttribute(
                            "adminUsername",
                            result.getString("username")
                        );

                        session.setMaxInactiveInterval(15 * 60);
                        AdminAuth.csrfToken(session);

                        response.sendRedirect(
                            request.getContextPath()
                                + "/admin-dashboard"
                        );
                        return;
                    }
                }
            }

            FAILED_LOGINS.record(clientKey);

            response.sendRedirect(
                request.getContextPath() + "/admin-login.jsp?error=1"
            );

        } catch (SQLException e) {
            throw new ServletException(
                "Admin login could not be processed.", e
            );
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath() + "/admin-login.jsp"
        );
    }
}
