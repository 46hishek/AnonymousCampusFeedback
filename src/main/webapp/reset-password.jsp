
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String resetToken = (String) request.getAttribute("token");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Reset Password | Campus Voice</title>
<style>
:root {
    --primary: #4338ca;
    --primary-dark: #3730a3;
    --ink: #172033;
    --muted: #64748b;
    --line: #e2e8f0;
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
    background: white;
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
}
.header-label { font-size: 12px; font-weight: 650; color: var(--muted); }
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
    background: white;
    border: 1px solid var(--line);
    border-radius: 22px;
    box-shadow: 0 24px 70px rgba(30,41,80,.09);
}
.visual {
    position: relative;
    overflow: hidden;
    min-height: 520px;
    padding: 46px 38px;
    background: linear-gradient(145deg, #312e81 0%, #4338ca 58%, #6366f1 100%);
    color: white;
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
.visual:before { width: 310px; height: 310px; right: -140px; top: -90px; }
.visual:after { width: 230px; height: 230px; right: -100px; top: -50px; }
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
    padding: 44px 42px;
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
    margin: 0 0 26px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.8;
}
.field { margin-bottom: 19px; }
label {
    display: block;
    margin-bottom: 9px;
    font-size: 13px;
    font-weight: 700;
}
.password-wrap { position: relative; }
.field-icon {
    position: absolute;
    top: 50%;
    left: 14px;
    transform: translateY(-50%);
    color: #94a3b8;
    pointer-events: none;
}
input {
    width: 100%;
    height: 51px;
    padding: 0 68px 0 44px;
    border: 1px solid #d7deea;
    border-radius: 10px;
    color: var(--ink);
    background: white;
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
.toggle {
    position: absolute;
    right: 11px;
    top: 50%;
    transform: translateY(-50%);
    padding: 7px 4px;
    border: 0;
    background: transparent;
    color: var(--primary);
    font-size: 12px;
    font-weight: 750;
    cursor: pointer;
}
.rules {
    margin: 1px 0 23px;
    padding: 14px 15px;
    border: 1px solid #e5e7eb;
    background: #f8faff;
    border-radius: 10px;
}
.rules-title {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 8px;
    font-size: 12px;
    font-weight: 750;
    color: #334155;
}
.rules ul {
    margin: 0;
    padding-left: 19px;
    color: #718096;
    font-size: 12px;
    line-height: 1.9;
}
.primary-btn {
    width: 100%;
    min-height: 50px;
    border: 0;
    border-radius: 10px;
    background: var(--primary);
    color: white;
    font: inherit;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: background .2s, transform .2s;
}
.primary-btn:hover { background: var(--primary-dark); transform: translateY(-1px); }
.primary-btn:focus-visible, a:focus-visible, .toggle:focus-visible {
    outline: 3px solid #a5b4fc;
    outline-offset: 3px;
}
.back-link {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 8px;
    margin-top: 24px;
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
    background: #fff1f2;
    border: 1px solid #fecdd3;
    color: #9f1239;
    font-size: 13px;
    line-height: 1.65;
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
                    <svg width="43" height="43" viewBox="0 0 48 48" fill="none">
                        <rect x="9" y="21" width="30" height="22" rx="4"
                              stroke="white" stroke-width="2"/>
                        <path d="M16 21v-7a8 8 0 0 1 16 0v7"
                              stroke="white" stroke-width="2.5" stroke-linecap="round"/>
                        <circle cx="24" cy="30" r="2.5" fill="white"/>
                        <path d="M24 32.5v4" stroke="white" stroke-width="2"
                              stroke-linecap="round"/>
                    </svg>
                </div>
                <h2>Secure your<br>account access.</h2>
                <p>
                    Create a new administrator password to continue managing
                    campus feedback securely.
                </p>
            </div>
            <div class="visual-foot">
                <strong>One secure step.</strong><br>
                Your reset link is time-limited and intended for one-time use.
            </div>
        </aside>

        <div class="form-panel">
            <div class="step-label">Password recovery</div>
            <h1>Create new password</h1>
            <p class="description">
                Choose a strong password for your administrator account.
                Enter it again to confirm.
            </p>

            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="notice" role="alert">
                    <%= org.owasp.encoder.Encode.forHtml(errorMessage) %>
                </div>
            <% } %>

            <% if (resetToken != null && !resetToken.isBlank()) { %>
            <form action="${pageContext.request.contextPath}/reset-password"
                  method="post" id="resetForm">
                <input type="hidden" name="token"
                       value="<%= org.owasp.encoder.Encode.forHtmlAttribute(resetToken) %>">

                <div class="field">
                    <label for="password">New password</label>
                    <div class="password-wrap">
                        <span class="field-icon" aria-hidden="true">
                            <svg width="18" height="18" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="1.7"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <rect x="4" y="10" width="16" height="11" rx="2"/>
                                <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                            </svg>
                        </span>
                        <input type="password" id="password" name="password"
                               minlength="12" maxlength="72"
                               autocomplete="new-password"
                               placeholder="Enter a new password" required>
                        <button class="toggle" type="button"
                                onclick="togglePassword('password', this)">
                            Show
                        </button>
                    </div>
                </div>

                <div class="field">
                    <label for="confirmPassword">Confirm new password</label>
                    <div class="password-wrap">
                        <span class="field-icon" aria-hidden="true">
                            <svg width="18" height="18" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="1.7"
                                 stroke-linecap="round" stroke-linejoin="round">
                                <rect x="4" y="10" width="16" height="11" rx="2"/>
                                <path d="M8 10V7a4 4 0 0 1 8 0v3"/>
                                <path d="m9 15 2 2 4-4"/>
                            </svg>
                        </span>
                        <input type="password" id="confirmPassword"
                               name="confirmPassword" minlength="12" maxlength="72"
                               autocomplete="new-password"
                               placeholder="Re-enter your password" required>
                        <button class="toggle" type="button"
                                onclick="togglePassword('confirmPassword', this)">
                            Show
                        </button>
                    </div>
                </div>

                <div class="rules">
                    <div class="rules-title">
                        <svg width="16" height="16" viewBox="0 0 24 24"
                             fill="none" stroke="#4338ca" stroke-width="1.8"
                             stroke-linecap="round" stroke-linejoin="round"
                             aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 11v5m0-8h.01"/>
                        </svg>
                        Password guidelines
                    </div>
                    <ul>
                        <li>Use at least 12 characters.</li>
                        <li>Both password fields must match.</li>
                        <li>Choose a unique password.</li>
                    </ul>
                </div>

                <button class="primary-btn" type="submit">
                    Update password &nbsp; &rarr;
                </button>
            </form>
            <% } else if (errorMessage == null || errorMessage.isBlank()) { %>
                <div class="notice" role="alert">
                    The reset link is missing. Request a new link to continue.
                </div>
            <% } %>

            <a class="back-link"
               href="${pageContext.request.contextPath}/forgot-password">
                <span aria-hidden="true">&larr;</span> Request a new reset link
            </a>
        </div>
    </section>
</main>

<footer class="footer">
    &copy; 2026 Campus Voice &middot; Anonymous Campus Feedback System
</footer>

<script>
function togglePassword(id, button) {
    const field = document.getElementById(id);
    const isVisible = field.type === "text";
    field.type = isVisible ? "password" : "text";
    button.textContent = isVisible ? "Show" : "Hide";
    button.setAttribute("aria-label",
        (isVisible ? "Show " : "Hide ") +
        (id === "password" ? "new password" : "confirm password"));
}

document.getElementById("resetForm")?.addEventListener("submit", function(event) {
    const password = document.getElementById("password").value;
    const confirmation = document.getElementById("confirmPassword").value;

    if (password !== confirmation) {
        event.preventDefault();
        document.getElementById("confirmPassword").setCustomValidity(
            "The passwords do not match.");
        document.getElementById("confirmPassword").reportValidity();
    }
});

document.getElementById("confirmPassword")?.addEventListener("input", function() {
    this.setCustomValidity("");
});
</script>
</body>
</html>
