package edu.campus.feedback.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.UUID;

/** Helpers shared by the admin servlets: login check, CSRF, redirects. */
public final class AdminAuth {

    private AdminAuth() {
    }

    public static boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("adminUsername") != null;
    }

    /** Returns the session CSRF token, creating it when needed. */
    public static String csrfToken(HttpSession session) {
        String token = (String) session.getAttribute("csrfToken");
        if (token == null) {
            token = UUID.randomUUID().toString();
            session.setAttribute("csrfToken", token);
        }
        return token;
    }

    public static boolean csrfValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        return sessionToken != null && requestToken != null
            && MessageDigest.isEqual(
                sessionToken.getBytes(StandardCharsets.UTF_8),
                requestToken.getBytes(StandardCharsets.UTF_8));
    }

    /** Dashboard URL that keeps the current search, category and page. */
    public static String dashboardUrl(HttpServletRequest request) {
        StringBuilder url = new StringBuilder(request.getContextPath())
            .append("/admin-dashboard");

        String search = trim(request.getParameter("search"));
        String category = trim(request.getParameter("category"));
        String page = trim(request.getParameter("page"));

        char separator = '?';
        if (!search.isEmpty()) {
            url.append(separator).append("search=").append(encode(search));
            separator = '&';
        }
        if (!category.isEmpty()) {
            url.append(separator).append("category=").append(encode(category));
            separator = '&';
        }
        if (page.matches("\\d{1,6}")) {
            url.append(separator).append("page=").append(page);
        }
        return url.append("#feedback").toString();
    }

    /** Address used only for in-memory rate limiting. */
    public static String clientKey(HttpServletRequest request) {
        return request.getRemoteAddr();
    }

    public static boolean isLoopback(HttpServletRequest request) {
        String addr = request.getRemoteAddr();
        return "127.0.0.1".equals(addr)
            || "::1".equals(addr)
            || "0:0:0:0:0:0:0:1".equals(addr);
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
