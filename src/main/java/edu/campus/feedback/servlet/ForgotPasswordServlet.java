
package edu.campus.feedback.servlet;

import edu.campus.feedback.util.AdminAuth;
import edu.campus.feedback.util.AppConfig;
import edu.campus.feedback.util.DBConnection;
import edu.campus.feedback.util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;
import java.security.NoSuchAlgorithmException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/forgot-password.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");

        String email = request.getParameter("email");

        if (email == null || email.isBlank()
                || email.length() > 254
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {

            request.setAttribute("error",
                    "Please enter a valid email address.");
            request.getRequestDispatcher("/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        email = email.trim();

        /*
         * Show the same success message whether the account exists or not,
         * so the page does not disclose registered email addresses.
         */
        String message =
                "If an administrator account matches that email, "
              + "a password reset link will be sent shortly.";

        // A fixed app.base.url (campus-feedback.properties) is safest because
        // it cannot be changed by a forged Host header.
        String baseUrl = AppConfig.get("app.base.url");

        if (baseUrl != null) {
            while (baseUrl.endsWith("/")) {
                baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
            }
        } else {
            baseUrl = request.getScheme() + "://" + request.getServerName();

            int port = request.getServerPort();

            if (("http".equalsIgnoreCase(request.getScheme()) && port != 80)
                    || ("https".equalsIgnoreCase(request.getScheme())
                        && port != 443)) {
                baseUrl += ":" + port;
            }

            baseUrl += request.getContextPath();
        }

        // Shown on the page ONLY when the request comes from the server
        // computer itself (localhost), to make local testing easy.
        String devLink = null;
        String devNote = null;
        boolean local = AdminAuth.isLoopback(request);

        try (Connection connection = DBConnection.getConnection()) {

            connection.setAutoCommit(false);

            try {
                int adminId = -1;

                String findAdmin =
                        "SELECT id FROM admin_users WHERE email = ?";

                try (PreparedStatement statement =
                             connection.prepareStatement(findAdmin)) {

                    statement.setString(1, email);

                    try (ResultSet result = statement.executeQuery()) {
                        if (result.next()) {
                            adminId = result.getInt("id");
                        }
                    }
                }

                if (adminId != -1) {

                    /*
                     * Invalidate previously issued reset links for this
                     * administrator.
                     */
                    String invalidate =
                            "UPDATE password_reset_tokens "
                          + "SET used_at = CURRENT_TIMESTAMP "
                          + "WHERE admin_id = ? AND used_at IS NULL";

                    try (PreparedStatement statement =
                                 connection.prepareStatement(invalidate)) {
                        statement.setInt(1, adminId);
                        statement.executeUpdate();
                    }

                    byte[] randomBytes = new byte[32];
                    SECURE_RANDOM.nextBytes(randomBytes);

                    String token = Base64.getUrlEncoder()
                            .withoutPadding()
                            .encodeToString(randomBytes);

                    String tokenHash = sha256(token);

                    String insert =
                            "INSERT INTO password_reset_tokens "
                          + "(admin_id, token_hash, expires_at) "
                          + "VALUES (?, ?, "
                          + "DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 15 MINUTE))";

                    try (PreparedStatement statement =
                                 connection.prepareStatement(insert)) {
                        statement.setInt(1, adminId);
                        statement.setString(2, tokenHash);
                        statement.executeUpdate();
                    }

                    connection.commit();

                    String resetUrl = baseUrl
                            + "/reset-password?token="
                            + URLEncoder.encode(
                                    token, StandardCharsets.UTF_8);

                    /*
                     * Do not expose account existence to the browser.
                     * If sending fails, invalidate the unused token.
                     */
                    try {
                        boolean emailed =
                                EmailService.sendResetLink(email, resetUrl);

                        if (!emailed && local) {
                            devLink = resetUrl;
                            devNote = "E-mail is not configured, so no "
                                    + "e-mail was sent.";
                        }
                    } catch (Exception mailException) {
                        getServletContext().log(
                                "Unable to send password reset email.",
                                mailException);

                        if (local) {
                            devLink = resetUrl;
                            devNote = "The e-mail could not be sent. "
                                    + EmailService.describeFailure(
                                            mailException);
                        } else {
                            invalidateToken(tokenHash);
                        }
                    }
                } else {
                    connection.commit();

                    if (local) {
                        devNote = "No administrator account has this "
                                + "e-mail address. Save the e-mail on the "
                                + "account first (see README).";
                    }
                }

            } catch (Exception exception) {
                try {
                    connection.rollback();
                } catch (Exception rollbackException) {
                    getServletContext().log(
                            "Password reset transaction rollback failed.",
                            rollbackException);
                }

                throw exception;
            } finally {
                try {
                    connection.setAutoCommit(true);
                } catch (Exception autoCommitException) {
                    getServletContext().log(
                            "Unable to restore database auto-commit.",
                            autoCommitException);
                }
            }

        } catch (Exception exception) {
            getServletContext().log(
                    "Password reset request failed.", exception);

            request.setAttribute("error",
                    "We could not process your request right now. "
                  + "Please try again later.");

            request.getRequestDispatcher("/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        request.setAttribute("devLink", devLink);
        request.setAttribute("devNote", devNote);
        request.setAttribute("message", message);
        request.getRequestDispatcher("/forgot-password.jsp")
               .forward(request, response);
    }

    private static String sha256(String value)
            throws NoSuchAlgorithmException {

        MessageDigest digest = MessageDigest.getInstance("SHA-256");

        byte[] hash = digest.digest(
                value.getBytes(StandardCharsets.UTF_8));

        return java.util.HexFormat.of().formatHex(hash);
    }

    private void invalidateToken(String tokenHash) {
        String sql =
                "UPDATE password_reset_tokens "
              + "SET used_at = CURRENT_TIMESTAMP "
              + "WHERE token_hash = ? AND used_at IS NULL";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(sql)) {

            statement.setString(1, tokenHash);
            statement.executeUpdate();

        } catch (Exception exception) {
            getServletContext().log(
                    "Unable to invalidate reset token.", exception);
        }
    }
}
