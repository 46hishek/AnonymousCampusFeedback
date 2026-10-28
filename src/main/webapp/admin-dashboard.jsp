
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Locale" %>
<%@ page import="org.owasp.encoder.Encode" %>
<%@ page import="edu.campus.feedback.servlet.AdminDashboardServlet.CategoryStat" %>
<%@ page import="edu.campus.feedback.servlet.AdminDashboardServlet.FeedbackRecord" %>

<%
    List<CategoryStat> categoryStats =
        (List<CategoryStat>) request.getAttribute("categoryStats");

    List<FeedbackRecord> feedbackList =
        (List<FeedbackRecord>) request.getAttribute("feedbackList");

    Map<Integer, Integer> ratingCounts =
        (Map<Integer, Integer>) request.getAttribute("ratingCounts");

    int totalFeedback =
        request.getAttribute("totalFeedback") == null ? 0
        : (Integer) request.getAttribute("totalFeedback");

    int pendingFeedback =
        request.getAttribute("pendingFeedback") == null ? 0
        : (Integer) request.getAttribute("pendingFeedback");

    int reviewedFeedback =
        request.getAttribute("reviewedFeedback") == null ? 0
        : (Integer) request.getAttribute("reviewedFeedback");

    double averageRating =
        request.getAttribute("averageRating") == null ? 0.0
        : (Double) request.getAttribute("averageRating");

    String search = (String) request.getAttribute("search");
    String selectedCategory =
        (String) request.getAttribute("selectedCategory");

    String csrfToken = (String) session.getAttribute("csrfToken");
    String adminUsername = (String) session.getAttribute("adminUsername");

    if (search == null) search = "";
    if (selectedCategory == null) selectedCategory = "";

    int maxCategoryCount = 1;
    if (categoryStats != null) {
        for (CategoryStat stat : categoryStats) {
            if (stat.count > maxCategoryCount) {
                maxCategoryCount = stat.count;
            }
        }
    }

    int maxRatingCount = 1;
    if (ratingCounts != null) {
        for (Integer count : ratingCounts.values()) {
            if (count != null && count > maxRatingCount) {
                maxRatingCount = count;
            }
        }
    }

    String averageRatingText =
        String.format(Locale.US, "%.1f", averageRating);

    int matchingTotal =
        request.getAttribute("matchingTotal") == null ? 0
        : (Integer) request.getAttribute("matchingTotal");
    int currentPage =
        request.getAttribute("currentPage") == null ? 1
        : (Integer) request.getAttribute("currentPage");
    int totalPages =
        request.getAttribute("totalPages") == null ? 1
        : (Integer) request.getAttribute("totalPages");
    int pageSize =
        request.getAttribute("pageSize") == null ? 10
        : (Integer) request.getAttribute("pageSize");

    // Query string that keeps the current search and category in links.
    String filterQuery =
        "search=" + java.net.URLEncoder.encode(search,
            java.nio.charset.StandardCharsets.UTF_8)
        + "&category=" + java.net.URLEncoder.encode(selectedCategory,
            java.nio.charset.StandardCharsets.UTF_8);

    // Hidden fields sent with every row action (security token + current view).
    String stateFields =
        "<input type=\"hidden\" name=\"csrfToken\" value=\""
        + Encode.forHtmlAttribute(csrfToken == null ? "" : csrfToken) + "\">"
        + "<input type=\"hidden\" name=\"search\" value=\""
        + Encode.forHtmlAttribute(search) + "\">"
        + "<input type=\"hidden\" name=\"category\" value=\""
        + Encode.forHtmlAttribute(selectedCategory) + "\">"
        + "<input type=\"hidden\" name=\"page\" value=\""
        + currentPage + "\">";

    int firstShown = matchingTotal == 0 ? 0
        : (currentPage - 1) * pageSize + 1;
    int lastShown = Math.min(matchingTotal, currentPage * pageSize);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Campus Voice</title>

    <style>
        :root {
            --navy: #101a35;
            --navy-light: #1c2a4d;
            --primary: #4f46e5;
            --primary-light: #eef2ff;
            --bg: #f5f7fb;
            --white: #ffffff;
            --text: #1e293b;
            --muted: #64748b;
            --border: #e5eaf2;
            --green: #15803d;
            --green-bg: #dcfce7;
            --orange: #c2410c;
            --orange-bg: #ffedd5;
            --red: #b91c1c;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Inter, "Segoe UI", Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        a {
            text-decoration: none;
        }

        button, input, select {
            font: inherit;
        }

        .app {
            min-height: 100vh;
            display: flex;
        }

        .sidebar {
            width: 245px;
            flex-shrink: 0;
            background: var(--navy);
            color: white;
            padding: 28px 18px;
            display: flex;
            flex-direction: column;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 0 10px 32px;
        }

        .brand-icon {
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            border-radius: 13px;
            background: #4f46e5;
            font-size: 22px;
            font-weight: 800;
        }

        .brand-name {
            font-size: 18px;
            font-weight: 800;
        }

        .brand-subtitle {
            color: #aab7d2;
            font-size: 11px;
            margin-top: 4px;
        }

        .nav-label {
            color: #91a0bf;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            margin: 12px 12px 10px;
        }

        .nav-link {
            display: flex;
            gap: 12px;
            align-items: center;
            padding: 13px 14px;
            margin-bottom: 7px;
            border-radius: 10px;
            color: #d5deef;
            font-size: 14px;
            font-weight: 600;
        }

        .nav-link.active,
        .nav-link:hover {
            background: #28375c;
            color: white;
        }

        .nav-icon {
            width: 22px;
            text-align: center;
        }

        .sidebar-bottom {
            margin-top: auto;
            padding: 20px 10px 0;
            border-top: 1px solid #2a3858;
        }

        .admin-name {
            font-size: 13px;
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        .admin-role {
            margin-top: 5px;
            color: #aab7d2;
            font-size: 12px;
        }

        .logout-link {
            display: inline-block;
            color: #fca5a5;
            margin-top: 16px;
            font-size: 13px;
            font-weight: 700;
        }

        .main {
            flex: 1;
            min-width: 0;
            padding: 30px;
        }

        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 27px;
        }

        .eyebrow {
            color: var(--primary);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        h1 {
            margin: 0;
            font-size: clamp(25px, 3vw, 32px);
            letter-spacing: -1px;
        }

        .subtitle {
            color: var(--muted);
            font-size: 14px;
            margin-top: 9px;
            line-height: 1.5;
        }

        .live-indicator {
            background: white;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 12px 15px;
            font-size: 12px;
            color: var(--muted);
            white-space: nowrap;
        }

        .live-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #22c55e;
            margin-right: 7px;
        }

        .section-title {
            font-size: 17px;
            font-weight: 800;
            margin: 0 0 15px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
            margin-bottom: 28px;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 22px;
            min-width: 0;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.025);
        }

        .stat-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
        }

        .stat-label {
            color: var(--muted);
            font-size: 13px;
            font-weight: 600;
        }

        .stat-icon {
            width: 38px;
            height: 38px;
            display: grid;
            place-items: center;
            border-radius: 11px;
            background: var(--primary-light);
            color: var(--primary);
            font-size: 19px;
            flex-shrink: 0;
        }

        .stat-number {
            font-size: clamp(25px, 3vw, 33px);
            font-weight: 800;
            letter-spacing: -1px;
            margin-top: 17px;
            overflow-wrap: anywhere;
        }

        .stat-foot {
            color: var(--muted);
            font-size: 12px;
            margin-top: 8px;
        }

        .analytics-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
            gap: 20px;
            margin-bottom: 28px;
        }

        .panel {
            background: white;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            min-width: 0;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.025);
        }

        .panel-heading {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 24px;
        }

        .panel-title {
            margin: 0;
            font-size: 16px;
            font-weight: 800;
        }

        .panel-description {
            color: var(--muted);
            font-size: 12px;
            line-height: 1.5;
            margin-top: 7px;
        }

        .average-display {
            text-align: right;
            flex-shrink: 0;
        }

        .average-number {
            font-size: 29px;
            font-weight: 800;
            color: var(--primary);
        }

        .average-stars {
            color: #f59e0b;
            letter-spacing: 1px;
            font-size: 14px;
        }

        .bar-row {
            margin-bottom: 20px;
        }

        .bar-label-row {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            font-size: 12px;
            margin-bottom: 9px;
        }

        .bar-label {
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        .bar-count {
            color: var(--muted);
            white-space: nowrap;
        }

        .bar-track {
            height: 9px;
            background: #eef1f7;
            border-radius: 20px;
            overflow: hidden;
        }

        .bar-fill {
            height: 100%;
            min-width: 0;
            background: linear-gradient(90deg, #4f46e5, #818cf8);
            border-radius: 20px;
            transition: width 0.3s ease;
        }

        .rating-row {
            display: grid;
            grid-template-columns: 42px minmax(0, 1fr) 32px;
            gap: 12px;
            align-items: center;
            margin-bottom: 18px;
        }

        .rating-label {
            color: #b77908;
            font-weight: 800;
            font-size: 13px;
        }

        .rating-track {
            height: 10px;
            background: #f1f3f8;
            border-radius: 20px;
            overflow: hidden;
        }

        .rating-fill {
            height: 100%;
            background: linear-gradient(90deg, #f59e0b, #fbbf24);
            border-radius: 20px;
        }

        .rating-count {
            text-align: right;
            font-size: 12px;
            font-weight: 700;
        }

        .empty-chart {
            padding: 20px 0;
            text-align: center;
            color: var(--muted);
            font-size: 13px;
        }

        .table-panel {
            padding: 0;
            overflow: hidden;
        }

        .table-header {
            padding: 23px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
            border-bottom: 1px solid var(--border);
        }

        .table-header .section-title {
            margin: 0;
        }

        .table-count {
            color: var(--muted);
            font-size: 12px;
            margin-top: 6px;
        }

        .filters {
            display: flex;
            gap: 9px;
            flex-wrap: wrap;
        }

        .filter-input,
        .filter-select {
            min-height: 40px;
            border: 1px solid #dbe2ed;
            border-radius: 9px;
            background: white;
            padding: 9px 12px;
            color: var(--text);
            font-size: 12px;
            max-width: 100%;
        }

        .filter-input {
            width: 200px;
        }

        .filter-select {
            min-width: 135px;
        }

        .filter-button {
            min-height: 40px;
            border: 0;
            border-radius: 9px;
            padding: 0 16px;
            background: var(--primary);
            color: white;
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
        }

        .filter-button:hover {
            background: #4338ca;
        }

        .table-scroll {
            overflow-x: auto;
        }

        table {
            width: 100%;
            min-width: 930px;
            border-collapse: collapse;
        }

        thead {
            background: #f8fafc;
        }

        th {
            text-align: left;
            color: #64748b;
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            padding: 15px 18px;
            white-space: nowrap;
        }

        td {
            padding: 17px 18px;
            border-top: 1px solid #edf0f5;
            vertical-align: top;
            font-size: 12px;
            line-height: 1.6;
        }

        tbody tr:hover {
            background: #fafbff;
        }

        .feedback-id {
            color: #64748b;
            font-weight: 800;
        }

        .category-tag {
            display: inline-block;
            padding: 5px 9px;
            background: #eef2ff;
            color: #4338ca;
            border-radius: 7px;
            font-size: 11px;
            font-weight: 700;
        }

        .comment-cell {
            max-width: 270px;
            overflow-wrap: anywhere;
            white-space: pre-wrap;
        }

        .stars {
            color: #f59e0b;
            white-space: nowrap;
            font-size: 14px;
        }

        .rating-value {
            color: #475569;
            font-size: 11px;
            margin-left: 4px;
        }

        .status {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }

        .status-pending {
            background: var(--orange-bg);
            color: var(--orange);
        }

        .status-reviewed {
            background: var(--green-bg);
            color: var(--green);
        }

        .review-btn {
            border: 0;
            border-radius: 8px;
            padding: 9px 11px;
            background: var(--primary-light);
            color: var(--primary);
            font-size: 11px;
            font-weight: 800;
            cursor: pointer;
            white-space: nowrap;
        }

        .review-btn:hover {
            background: #dfe5ff;
        }

        .action-row {
            display: flex;
            align-items: center;
            gap: 7px;
            flex-wrap: wrap;
        }

        .action-row form {
            margin: 0;
        }

        .reopen-btn,
        .delete-btn {
            border: 0;
            border-radius: 8px;
            padding: 9px 11px;
            font-size: 11px;
            font-weight: 800;
            cursor: pointer;
            white-space: nowrap;
        }

        .reopen-btn {
            background: var(--orange-bg);
            color: var(--orange);
        }

        .reopen-btn:hover {
            background: #ffe8c2;
        }

        .delete-btn {
            background: #fff1f2;
            color: #be123c;
        }

        .delete-btn:hover {
            background: #ffe0e4;
        }

        .export-link {
            display: inline-flex;
            align-items: center;
            min-height: 40px;
            padding: 0 14px;
            border: 1px solid #dbe2ed;
            border-radius: 9px;
            background: white;
            color: var(--primary);
            font-size: 12px;
            font-weight: 700;
            text-decoration: none;
        }

        .export-link:hover {
            background: var(--primary-light);
        }

        .pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            padding: 16px 24px;
            border-top: 1px solid var(--border);
            color: var(--muted);
            font-size: 12px;
        }

        .page-links {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .page-link {
            min-width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0 10px;
            border: 1px solid #dbe2ed;
            border-radius: 8px;
            background: white;
            color: var(--text);
            font-weight: 700;
            text-decoration: none;
        }

        .page-link:hover {
            background: var(--primary-light);
        }

        .page-link.current {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }

        .page-link.disabled {
            opacity: .45;
            pointer-events: none;
        }

        .reviewed-label {
            color: var(--green);
            font-size: 11px;
            font-weight: 800;
        }

        .empty-table {
            text-align: center;
            padding: 45px 20px;
            color: var(--muted);
        }

        .empty-table strong {
            display: block;
            color: var(--text);
            margin-bottom: 6px;
            font-size: 14px;
        }

        .footer {
            text-align: center;
            color: #94a3b8;
            font-size: 11px;
            padding: 25px 0 5px;
        }

        @media (max-width: 1100px) {
            .sidebar {
                width: 210px;
            }

            .main {
                padding: 23px;
            }

            .stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .analytics-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 680px) {
            .app {
                display: block;
            }

            .sidebar {
                width: 100%;
                padding: 15px;
            }

            .brand {
                padding: 0 5px 14px;
            }

            .nav-label {
                display: none;
            }

            .nav-links {
                display: flex;
                gap: 8px;
            }

            .nav-link {
                flex: 1;
                justify-content: center;
                padding: 11px 8px;
                margin: 0;
                font-size: 12px;
            }

            .sidebar-bottom {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                padding: 13px 5px 0;
                margin-top: 14px;
            }

            .logout-link {
                margin-top: 0;
                white-space: nowrap;
            }

            .main {
                padding: 19px 13px;
            }

            .topbar {
                align-items: flex-start;
                flex-direction: column;
                margin-bottom: 22px;
            }

            .live-indicator {
                white-space: normal;
            }

            .stats-grid {
                gap: 10px;
            }

            .stat-card {
                padding: 15px;
                border-radius: 13px;
            }

            .stat-icon {
                width: 31px;
                height: 31px;
                font-size: 16px;
            }

            .stat-number {
                font-size: 26px;
            }

            .panel {
                padding: 18px;
            }

            .table-header {
                padding: 18px;
            }

            .filters {
                width: 100%;
            }

            .filter-input {
                flex: 1;
                width: 100%;
                min-width: 0;
            }

            .filter-select {
                flex: 1;
                min-width: 0;
            }

            .filter-button {
                flex: 1;
            }
        }

        @media (max-width: 390px) {
            .nav-link {
                font-size: 11px;
                gap: 5px;
            }

            .stat-label {
                font-size: 11px;
            }

            .stat-number {
                font-size: 23px;
            }

            .average-number {
                font-size: 24px;
            }
        }
    </style>
</head>

<body>
<div class="app">

    <aside class="sidebar">
        <div class="brand">
            <div class="brand-icon">C</div>
            <div>
                <div class="brand-name">Campus Voice</div>
                <div class="brand-subtitle">FEEDBACK MANAGEMENT</div>
            </div>
        </div>

        <div class="nav-label">WORKSPACE</div>

        <nav class="nav-links">
            <a class="nav-link active"
               href="<%= request.getContextPath() %>/admin-dashboard">
                <span class="nav-icon">&#9632;</span>
                Overview
            </a>

            <a class="nav-link"
               href="<%= request.getContextPath() %>/admin-dashboard#feedback">
                <span class="nav-icon">&#9776;</span>
                Feedback Records
            </a>
        </nav>

        <div class="sidebar-bottom">
            <div>
                <div class="admin-name">
                    <%= Encode.forHtml(adminUsername == null
                        ? "Administrator" : adminUsername) %>
                </div>
                <div class="admin-role">System Administrator</div>
            </div>

            <a class="logout-link"
               href="<%= request.getContextPath() %>/admin-logout">
                Sign out &#8594;
            </a>
        </div>
    </aside>

    <main class="main">

        <header class="topbar">
            <div>
                <div class="eyebrow">ADMINISTRATION</div>
                <h1>Dashboard Overview</h1>
                <div class="subtitle">
                    Monitor campus feedback, ratings and review progress.
                </div>
            </div>

            <div class="live-indicator">
                <span class="live-dot"></span>
                Live database statistics
            </div>
        </header>

        <section>
            <h2 class="section-title">Feedback Summary</h2>

            <div class="stats-grid">

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-label">Total Feedback</div>
                        <div class="stat-icon">&#9776;</div>
                    </div>
                    <div class="stat-number"><%= totalFeedback %></div>
                    <div class="stat-foot">All submitted responses</div>
                </div>

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-label">Pending Review</div>
                        <div class="stat-icon">&#9203;</div>
                    </div>
                    <div class="stat-number"><%= pendingFeedback %></div>
                    <div class="stat-foot">Awaiting administrator review</div>
                </div>

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-label">Reviewed</div>
                        <div class="stat-icon">&#10003;</div>
                    </div>
                    <div class="stat-number"><%= reviewedFeedback %></div>
                    <div class="stat-foot">Feedback marked as reviewed</div>
                </div>

                <div class="stat-card">
                    <div class="stat-top">
                        <div class="stat-label">Average Rating</div>
                        <div class="stat-icon">&#9733;</div>
                    </div>
                    <div class="stat-number">
                        <%= averageRatingText %><span style="font-size:15px;color:#64748b;"> / 5</span>
                    </div>
                    <div class="stat-foot">Average of submitted ratings</div>
                </div>

            </div>
        </section>

        <section>
            <h2 class="section-title">Feedback Analytics</h2>

            <div class="analytics-grid">

                <div class="panel">
                    <div class="panel-heading">
                        <div>
                            <h3 class="panel-title">Category Breakdown</h3>
                            <div class="panel-description">
                                Number of responses in each category
                            </div>
                        </div>
                    </div>

                    <% if (categoryStats == null || categoryStats.isEmpty()) { %>
                        <div class="empty-chart">
                            No feedback data available yet.
                        </div>
                    <% } else {
                        for (CategoryStat stat : categoryStats) {
                            int percentage = (int) Math.round(
                                stat.count * 100.0 / maxCategoryCount
                            );
                    %>
                        <div class="bar-row">
                            <div class="bar-label-row">
                                <span class="bar-label">
                                    <%= Encode.forHtml(stat.category == null
                                        ? "Uncategorized" : stat.category) %>
                                </span>
                                <span class="bar-count">
                                    <%= stat.count %>
                                    <%= stat.count == 1 ? "response" : "responses" %>
                                </span>
                            </div>

                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width:<%= percentage %>%;">
                                </div>
                            </div>
                        </div>
                    <%  }
                       } %>
                </div>

                <div class="panel">
                    <div class="panel-heading">
                        <div>
                            <h3 class="panel-title">Rating Distribution</h3>
                            <div class="panel-description">
                                How students rated their campus experience
                            </div>
                        </div>

                        <div class="average-display">
                            <div class="average-number">
                                <%= averageRatingText %>
                            </div>
                            <div class="average-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</div>
                        </div>
                    </div>

                    <% for (int rating = 5; rating >= 1; rating--) {
                        int count = ratingCounts == null
                            || ratingCounts.get(rating) == null
                            ? 0 : ratingCounts.get(rating);

                        int percentage = (int) Math.round(
                            count * 100.0 / maxRatingCount
                        );
                    %>
                        <div class="rating-row">
                            <div class="rating-label">
                                <%= rating %> &#9733;
                            </div>

                            <div class="rating-track">
                                <div class="rating-fill"
                                     style="width:<%= percentage %>%;">
                                </div>
                            </div>

                            <div class="rating-count"><%= count %></div>
                        </div>
                    <% } %>

                    <div class="panel-description">
                        Bars are scaled to the largest rating count.
                    </div>
                </div>

            </div>
        </section>

        <section id="feedback" class="panel table-panel">
            <div class="table-header">
                <div>
                    <h2 class="section-title">Feedback Records</h2>
                    <div class="table-count">
                        <%= matchingTotal %>
                        matching record(s)
                    </div>
                </div>

                <form class="filters" method="get"
                      action="<%= request.getContextPath() %>/admin-dashboard">

                    <input class="filter-input"
                           type="search"
                           name="search"
                           placeholder="Search feedback..."
                           value="<%= Encode.forHtmlAttribute(search) %>">

                    <select class="filter-select" name="category">
                        <option value="">All categories</option>

                        <% if (categoryStats != null) {
                            for (CategoryStat stat : categoryStats) {
                                String categoryName = stat.category == null
                                    ? "" : stat.category;
                        %>
                            <option value="<%= Encode.forHtmlAttribute(categoryName) %>"
                                <%= categoryName.equals(selectedCategory)
                                    ? "selected" : "" %>>
                                <%= Encode.forHtml(categoryName) %>
                            </option>
                        <%  }
                           } %>
                    </select>

                    <button class="filter-button" type="submit">
                        Search
                    </button>

                    <a class="export-link"
                       href="<%= request.getContextPath() %>/export-feedback?<%= Encode.forHtmlAttribute(filterQuery) %>">
                        Export CSV
                    </a>
                </form>
            </div>

            <div class="table-scroll">
                <table>
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Category</th>
                        <th>Rating</th>
                        <th>Comments</th>
                        <th>Date Submitted</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% if (feedbackList == null || feedbackList.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="empty-table">
                                <strong>No feedback found</strong>
                                Try changing the search term or category filter.
                            </td>
                        </tr>
                    <% } else {
                        for (FeedbackRecord item : feedbackList) {
                            String status = item.status == null
                                ? "Unknown" : item.status;
                    %>
                        <tr>
                            <td class="feedback-id">#<%= item.id %></td>

                            <td>
                                <span class="category-tag">
                                    <%= Encode.forHtml(item.category == null
                                        ? "Uncategorized" : item.category) %>
                                </span>
                            </td>

                            <td>
                                <span class="stars">
                                    <%= "★".repeat(Math.max(0,
                                        Math.min(5, item.rating))) %>
                                    <%= "☆".repeat(Math.max(0,
                                        5 - Math.max(0, Math.min(5, item.rating)))) %>
                                </span>
                                <span class="rating-value">
                                    <%= item.rating %>/5
                                </span>
                            </td>

                            <td class="comment-cell">
                                <%= Encode.forHtml(item.comments == null
                                    ? "" : item.comments) %>
                            </td>

                            <td>
                                <%= Encode.forHtml(item.createdAt == null
                                    ? "" : item.createdAt) %>
                            </td>

                            <td>
                                <% if ("Pending".equals(status)) { %>
                                    <span class="status status-pending">
                                        Pending
                                    </span>
                                <% } else if ("Reviewed".equals(status)) { %>
                                    <span class="status status-reviewed">
                                        Reviewed
                                    </span>
                                <% } else { %>
                                    <span class="status">
                                        <%= Encode.forHtml(status) %>
                                    </span>
                                <% } %>
                            </td>

                            <td>
                                <div class="action-row">
                                <% if ("Pending".equals(status)) { %>
                                    <form method="post"
                                          action="<%= request.getContextPath() %>/update-feedback-status"
                                          onsubmit="return confirm('Mark this feedback as reviewed?');">
                                        <%= stateFields %>
                                        <input type="hidden"
                                               name="feedbackId"
                                               value="<%= item.id %>">
                                        <input type="hidden"
                                               name="status"
                                               value="Reviewed">
                                        <button type="submit" class="review-btn">
                                            Mark as Reviewed
                                        </button>
                                    </form>
                                <% } else if ("Reviewed".equals(status)) { %>
                                    <span class="reviewed-label">
                                        &#10003; Reviewed
                                    </span>
                                    <form method="post"
                                          action="<%= request.getContextPath() %>/update-feedback-status"
                                          onsubmit="return confirm('Move this feedback back to Pending?');">
                                        <%= stateFields %>
                                        <input type="hidden"
                                               name="feedbackId"
                                               value="<%= item.id %>">
                                        <input type="hidden"
                                               name="status"
                                               value="Pending">
                                        <button type="submit" class="reopen-btn">
                                            Reopen
                                        </button>
                                    </form>
                                <% } else { %>
                                    <span class="reviewed-label">
                                        <%= Encode.forHtml(status) %>
                                    </span>
                                <% } %>

                                    <form method="post"
                                          action="<%= request.getContextPath() %>/delete-feedback"
                                          onsubmit="return confirm('Delete this feedback permanently? This cannot be undone.');">
                                        <%= stateFields %>
                                        <input type="hidden"
                                               name="feedbackId"
                                               value="<%= item.id %>">
                                        <button type="submit" class="delete-btn">
                                            Delete
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    <%  }
                       } %>
                    </tbody>
                </table>
            </div>

            <% if (matchingTotal > 0) { %>
            <nav class="pagination" aria-label="Feedback pages">
                <div>
                    Showing <%= firstShown %>&ndash;<%= lastShown %>
                    of <%= matchingTotal %>
                </div>

                <div class="page-links">
                    <a class="page-link <%= currentPage <= 1 ? "disabled" : "" %>"
                       href="<%= request.getContextPath() %>/admin-dashboard?<%= Encode.forHtmlAttribute(filterQuery) %>&amp;page=<%= currentPage - 1 %>#feedback">
                        &larr; Previous
                    </a>

                    <% int fromPage = Math.max(1, currentPage - 2);
                       int toPage = Math.min(totalPages, currentPage + 2);
                       for (int p = fromPage; p <= toPage; p++) { %>
                        <a class="page-link <%= p == currentPage ? "current" : "" %>"
                           href="<%= request.getContextPath() %>/admin-dashboard?<%= Encode.forHtmlAttribute(filterQuery) %>&amp;page=<%= p %>#feedback">
                            <%= p %>
                        </a>
                    <% } %>

                    <a class="page-link <%= currentPage >= totalPages ? "disabled" : "" %>"
                       href="<%= request.getContextPath() %>/admin-dashboard?<%= Encode.forHtmlAttribute(filterQuery) %>&amp;page=<%= currentPage + 1 %>#feedback">
                        Next &rarr;
                    </a>
                </div>
            </nav>
            <% } %>
        </section>

        <footer class="footer">
            Campus Voice &copy; <%= java.time.Year.now().getValue() %>
            &middot; Anonymous Campus Feedback System
        </footer>

    </main>
</div>
</body>
</html>
