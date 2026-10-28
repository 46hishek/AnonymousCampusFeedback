
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Forgot Password | Campus Voice</title>
<style>
:root {
    --primary: #4338ca;
    --primary-dark: #3730a3;
    --ink: #172033;
    --muted: #64748b;
    --line: #e2e8f0;
    --surface: #ffffff;
    --bg: #f5f7fc;
}
* { box-sizing: border-box; }
body {
    margin: 0;
    min-height: 100vh;
    font-family: "Segoe UI", Inter, Arial, sans-serif;
    background: var(--bg);
    color: var(--ink);
    display: flex;
    flex-direction: column;
}
.topbar {
    height: 78px;
    padding: 0 clamp(20px, 7vw, 100px);
    background: #fff;
    border-bottom: 1px solid var(--line);
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.brand {
    display: flex;
    align-items: center;
    gap: 12px;
    text-decoration: none;
    color: var(--ink);
}
.brand-mark {
    width: 46px;
    height: 46px;
    display: grid;
    place-items: center;
    background: var(--primary);
    border-radius: 13px;
    box-shadow: 0 5px 12px #4338ca2b;
}
.brand-name {
    font-size: 20px;
    font-weight: 750;
    letter-spacing: -.5px;
}
.brand-subtitle {
    display: block;
    margin-top: 2px;
    font-size: 11px;
    color: var(--muted);
    font-weight: 500;
    letter-spacing: .2px;
}
.header-label {
    font-size: 12px;
    font-weight: 650;
    color: var(--muted);
}
main {
    flex: 1;
    display: grid;
    place-items: center;
    padding: 48px 18px;
}
.layout {
    width: 100%;
    max-width: 960px;
    display: grid;
    grid-template-columns: 1fr 1fr;
    overflow: hidden;
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: 22px;
    box-shadow: 0 24px 70px rgba(30, 41, 80, .09);
}
.visual {
    position: relative;
    overflow: hidden;
    min-height: 480px;
    padding: 46px 38px;
    background: linear-gradient(145deg, #312e81 0%, #4338ca 58%, #6366f1 100%);
    color: #fff;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}
.visual:before, .visual:after {
    content: "";
    position: absolute;
    border: 1px solid rgba(255,255,255,.13);
    border-radius: 50%;
    pointer-events: none;
}
.visual:before {
    width: 310px; height: 310px;
    right: -140px; top: -90px;
}
.visual:after {
    width: 230px; height: 230px;
    right: -100px; top: -50px;
}
.visual-content, .visual-foot { position: relative; z-index: 1; }
.visual-icon {
    width: 76px; height: 76px;
    display: grid; place-items: center;
    border-radius: 20px;
    background: rgba(255,255,255,.13);
    border: 1px solid rgba(255,255,255,.2);
    margin-bottom: 30px;
}
.visual h2 {
    margin: 0 0 14px;
    font-size: 30px;
    line-height: 1.25;
    letter-spacing: -.8px;
}
.visual p {
    margin: 0;
    max-width: 340px;
    color: #e0e7ff;
    font-size: 14px;
    line-height: 1.85;
}
.visual-foot {
    padding-top: 22px;
    border-top: 1px solid rgba(255,255,255,.2);
    color: #e0e7ff;
    font-size: 12px;
    line-height: 1.7;
}
.form-panel {
    padding: 48px 42px;
    display: flex;
    flex-direction: column;
    justify-content: center;
}
.step-label {
    color: var(--primary);
    text-transform: uppercase;
    letter-spacing: 1.6px;
    font-size: 11px;
    font-weight: 800;
}
h1 {
    margin: 12px 0 10px;
    font-size: 30px;
    line-height: 1.2;
    letter-spacing: -1px;
}
.description {
    margin: 0 0 28px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.8;
}
label {
    display: block;
    margin-bottom: 9px;
    font-size: 13px;
    font-weight: 700;
}
.input-wrap { position: relative; }
.input-icon {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    color: #94a3b8;
    pointer-events: none;
}
input {
    width: 100%;
    height: 51px;
    padding: 0 14px 0 44px;
    border: 1px solid #d7deea;
    border-radius: 10px;
    color: var(--ink);
    background: #fff;
    font: inherit;
    font-size: 14px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}
input::placeholder { color: #a0aabc; }
input:focus {
    border-color: #6366f1;
    box-shadow: 0 0 0 4px rgba(99,102,241,.12);
}
.helper {
    margin: 10px 0 22px;
    color: #7b8799;
    font-size: 12px;
    line-height: 1.7;
}
.primary-btn {
    width: 100%;
    min-height: 50px;
    border: 0;
    border-radius: 10px;
    background: var(--primary);
    color: #fff;
    font: inherit;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: background .2s, transform .2s;
}
.primary-btn:hover { background: var(--primary-dark); transform: translateY(-1px); }
.primary-btn:focus-visible, a:focus-visible {
    outline: 3px solid #a5b4fc;
    outline-offset: 3px;
}
.back-link {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 25px;
    color: #596579;
    font-size: 13px;
    font-weight: 650;
    text-decoration: none;
}
.back-link:hover { color: var(--primary); }
.notice {
    padding: 13px 14px;
    margin: 0 0 20px;
    border-radius: 10px;
    background: #eef2ff;
    border: 1px solid #c7d2fe;
    color: #3730a3;
    font-size: 13px;
    line-height: 1.65;
}
.notice.error {
    background: #fff1f2;
    border-color: #fecdd3;
    color: #9f1239;
}
.footer {
    text-align: center;
    padding: 20px;
    color: #8490a3;
    font-size: 12px;
}
@media (max-width: 720px) {
    .layout { max-width: 470px; grid-template-columns: 1fr; }
    .visual { min-height: auto; padding: 28px; }
    .visual-icon { width: 58px; height: 58px; margin-bottom: 20px; }
    .visual h2 { font-size: 23px; }
    .visual p { font-size: 13px; }
    .visual-foot { margin-top: 24px; padding-top: 14px; }
    .form-panel { padding: 32px 26px; }
    .header-label { display: none; }
}
@media (prefers-reduced-motion: reduce) {
    *, *:before, *:after { transition: none !important; }
}
</style>
</head>
<body>
<header class="topbar">
    <a class="brand" href="${pageContext.request.contextPath}/">
        <span class="brand-mark" aria-hidden="true">
            <svg width="31" height="31" viewBox="0 0 32 32" fill="none">
                <path d="M4 12 16 5l12 7H4Z" stroke="white"
                      stroke-width="1.8" stroke-linejoin="round"/>
                <path d="M7 14h18M9 14v9m5-9v9m5-9v9m5-9v9M6 25h20"
                      stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                <path d="M20 19h8v6h-4l-3 2v-2h-1z"
                      fill="#c7d2fe" stroke="white" stroke-width="1.2"
                      stroke-linejoin="round"/>
            </svg>
        </span>
        <span>
            <span class="brand-name">Campus Voice</span>
            <span class="brand-subtitle">Anonymous Campus Feedback System</span>
        </span>
    </a>
    <span class="header-label">Administrator Portal</span>
</header>

<main>
    <section class="layout">
        <aside class="visual">
            <div class="visual-content">
                <div class="visual-icon" aria-hidden="true">
                    <svg width="44" height="44" viewBox="0 0 48 48" fill="none">
                        <path d="M5 19 24 7l19 12H5Z" stroke="white"
                              stroke-width="2" stroke-linejoin="round"/>
                        <path d="M10 22h28M13 22v15m7-15v15m8-15v15m7-15v15M8 40h32"
                              stroke="white" stroke-width="2" stroke-linecap="round"/>
                        <path d="M27 27h15v10h-7l-5 4v-4h-3z"
                              fill="#c7d2fe" stroke="white" stroke-width="1.5"
                              stroke-linejoin="round"/>
                    </svg>
                </div>
                <h2>Your campus.<br>Your voice.</h2>
                <p>
                    A secure administrator experience for managing anonymous
                    campus feedback. Get back to your account with confidence.
                </p>
            </div>
            <div class="visual-foot">
                <strong>Privacy matters.</strong><br>
                Password recovery is designed to protect your administrator account.
            </div>
        </aside>

        <div class="form-panel">
            <div class="step-label">Account recovery</div>
            <h1>Forgot password?</h1>
            <p class="description">
                Enter your registered administrator email address.
                If an account matches, we'll send a secure reset link.
            </p>

            <% String flashMessage = (String) request.getAttribute("message");
               String flashError = (String) request.getAttribute("error"); %>

            <% if (flashMessage != null) { %>
                <div class="notice" role="status">
                    <%= org.owasp.encoder.Encode.forHtml(flashMessage) %>
                    Check your inbox and spam folder.
                </div>
            <% } %>

            <% String devNote = (String) request.getAttribute("devNote");
               String devLink = (String) request.getAttribute("devLink"); %>
            <% if (devNote != null) { %>
                <div class="notice error" role="status">
                    <strong>Local testing help</strong><br>
                    <%= org.owasp.encoder.Encode.forHtml(devNote) %>
                    <% if (devLink != null) { %>
                        <br>Use this link (valid 15 minutes):<br>
                        <a href="<%= org.owasp.encoder.Encode.forHtmlAttribute(devLink) %>"
                           style="overflow-wrap:anywhere;">
                            <%= org.owasp.encoder.Encode.forHtml(devLink) %>
                        </a>
                    <% } %>
                </div>
            <% } %>

            <% if (flashError != null) { %>
                <div class="notice error" role="alert">
                    <%= org.owasp.encoder.Encode.forHtml(flashError) %>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/forgot-password"
                  method="post">
                <label for="email">Registered email address</label>
                <div class="input-wrap">
                    <span class="input-icon" aria-hidden="true">
                        <svg width="19" height="19" viewBox="0 0 24 24"
                             fill="none" stroke="currentColor" stroke-width="1.7"
                             stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="5" width="18" height="14" rx="2"/>
                            <path d="m4 7 8 6 8-6"/>
                        </svg>
                    </span>
                    <input type="email" id="email" name="email"
                           placeholder="admin@yourcollege.edu"
                           maxlength="254" autocomplete="email" required>
                </div>
                <p class="helper">
                    Use the email address associated with your administrator account.
                </p>
                <button class="primary-btn" type="submit">
                    Send reset link &nbsp; &rarr;
                </button>
            </form>

            <a class="back-link"
               href="${pageContext.request.contextPath}/admin-login.jsp">
                <span aria-hidden="true">&larr;</span> Back to administrator login
            </a>
        </div>
    </section>
</main>

<footer class="footer">
    &copy; 2026 Campus Voice &middot; Anonymous Campus Feedback System
</footer>
</body>
</html>
