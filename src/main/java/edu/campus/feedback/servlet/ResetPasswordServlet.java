
package edu.campus.feedback.servlet;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HexFormat;

import org.mindrot.jbcrypt.BCrypt;

import edu.campus.feedback.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private String hashToken(String token)
            throws NoSuchAlgorithmException {

        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(
                token.getBytes(StandardCharsets.UTF_8));

        return HexFormat.of().formatHex(hash);
    }

    private boolean isTokenValid(String token)
            throws SQLException, NoSuchAlgorithmException {

        if (token == null || token.isBlank() || token.length() > 200) {
            return false;
        }

        String sql = """
                SELECT id
                FROM password_reset_tokens
                WHERE token_hash = ?
                  AND used_at IS NULL
                  AND expires_at > CURRENT_TIMESTAMP
                """;

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashToken(token));

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");

        try {
            if (!isTokenValid(token)) {
                request.setAttribute("errorMessage",
                        "This reset link is invalid or has expired.");
                request.getRequestDispatcher("/reset-password.jsp")
                        .forward(request, response);
                return;
            }

            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp")
                    .forward(request, response);

        } catch (SQLException | NoSuchAlgorithmException e) {
            throw new ServletException(
                    "Unable to validate the password reset link.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || token.isBlank() || token.length() > 200) {
            request.setAttribute("errorMessage",
                    "This reset link is invalid or has expired.");
            request.getRequestDispatcher("/reset-password.jsp")
                    .forward(request, response);
            return;
        }

        if (password == null || confirmPassword == null
                || password.length() < 12
                || password.length() > 72
                || !password.equals(confirmPassword)) {

            request.setAttribute("errorMessage",
                    "Passwords must match and contain 12 to 72 characters.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/reset-password.jsp")
                    .forward(request, response);
            return;
        }

        Connection con = null;

        try {
            String tokenHash = hashToken(token);

            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int adminId;

            String selectSql = """
                    SELECT admin_id
                    FROM password_reset_tokens
                    WHERE token_hash = ?
                      AND used_at IS NULL
                      AND expires_at > CURRENT_TIMESTAMP
                    FOR UPDATE
                    """;

            try (PreparedStatement ps = con.prepareStatement(selectSql)) {
                ps.setString(1, tokenHash);

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();

                        request.setAttribute("errorMessage",
                                "This reset link is invalid or has expired.");
                        request.getRequestDispatcher("/reset-password.jsp")
                                .forward(request, response);
                        return;
                    }

                    adminId = rs.getInt("admin_id");
                }
            }

            String newPasswordHash =
                    BCrypt.hashpw(password, BCrypt.gensalt(12));

            String updateSql = """
                    UPDATE admin_users
                    SET password_hash = ?
                    WHERE id = ?
                    """;

            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setString(1, newPasswordHash);
                ps.setInt(2, adminId);

                if (ps.executeUpdate() != 1) {
                    con.rollback();
                    throw new SQLException("Admin password could not be updated.");
                }
            }

            String consumeSql = """
                    UPDATE password_reset_tokens
                    SET used_at = CURRENT_TIMESTAMP
                    WHERE token_hash = ?
                      AND used_at IS NULL
                    """;

            try (PreparedStatement ps = con.prepareStatement(consumeSql)) {
                ps.setString(1, tokenHash);

                if (ps.executeUpdate() != 1) {
                    con.rollback();

                    request.setAttribute("errorMessage",
                            "This reset link is invalid or has expired.");
                    request.getRequestDispatcher("/reset-password.jsp")
                            .forward(request, response);
                    return;
                }
            }

            con.commit();

            response.sendRedirect(
                    request.getContextPath()
                    + "/admin-login.jsp?passwordReset=1");

        } catch (SQLException | NoSuchAlgorithmException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }

            throw new ServletException(
                    "Unable to reset the administrator password.", e);

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {
                    // Connection cleanup.
                }
            }
        }
    }
}
