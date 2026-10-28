<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" isErrorPage="true" %>
<%
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    int code = statusCode == null ? 500 : statusCode;
    String title;
    String text;
    switch (code) {
        case 400: title = "Request not accepted";
                  text = "Some of the information sent was not valid. Please go back and check it."; break;
        case 403: title = "Access denied";
                  text = "Your security token expired or you are not allowed to do this. Please reload the page and try again."; break;
        case 404: title = "Page not found";
                  text = "The page you are looking for does not exist or is no longer available."; break;
        case 429: title = "Too many requests";
                  text = "Please wait a few minutes and try again."; break;
        default:  title = "Something went wrong";
                  text = "We could not complete your request. Please try again in a moment."; break;
    }
    response.setStatus(code);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex">
<title><%= title %> | Campus Voice</title>
<style>
:root { --navy: #14213d; --blue: #4f46e5; --muted: #69758b; }
* { box-sizing: border-box; }
body {
    margin: 0;
    min-height: 100vh;
    display: grid;
    place-items: center;
    padding: 24px;
    font-family: Inter, "Segoe UI", Arial, sans-serif;
    color: var(--navy);
    background: linear-gradient(145deg, #111c38, #273b73 70%, #4f46e5);
}
.card {
    width: min(480px, 100%);
    padding: 40px 34px;
    text-align: center;
    background: #fff;
    border-radius: 20px;
    box-shadow: 0 24px 60px rgba(8, 12, 40, .35);
}
.code {
    font-size: 54px;
    font-weight: 800;
    color: var(--blue);
    line-height: 1;
}
h1 { margin: 14px 0 8px; font-size: 22px; }
p { margin: 0 0 26px; color: var(--muted); line-height: 1.6; font-size: 14px; }
a {
    display: inline-block;
    padding: 12px 22px;
    border-radius: 10px;
    background: var(--blue);
    color: #fff;
    font-weight: 700;
    font-size: 14px;
    text-decoration: none;
}
a:hover { background: #4338ca; }
</style>
</head>
<body>
<main class="card">
    <div class="code"><%= code %></div>
    <h1><%= title %></h1>
    <p><%= text %></p>
    <a href="<%= request.getContextPath() %>/index.jsp">Back to Campus Voice</a>
</main>
</body>
</html>
