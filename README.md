# Campus Voice – Anonymous Campus Feedback System

Java 24 · Jakarta Servlet 6 / JSP (Tomcat 10.1) · MySQL 8 · Maven · Eclipse

Students send anonymous feedback (category, 1–5 rating, comments). Administrators sign in to a dashboard to
read, search, filter, review, reopen, delete and export it.

## Features

**Students (no login, no personal data stored)**
- Feedback form: category, star rating, comments (max 2000 characters)
- Spam protection: limited submissions per visitor (kept in memory only, never stored)

**Administrators**
- First-time setup page to create the first admin (`/admin-setup`, works once, only on the server computer)
- Sign in with BCrypt-hashed password, sign-in lockout after repeated failures, 15-minute session, sign out
- Dashboard: totals, pending/reviewed counts, average rating, category and rating charts
- Search and category filter, **pagination** (10 per page)
- **Mark as Reviewed**, **Reopen** (back to Pending), **Delete**
- **Export CSV** of the current filter (opens in Excel)
- Forgot / reset password by e-mail link (15 minutes, one use)

---

## Setup (Windows, Eclipse, Tomcat 10.1, JDK 24, MySQL)

### 1. Create the database
1. Open **MySQL Workbench**, connect to your local server.
2. **File → Open SQL Script** → choose `database/schema.sql` → click the **lightning bolt**.
   (Safe to run again. It also upgrades an older database that has no admin e-mail column.)
3. Optional demo data: open and run `database/sample_data.sql`.

### 2. Put your MySQL password in the settings file
Open `src/main/resources/campus-feedback.properties` and set:
```
db.user=root
db.password=YOUR_MYSQL_PASSWORD
```
(If you use a different MySQL user or port, change `db.user` / `db.url` too.)

### 3. Import into Eclipse
1. **File → Import → Maven → Existing Maven Projects** → select this folder → **Finish**.
2. Wait for the bottom-right progress bar (internet needed once for the libraries).
3. If you see red errors: right-click the project → **Maven → Update Project…** → tick **Force Update** → OK.

### 4. Add the server
1. **Window → Show View → Servers** → *No servers are available. Click this link…*
2. Choose **Apache → Tomcat v10.1 Server** → Next → select your Tomcat 10.1 folder and JDK 24.
3. Add **AnonymousCampusFeedback** to the server → Finish.

### 5. Run
Right-click the project → **Run As → Run on Server** → Finish. Open:

`http://localhost:8080/campus-feedback/`

### 6. Create the first administrator
Open `http://localhost:8080/campus-feedback/admin-setup`, choose a username, e-mail and a password of
12+ characters, and press **Create administrator**. Then sign in at
`http://localhost:8080/campus-feedback/admin-login.jsp` (there is also an **Admin** link on the home page).

This page only works while no admin exists, and only from the computer running Tomcat.
(Alternative: run `edu.campus.feedback.util.CreateAdmin` from Eclipse with *Run As → Java Application*.)

---

## Forgot password e-mail (optional)

When you test on your own computer (localhost), the forgot-password page shows the reset link and the exact
e-mail error **on the page itself**, so you can test everything without Gmail. The link is also printed in the
Eclipse Console (`[Campus Voice - DEV]`).

The account must have an e-mail saved. If it shows `NULL`, run in MySQL Workbench:
`UPDATE campus_feedback.admin_users SET email='you@example.com' WHERE username='your_username';`

To send real e-mails with Gmail:
1. Google Account → Security → turn on **2-Step Verification**.
2. Google Account → Security → **App passwords** → create one called "Campus Voice" (16 letters).
3. In `campus-feedback.properties` set `mail.username=yourname@gmail.com` and
   `mail.app.password=abcd efgh ijkl mnop` (spaces are fine). Set `mail.dev.logLink=false` on a real server.
4. **Test it without the website:** in Eclipse right-click `MailTest.java` → *Run As → Java Application*, type
   your own e-mail address in the Console. It prints SUCCESS, or a plain-English reason for the failure.
5. Restart the server.

Error `535 Username and Password not accepted` = wrong address or you used your normal password instead of the
App password. Remove old Windows variables `CAMPUS_MAIL_USERNAME` / `CAMPUS_MAIL_APP_PASSWORD` if you set them.
Other providers work too (`mail.smtp.host`, `mail.smtp.port`). On a real server also set `app.base.url`.

## Useful pages
| Page | Address |
|---|---|
| Feedback form | `/campus-feedback/` |
| Admin sign in | `/campus-feedback/admin-login.jsp` |
| First-admin setup | `/campus-feedback/admin-setup` |
| Dashboard | `/campus-feedback/admin-dashboard` |

## Troubleshooting
- **Blank/500 error page, "Communications link failure" in Console:** MySQL is not running, or `db.url` is wrong.
- **"Access denied for user":** the password in `campus-feedback.properties` does not match MySQL.
- **"Table ... doesn't exist":** run `database/schema.sql` (step 1).
- **404 on `/admin-setup`:** an admin already exists (use the sign-in page, or *Forgot password?*), or you opened it from another computer.
- **Red errors after import:** *Maven → Update Project* with Force Update.
- **Changed the settings file but nothing changed:** restart the server (right-click server → Restart).

## Before putting it online
1. Create a dedicated MySQL user (not `root`) with only `SELECT, INSERT, UPDATE, DELETE` on `campus_feedback`.
2. Use HTTPS, set `app.base.url`, set `mail.dev.logLink=false`.
3. Do not commit `campus-feedback.properties` with real passwords.
4. Back up the database regularly (`mysqldump campus_feedback`).
