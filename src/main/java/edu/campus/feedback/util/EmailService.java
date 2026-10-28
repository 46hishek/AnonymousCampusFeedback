package edu.campus.feedback.util;

import jakarta.mail.AuthenticationFailedException;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.net.ConnectException;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Sends e-mail through any SMTP provider (Gmail by default).
 * Settings live in campus-feedback.properties:
 * mail.username, mail.app.password, mail.smtp.host, mail.smtp.port, mail.from
 */
public final class EmailService {

    private EmailService() {
        // Utility class
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }

    private static String username() {
        String value = AppConfig.get("mail.username");
        return value != null ? value
            : blankToNull(System.getenv("CAMPUS_MAIL_USERNAME"));
    }

    /**
     * Google shows app passwords as "abcd efgh ijkl mnop". The spaces are not
     * part of the password, so all whitespace is removed.
     */
    private static String password() {
        String value = AppConfig.get("mail.app.password");
        if (value == null) {
            value = blankToNull(System.getenv("CAMPUS_MAIL_APP_PASSWORD"));
        }
        return value == null ? null : value.replaceAll("\\s+", "");
    }

    /** True when a mail account is configured. */
    public static boolean isConfigured() {
        return username() != null && password() != null;
    }

    private static Session createSession(String username, String password) {
        String port = AppConfig.get("mail.smtp.port", "587");

        Properties properties = new Properties();
        properties.put("mail.smtp.host",
            AppConfig.get("mail.smtp.host", "smtp.gmail.com"));
        properties.put("mail.smtp.port", port);
        properties.put("mail.smtp.auth", "true");

        if ("465".equals(port)) {
            // Implicit TLS
            properties.put("mail.smtp.ssl.enable", "true");
        } else {
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.starttls.required", "true");
        }

        properties.put("mail.smtp.connectiontimeout", "15000");
        properties.put("mail.smtp.timeout", "15000");
        properties.put("mail.smtp.writetimeout", "15000");

        return Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    private static void send(String recipientEmail, String subject,
                             String html) throws MessagingException {

        String username = username();
        String password = password();

        Session session = createSession(username, password);
        MimeMessage message = new MimeMessage(session);

        message.setFrom(new InternetAddress(
            AppConfig.get("mail.from", username)));
        message.setRecipients(
            Message.RecipientType.TO,
            InternetAddress.parse(recipientEmail, true)
        );
        message.setSubject(subject, StandardCharsets.UTF_8.name());
        message.setContent(html, "text/html; charset=UTF-8");

        Transport.send(message);
    }

    /** Returns true when an e-mail was sent, false when only logged (dev mode). */
    public static boolean sendResetLink(String recipientEmail, String resetUrl)
            throws MessagingException {

        if (recipientEmail == null || recipientEmail.isBlank()
                || resetUrl == null || resetUrl.isBlank()) {
            throw new IllegalArgumentException(
                "Recipient email and reset URL are required."
            );
        }

        if (!isConfigured()) {
            if (AppConfig.getBoolean("mail.dev.logLink", true)) {
                // Development fallback: no mail account configured.
                System.out.println(
                    "[Campus Voice - DEV] E-mail is not configured. "
                    + "Password reset link for " + recipientEmail + ":");
                System.out.println("[Campus Voice - DEV] " + resetUrl);
                return false;
            }
            throw new IllegalStateException(
                "E-mail is not configured. Set mail.username and "
                + "mail.app.password in campus-feedback.properties."
            );
        }

        // Escape HTML special characters in the URL
        String safeUrl = resetUrl
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

        String html = """
            <!DOCTYPE html>
            <html lang="en">
            <body style="font-family:Arial,sans-serif;color:#1e293b;
                         line-height:1.6;max-width:560px;margin:auto;padding:24px;">
                <h2 style="color:#4338ca;">Campus Voice</h2>
                <h3>Reset your administrator password</h3>

                <p>We received a request to reset your administrator password.</p>

                <p>This link expires in <strong>15 minutes</strong>
                   and can be used only once.</p>

                <p style="margin:28px 0;">
                    <a href="%s"
                       style="background:#4f46e5;color:#ffffff;
                              padding:13px 20px;text-decoration:none;
                              border-radius:8px;display:inline-block;">
                        Reset Password
                    </a>
                </p>

                <p>If the button does not work, open this link in your browser:</p>
                <p style="overflow-wrap:anywhere;">%s</p>

                <p>If you did not request this reset, ignore this email.</p>

                <hr style="border:0;border-top:1px solid #e2e8f0;">

                <p style="font-size:12px;color:#64748b;">
                    Campus Voice — Anonymous Campus Feedback System
                </p>
            </body>
            </html>
            """.formatted(safeUrl, safeUrl);

        send(recipientEmail, "Reset your Campus Voice admin password", html);
        return true;
    }

    /** Sends a short test message (used by MailTest). */
    public static void sendTest(String recipientEmail)
            throws MessagingException {
        if (!isConfigured()) {
            throw new IllegalStateException(
                "mail.username and mail.app.password are not set.");
        }
        send(recipientEmail, "Campus Voice test e-mail",
            "<p>Success! Campus Voice can send e-mail with these settings.</p>");
    }

    /** Plain-English explanation of why sending failed. */
    public static String describeFailure(Throwable error) {
        Throwable cause = error;
        while (cause != null) {
            if (cause instanceof AuthenticationFailedException) {
                return "The mail server rejected the username or password. "
                    + "For Gmail you must use a 16-letter App Password "
                    + "(Google Account > Security > 2-Step Verification > "
                    + "App passwords), not your normal password. "
                    + "Check mail.username and mail.app.password in "
                    + "campus-feedback.properties, and remove old Windows "
                    + "variables CAMPUS_MAIL_USERNAME / CAMPUS_MAIL_APP_PASSWORD.";
            }
            if (cause instanceof UnknownHostException) {
                return "The mail server could not be found. Check your "
                    + "internet connection and mail.smtp.host.";
            }
            if (cause instanceof ConnectException
                    || cause instanceof SocketTimeoutException) {
                return "Could not connect to the mail server. A firewall or "
                    + "antivirus may be blocking port " 
                    + AppConfig.get("mail.smtp.port", "587") + ".";
            }
            cause = cause.getCause();
        }
        return error.getClass().getSimpleName() + ": " + error.getMessage();
    }
}
