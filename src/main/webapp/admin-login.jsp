
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%
    if (session.getAttribute("adminUsername") != null) {
        response.sendRedirect(request.getContextPath() + "/admin-dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="robots" content="noindex">
<title>Admin Sign In | Campus Voice</title>
<style>
:root {
    --navy: #14213d;
    --blue: #4f46e5;
    --muted: #69758b;
    --border: #e4e8f0;
}
* { box-sizing: border-box; }
body {
    margin: 0;
    min-height: 100vh;
    font-family: Inter, "Segoe UI", Arial, sans-serif;
    color: var(--navy);
    background: #f5f7fc;
}
.page {
    min-height: 100vh;
    display: grid;
    grid-template-columns: 1fr 1fr;
}
.brand-panel {
    position: relative;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 46px clamp(28px, 5vw, 76px);
    overflow: hidden;
    color: white;
    background: linear-gradient(145deg, #111c38, #273b73 70%, #4f46e5);
}
.brand-panel:before,
.brand-panel:after {
    content: "";
    position: absolute;
    border: 1px solid rgba(255,255,255,.13);
    border-radius: 50%;
    width: 410px;
    height: 410px;
    right: -180px;
    bottom: 8%;
}
.brand-panel:after {
    width: 290px;
    height: 290px;
    right: -120px;
    bottom: 15%;
}
.brand, .brand-panel footer, .brand-copy { position: relative; z-index: 1; }
.brand {
    display: flex;
    align-items: center;
    gap: 12px;
    font-weight: 750;
    font-size: 20px;
    letter-spacing: -.4px;
}
.logo {
    display: grid;
    place-items: center;
    width: 44px;
    height: 44px;
    border-radius: 13px;
    background: white;
    color: #3730a3;
    font-size: 24px;
    font-weight: 850;
}
.brand-copy { max-width: 520px; margin: 60px 0; }
.eyebrow {
    display: inline-block;
    padding: 8px 12px;
    border: 1px solid rgba(255,255,255,.25);
    border-radius: 99px;
    color: #e0e7ff;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
}
.brand-copy h1 {
    margin: 25px 0 18px;
    font-size: clamp(36px, 4.5vw, 58px);
    line-height: 1.1;
    letter-spacing: -2px;
}
.brand-copy p {
    max-width: 430px;
    color: #d7def4;
    font-size: 16px;
    line-height: 1.8;
}
.brand-panel footer { color: #c4cce5; font-size: 12px; }
.form-panel {
    display: grid;
    place-items: center;
    padding: 32px;
}
.login-card { width: 100%; max-width: 410px; }
.mobile-brand { display: none; }
.kicker {
    margin: 0 0 12px;
    color: var(--blue);
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 1.4px;
    text-transform: uppercase;
}
h2 {
    margin: 0;
    font-size: 34px;
    letter-spacing: -1.2px;
}
.intro {
    margin: 12px 0 30px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}
.error {
    margin-bottom: 20px;
    padding: 13px 15px;
    border: 1px solid #fecaca;
    border-radius: 11px;
    background: #fff1f2;
    color: #a61b35;
    font-size: 13px;
    line-height: 1.5;
}
.success {
    margin-bottom: 20px;
    padding: 13px 15px;
    border: 1px solid #bbf7d0;
    border-radius: 11px;
    background: #f0fdf4;
    color: #166534;
    font-size: 13px;
    line-height: 1.5;
}
.field { margin: 21px 0; }
label {
    display: block;
    margin-bottom: 9px;
    font-size: 13px;
    font-weight: 700;
}
.input-wrap { position: relative; }
input {
    width: 100%;
    min-height: 50px;
    padding: 13px 15px;
    border: 1px solid #dce2ed;
    border-radius: 11px;
    background: white;
    color: var(--navy);
    font-size: 14px;
    outline: none;
    transition: border .2s, box-shadow .2s;
}
input:focus {
    border-color: var(--blue);
    box-shadow: 0 0 0 4px rgba(79,70,229,.11);
}
#password { padding-right: 76px; }
.toggle {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    border: 0;
    background: transparent;
    color: var(--blue);
    font-size: 12px;
    font-weight: 750;
    cursor: pointer;
    padding: 9px 4px;
}
.submit {
    width: 100%;
    min-height: 51px;
    margin-top: 6px;
    border: 0;
    border-radius: 11px;
    color: white;
    background: linear-gradient(100deg, #4338ca, #6366f1);
    box-shadow: 0 8px 18px rgba(79,70,229,.2);
    font-size: 14px;
    font-weight: 750;
    cursor: pointer;
    transition: transform .2s, box-shadow .2s;
}
.submit:hover {
    transform: translateY(-1px);
    box-shadow: 0 11px 22px rgba(79,70,229,.28);
}
.secure-note {
    display: flex;
    gap: 10px;
    align-items: flex-start;
    margin-top: 24px;
    padding: 15px;
    border: 1px solid var(--border);
    border-radius: 12px;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.6;
}
.secure-note strong { color: var(--navy); }
.back {
    display: inline-block;
    margin-top: 26px;
    color: #4f46e5;
    font-size: 13px;
    font-weight: 700;
    text-decoration: none;
}
.back:hover { text-decoration: underline; }
@media (max-width: 800px) {
    .page { grid-template-columns: 1fr; }
    .brand-panel { display: none; }
    .form-panel { padding: 28px 22px; }
    .login-card { max-width: 440px; }
    .mobile-brand {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 44px;
        font-size: 18px;
        font-weight: 800;
    }
    .mobile-brand .logo {
        background: #e8eaff;
        color: #4338ca;
    }
    h2 { font-size: 30px; }
}
@media (prefers-reduced-motion: reduce) {
    *, *:before, *:after { transition: none !important; }
}
</style>
</head>
<body>
<div class="page">
    <aside class="brand-panel">
        <div class="brand">
            <div class="logo">C</div>
            <span>Campus Voice</span>
        </div>

        <div class="brand-copy">
            <span class="eyebrow">Campus feedback platform</span>
            <h1>Better campuses begin with listening.</h1>
            <p>
                A dedicated workspace to review student feedback,
                understand concerns, and help build a better campus experience.
            </p>
        </div>

        <footer>Campus Voice · Administration Portal</footer>
    </aside>

    <main class="form-panel">
        <section class="login-card">
            <div class="mobile-brand">
                <div class="logo">C</div>
                <span>Campus Voice</span>
            </div>

            <p class="kicker">Administrator access</p>
            <h2>Welcome back</h2>
            <p class="intro">
                Sign in with your administrator credentials to continue.
            </p>

            <% if ("1".equals(request.getParameter("error"))) { %>
                <div class="error" role="alert">
                    Sign-in unsuccessful. Check your username and password,
                    then try again.
                </div>
            <% } else if ("2".equals(request.getParameter("error"))) { %>
                <div class="error" role="alert">
                    Too many failed attempts. Please wait 15 minutes
                    and try again.
                </div>
            <% } %>

            <% if ("1".equals(request.getParameter("passwordReset"))) { %>
                <div class="success" role="status">
                    Your password was changed. Please sign in.
                </div>
            <% } else if ("1".equals(request.getParameter("loggedOut"))) { %>
                <div class="success" role="status">
                    You have been signed out.
                </div>
            <% } else if ("1".equals(request.getParameter("setup"))) { %>
                <div class="success" role="status">
                    Administrator created. You can sign in now.
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/admin-login"
                  method="post">
                <div class="field">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="Enter your username"
                           autocomplete="username"
                           maxlength="50" required>
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <div class="input-wrap">
                        <input type="password" id="password" name="password"
                               placeholder="Enter your password"
                               autocomplete="current-password"
                               maxlength="72" required>
                        <button class="toggle" type="button"
                                id="togglePassword"
                                aria-controls="password"
                                aria-label="Show password">Show</button>
                    </div>
                </div>

                <button class="submit" type="submit">Sign in to dashboard
                    &nbsp; →</button>
                    <br>
                    <a href="${pageContext.request.contextPath}/forgot-password">
    Forgot Password?
</a>
            </form>

            <div class="secure-note">
                <span aria-hidden="true">🔒</span>
                <div>
                    <strong>Administrator-only area</strong><br>
                    Your session is protected. Sign out when you finish.
                </div>
            </div>

            <a class="back"
               href="<%= request.getContextPath() %>/index.jsp">
                ← Return to feedback page
            </a>
        </section>
    </main>
</div>
<script>
const passwordField = document.getElementById("password");
const toggleButton = document.getElementById("togglePassword");

toggleButton.addEventListener("click", function () {
    const show = passwordField.type === "password";
    passwordField.type = show ? "text" : "password";
    toggleButton.textContent = show ? "Hide" : "Show";
    toggleButton.setAttribute(
        "aria-label", show ? "Hide password" : "Show password"
    );
});
</script>
</body>
</html>
