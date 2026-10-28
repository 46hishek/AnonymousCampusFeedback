
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Campus Voice | Anonymous Feedback</title>

<style>
:root {
    --navy: #142b4d;
    --blue: #246bfd;
    --blue-dark: #1756d5;
    --text: #183153;
    --muted: #647a9a;
    --border: #dce6f3;
    --bg: #f2f7ff;
    --white: #ffffff;
    --green: #13865b;
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Inter, "Segoe UI", Arial, sans-serif;
    color: var(--text);
    background: var(--bg);
    line-height: 1.55;
}

a { color: inherit; text-decoration: none; }
button, select, textarea { font: inherit; }

.navbar {
    min-height: 76px;
    padding: 0 6.5%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    background: var(--navy);
    color: white;
}

.brand {
    display: flex;
    align-items: center;
    gap: 11px;
    font-size: 23px;
    font-weight: 800;
    letter-spacing: -.6px;
}

.brand svg { width: 38px; height: 38px; }
.brand span span { color: #67a6ff; }

.nav-links {
    display: flex;
    align-items: center;
    gap: 32px;
    font-size: 14px;
    font-weight: 600;
}

.nav-links a { opacity: .88; }
.nav-links a:hover, .nav-links a.active { opacity: 1; color: #80b5ff; }

.hero {
    position: relative;
    overflow: hidden;
    padding: 52px 7% 58px;
    background:
        radial-gradient(ellipse at 80% 15%, #d5e8ff 0, transparent 35%),
        linear-gradient(115deg, #f8fbff, #e7f2ff);
}

.hero-inner {
    max-width: 1120px;
    margin: auto;
    display: grid;
    grid-template-columns: 1fr .85fr;
    align-items: center;
    gap: 30px;
}

.eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 7px 12px;
    border-radius: 30px;
    background: #e0ecff;
    color: #2258b6;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: .8px;
    text-transform: uppercase;
}

.hero h1 {
    max-width: 560px;
    margin: 19px 0 12px;
    font-size: clamp(36px, 4.5vw, 54px);
    line-height: 1.12;
    letter-spacing: -1.8px;
}

.hero h1 span { color: var(--blue); }

.hero p {
    max-width: 500px;
    margin: 0;
    color: var(--muted);
    font-size: 16px;
}

.campus-art {
    width: 100%;
    max-width: 400px;
    justify-self: end;
    color: #6f9fe0;
}

.main-wrap {
    max-width: 1120px;
    width: 88%;
    margin: -18px auto 0;
    position: relative;
    z-index: 1;
}

.feedback-card {
    display: grid;
    grid-template-columns: .72fr 1.55fr;
    background: var(--white);
    border: 1px solid #e8eef8;
    border-radius: 18px;
    box-shadow: 0 18px 55px rgba(28, 61, 108, .10);
    overflow: hidden;
}

.benefits {
    padding: 34px 30px;
    border-right: 1px solid #e6edf7;
    background: linear-gradient(155deg, #fbfdff, #f5f9ff);
}

.benefit {
    padding: 0 0 23px;
    margin-bottom: 22px;
    border-bottom: 1px solid #e2eaf5;
}

.benefit:last-of-type {
    margin-bottom: 12px;
    border-bottom: 0;
}

.icon-circle {
    display: grid;
    place-items: center;
    width: 48px;
    height: 48px;
    border-radius: 15px;
    margin-bottom: 13px;
}

.icon-circle svg { width: 24px; height: 24px; }
.icon-green { background: #dcf7eb; color: #078457; }
.icon-blue { background: #e0edff; color: #2166e9; }
.icon-purple { background: #efe5ff; color: #7b42d7; }

.benefit h3 {
    margin: 0 0 5px;
    font-size: 15px;
}

.benefit p {
    margin: 0;
    font-size: 13px;
    color: var(--muted);
}

.signature {
    color: #5277ac;
    font-size: 17px;
    font-weight: 700;
    font-style: italic;
}

.form-panel { padding: 36px 40px 40px; }

.form-heading {
    display: flex;
    align-items: center;
    gap: 15px;
    margin-bottom: 27px;
}

.form-heading .icon-circle {
    flex-shrink: 0;
    width: 53px;
    height: 53px;
    margin: 0;
    border-radius: 50%;
}

.form-heading h2 {
    margin: 0;
    font-size: 25px;
    letter-spacing: -.6px;
}

.form-heading p {
    margin: 4px 0 0;
    color: var(--muted);
    font-size: 14px;
}

.field { margin-bottom: 22px; }

.field label {
    display: block;
    margin-bottom: 8px;
    font-size: 13px;
    font-weight: 750;
}

.required { color: #e34d5b; }

.select-wrap { position: relative; }

.select-wrap svg {
    position: absolute;
    left: 14px;
    top: 50%;
    transform: translateY(-50%);
    width: 19px;
    height: 19px;
    color: #58769d;
    pointer-events: none;
}

select, textarea {
    width: 100%;
    border: 1px solid #d7e1ef;
    border-radius: 9px;
    background: #fff;
    color: var(--text);
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}

select {
    height: 49px;
    padding: 0 14px 0 43px;
    cursor: pointer;
}

textarea {
    min-height: 135px;
    resize: vertical;
    padding: 14px;
    line-height: 1.6;
}

select:focus, textarea:focus {
    border-color: var(--blue);
    box-shadow: 0 0 0 3px rgba(36, 107, 253, .12);
}

.rating-stars {
    display: flex;
    gap: 8px;
    margin: 5px 0 7px;
}

.star {
    padding: 0;
    border: 0;
    background: transparent;
    color: #b9c8dd;
    font-size: 34px;
    line-height: 1.2;
    cursor: pointer;
    transition: transform .15s, color .15s;
}

.star:hover { transform: scale(1.1); }
.star.selected { color: #f5ad28; }

.rating-help {
    min-height: 21px;
    color: var(--muted);
    font-size: 12px;
}

.textarea-wrap { position: relative; }

.char-count {
    position: absolute;
    right: 12px;
    bottom: 10px;
    color: #8294ad;
    font-size: 11px;
    background: white;
    padding-left: 5px;
}

.submit-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    width: 100%;
    min-height: 53px;
    padding: 13px 20px;
    border: 0;
    border-radius: 9px;
    background: linear-gradient(105deg, #286cf5, #1759e6);
    color: white;
    font-weight: 750;
    cursor: pointer;
    box-shadow: 0 5px 13px rgba(36, 107, 253, .18);
    transition: transform .2s, box-shadow .2s;
}

.submit-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 8px 19px rgba(36, 107, 253, .25);
}

.submit-btn svg { width: 19px; height: 19px; }

.privacy-note {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 7px;
    margin: 14px 0 0;
    color: #71849e;
    font-size: 11px;
    text-align: center;
}

.privacy-note svg { width: 15px; height: 15px; flex-shrink: 0; }

.footer {
    max-width: 1120px;
    width: 88%;
    margin: 32px auto 0;
    padding: 0 0 26px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    color: var(--muted);
    font-size: 12px;
}

.footer-brand {
    color: var(--navy);
    font-weight: 800;
    font-size: 14px;
}

.footer-center { text-align: center; }
.footer-center p { margin: 4px 0; }

.notice {
    display: none;
    margin-bottom: 18px;
    padding: 12px 14px;
    border-radius: 8px;
    background: #fff5df;
    color: #825516;
    font-size: 13px;
}


.success-message {
    background: #e8f8ee;
    color: #176534;
    border: 1px solid #a7e4bb;
    border-radius: 12px;
    padding: 16px 20px;
    margin: 0 0 20px;
}

.success-message p {
    margin: 6px 0 0;
    font-size: 14px;
}

@media (max-width: 760px) {
    .navbar { padding: 16px 5%; }
    .brand { font-size: 20px; }
    .brand svg { width: 32px; height: 32px; }
    .nav-links { gap: 15px; font-size: 12px; }
    .nav-links a:nth-child(2) { display: none; }
    .hero { padding: 40px 6% 48px; }
    .hero-inner { grid-template-columns: 1fr; }
    .hero h1 { font-size: 40px; }
    .campus-art { display: none; }
    .main-wrap { width: 92%; }
    .feedback-card { grid-template-columns: 1fr; }
    .benefits {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 13px;
        padding: 23px 18px;
        border-right: 0;
        border-bottom: 1px solid #e6edf7;
    }
    .benefit {
        padding: 0;
        margin: 0;
        border: 0;
    }
    .benefit h3 { font-size: 12px; }
    .benefit p { font-size: 11px; }
    .icon-circle { width: 39px; height: 39px; }
    .icon-circle svg { width: 20px; height: 20px; }
    .signature { display: none; }
    .form-panel { padding: 27px 22px; }
    .form-heading h2 { font-size: 22px; }
    .footer { width: 92%; }
}

@media (max-width: 420px) {
    .nav-links { gap: 10px; }
    .nav-links a:last-child { display: none; }
    .hero h1 { font-size: 34px; }
    .benefits { grid-template-columns: 1fr; }
    .benefit {
        display: flex;
        align-items: flex-start;
        gap: 11px;
    }
    .benefit .icon-circle { flex-shrink: 0; }
    .benefit h3 { font-size: 13px; }
    .benefit p { font-size: 12px; }
    .footer { flex-direction: column; text-align: center; }
}
</style>
</head>

<body>

<header class="navbar">
    <a href="#" class="brand" aria-label="Campus Voice home">
        <svg viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <path d="M3 16 24 5l21 11-21 11L3 16Z"
                fill="#fff"/>
            <path d="M12 22v10c7 7 17 7 24 0V22L24 30 12 22Z"
                fill="#8dbbff"/>
            <path d="M43 18v12" stroke="#fff" stroke-width="3"
                stroke-linecap="round"/>
            <circle cx="43" cy="33" r="3" fill="#78adff"/>
        </svg>
        <span>Campus <span>Voice</span></span>
    </a>

    <nav class="nav-links" aria-label="Main navigation">
        <a class="active" href="#">Home</a>
        <a href="#about">About</a>
        <a href="#feedback-form">Give Feedback</a>
        <a href="${pageContext.request.contextPath}/admin-login.jsp">Admin</a>
    </nav>
</header>

<section class="hero">
    <div class="hero-inner">
        <div>
            <div class="eyebrow">
                <span>✦</span> Your voice. Your campus.
            </div>
            <h1>Your Voice <span>Matters.</span></h1>
            <p>
                Help us build a better campus experience for everyone.
                Share honest suggestions about facilities, teaching
                and student services.
            </p>
        </div>

        <svg class="campus-art" viewBox="0 0 390 220"
            role="img" aria-label="Illustration of a university campus">
            <circle cx="290" cy="65" r="27" fill="#d4e7ff"/>
            <path d="M10 185 Q65 155 120 185 T230 183 T390 180 V220 H10Z"
                fill="#d9f0e6"/>
            <path d="M65 116 195 48 325 116Z" fill="#8bb5ed"/>
            <path d="M85 112H305V192H85Z" fill="#aacaf4"/>
            <path d="M160 75H230V48H160Z" fill="#6e9fdf"/>
            <path d="M178 48V24H212V48" fill="#6e9fdf"/>
            <path d="M195 24V5" stroke="#426eaf" stroke-width="3"/>
            <path d="M195 5 225 13 195 21Z" fill="#4b83d3"/>
            <path d="M60 116H330" stroke="#fff" stroke-width="4"/>
            <path d="M175 192V151Q195 126 215 151V192Z" fill="#547fbd"/>
            <g fill="#eaf3ff">
                <rect x="103" y="128" width="23" height="23" rx="3"/>
                <rect x="140" y="128" width="23" height="23" rx="3"/>
                <rect x="227" y="128" width="23" height="23" rx="3"/>
                <rect x="264" y="128" width="23" height="23" rx="3"/>
                <rect x="103" y="162" width="23" height="18" rx="3"/>
                <rect x="140" y="162" width="23" height="18" rx="3"/>
                <rect x="227" y="162" width="23" height="18" rx="3"/>
                <rect x="264" y="162" width="23" height="18" rx="3"/>
            </g>
            <g fill="#71bd9a">
                <circle cx="38" cy="167" r="16"/>
                <circle cx="53" cy="151" r="18"/>
                <circle cx="67" cy="170" r="16"/>
                <circle cx="326" cy="163" r="17"/>
                <circle cx="345" cy="146" r="21"/>
                <circle cx="363" cy="169" r="17"/>
            </g>
            <g stroke="#4d9b7b" stroke-width="3" stroke-linecap="round">
                <path d="M53 169v25M345 165v29"/>
                <path d="m53 175-8-7m8 14 8-8m284-8-8-7m8 14 8-8"/>
            </g>
        </svg>
    </div>
</section>

<main class="main-wrap">
    <section class="feedback-card" id="feedback-form">

        <aside class="benefits" id="about">
            <div class="benefit">
                <div class="icon-circle icon-green">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-11V5l-8-3-8 3v6c0 7 8 11 8 11Z"/>
                        <path d="m9 12 2 2 4-4"/>
                    </svg>
                </div>
                <div>
                    <h3>Privacy Comes First</h3>
                    <p>This form doesn't ask for your name or email. Avoid identifying details in comments.</p>
                </div>
            </div>

            <div class="benefit">
                <div class="icon-circle icon-blue">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 3v18h18"/>
                        <path d="M8 15v3M13 10v8M18 5v13"/>
                    </svg>
                </div>
                <div>
                    <h3>Your Feedback Drives Change</h3>
                    <p>Thoughtful suggestions help identify areas for campus improvement.</p>
                </div>
            </div>

            <div class="benefit">
                <div class="icon-circle icon-purple">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/>
                    </svg>
                </div>
                <div>
                    <h3>A Better Campus for All</h3>
                    <p>Every constructive idea can contribute to a better student experience.</p>
                </div>
            </div>

            <div class="signature">Together, we can do better.</div>
        </aside>

        <div class="form-panel">
            <div class="form-heading">
                <div class="icon-circle icon-blue">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 11.5a8.4 8.4 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.7a8.4 8.4 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.4 8.4 0 0 1 3.8-.9h.5a8.5 8.5 0 0 1 8 8v.5Z"/>
                    </svg>
                </div>
                <div>
                    <h2>Submit Your Feedback</h2>
                    <p>Your perspective can make a difference.</p>
                </div>
            </div>




<% if ("1".equals(request.getParameter("submitted"))) { %>
    <div class="success-message" role="status">
        <strong>✓ Feedback submitted successfully!</strong>
        <p>Thank you for helping us improve our campus.</p>
    </div>
<% } %>

           <form id="campusFeedbackForm"
      action="${pageContext.request.contextPath}/submit-feedback"
      method="post">
                <div class="field">
                    <label for="category">
                        Feedback Category <span class="required">*</span>
                    </label>
                    <div class="select-wrap">
                        <svg viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2"
                            stroke-linecap="round" stroke-linejoin="round">
                            <path d="m20.6 13.4-7.2 7.2a2 2 0 0 1-2.8 0l-7.2-7.2a2 2 0 0 1 0-2.8l7.2-7.2H20v8Z"/>
                            <circle cx="16" cy="8" r="1"/>
                        </svg>
                        <select id="category" name="category" required>
                            <option value="">Select a category</option>
                            <option value="Teaching">Teaching &amp; Faculty</option>
                            <option value="Infrastructure">Campus Infrastructure</option>
                            <option value="Library">Library</option>
                            <option value="Cleanliness">Cleanliness</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>

                <div class="field">
                    <label>
                        Overall Rating <span class="required">*</span>
                    </label>
                    <div class="rating-stars" role="group"
                        aria-label="Choose a rating from one to five">
                        <button class="star" type="button" data-rating="1"
                            aria-label="1 star">☆</button>
                        <button class="star" type="button" data-rating="2"
                            aria-label="2 stars">☆</button>
                        <button class="star" type="button" data-rating="3"
                            aria-label="3 stars">☆</button>
                        <button class="star" type="button" data-rating="4"
                            aria-label="4 stars">☆</button>
                        <button class="star" type="button" data-rating="5"
                            aria-label="5 stars">☆</button>
                    </div>
                    <input type="hidden" id="rating" name="rating" value="">
                    <div class="rating-help" id="ratingHelp">
                        Select a rating from 1 (Poor) to 5 (Excellent).
                    </div>
                </div>

                <div class="field">
                    <label for="comments">
                        Your Comments <span class="required">*</span>
                    </label>
                    <div class="textarea-wrap">
                        <textarea id="comments" name="comments"
                            maxlength="2000" required
                            placeholder="Share your suggestions, experience or concerns..."></textarea>
                        <span class="char-count" id="charCount">0 / 2000</span>
                    </div>
                </div>

                <button class="submit-btn" type="submit">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <path d="m22 2-7 20-4-9-9-4Z"/>
                        <path d="M22 2 11 13"/>
                    </svg>
                    Submit Feedback
                    <span aria-hidden="true">→</span>
                </button>

                <p class="privacy-note">
                    <svg viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    No name or email requested. Do not include personal details.
                </p>
            </form>
        </div>
    </section>
</main>

<footer class="footer">
    <div>
        <div class="footer-brand">Campus Voice</div>
        <div>Anonymous Campus Feedback System</div>
    </div>
    <div class="footer-center">
        <p>Built for a better campus experience.</p>
        <p>&copy; 2026 Campus Voice</p>
    </div>
    <div>Student voices. Meaningful improvements.</div>
</footer>

<script>
const starButtons = document.querySelectorAll(".star");
const ratingInput = document.getElementById("rating");
const ratingHelp = document.getElementById("ratingHelp");
const comments = document.getElementById("comments");
const charCount = document.getElementById("charCount");
const form = document.getElementById("campusFeedbackForm");

const ratingLabels = {
    1: "1 - Poor",
    2: "2 - Needs Improvement",
    3: "3 - Good",
    4: "4 - Very Good",
    5: "5 - Excellent"
};

function setRating(value) {
    ratingInput.value = value;
    ratingHelp.textContent = ratingLabels[value];

    starButtons.forEach(button => {
        const selected = Number(button.dataset.rating) <= value;
        button.classList.toggle("selected", selected);
        button.textContent = selected ? "★" : "☆";
        button.setAttribute("aria-pressed",
            Number(button.dataset.rating) === value ? "true" : "false");
    });
}

starButtons.forEach(button => {
    button.addEventListener("click", () => {
        setRating(Number(button.dataset.rating));
    });
});

comments.addEventListener("input", () => {
    charCount.textContent = comments.value.length + " / 2000";
});

form.addEventListener("submit", event => {
    if (!ratingInput.value) {
        event.preventDefault();
        ratingHelp.textContent =
            "Please select a rating before continuing.";
        document.querySelector(".rating-stars").scrollIntoView({
            behavior: "smooth",
            block: "center"
        });
    }
});

const urlParams = new URLSearchParams(window.location.search);

if (urlParams.get("submitted") === "1") {
    const form = document.getElementById("campusFeedbackForm");

    if (form) {
        form.reset();
    }

 
    document.querySelectorAll(
        '#campusFeedbackForm input[name="rating"]'
    ).forEach(input => {
        input.checked = false;
    });

    document.querySelectorAll(
        '#campusFeedbackForm .star'
    ).forEach(star => {
        star.classList.remove("active");
    });

 
    const counter = document.getElementById("charCount");
    if (counter) {
        counter.textContent = "0";
    }


    window.history.replaceState(
        {},
        document.title,
        window.location.pathname
    );
}

</script>

</body>
</html>
