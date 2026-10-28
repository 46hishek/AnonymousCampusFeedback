-- ============================================================
-- Campus Voice - Anonymous Campus Feedback System
-- MySQL 8.x schema.
--
-- Safe to run more than once: it never drops or deletes data.
-- It also upgrades an older database (adds the admin "email" column
-- if your admin_users table was created without it).
--
-- Run in MySQL Workbench:  File > Open SQL Script > this file > lightning bolt.
-- ============================================================

CREATE DATABASE IF NOT EXISTS campus_feedback
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE campus_feedback;

-- ------------------------------------------------------------
-- Anonymous feedback. No name, e-mail, IP address or session id is stored.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
    id          INT           NOT NULL AUTO_INCREMENT,
    category    VARCHAR(30)   NOT NULL,
    rating      TINYINT       NOT NULL,
    comments    VARCHAR(2000) NOT NULL,
    status      VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_feedback_created  (created_at),
    KEY idx_feedback_category (category),
    KEY idx_feedback_status   (status),
    CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_feedback_status CHECK (status IN ('Pending', 'Reviewed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Administrator accounts. Only a BCrypt hash of the password is stored.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS admin_users (
    id            INT          NOT NULL AUTO_INCREMENT,
    username      VARCHAR(50)  NOT NULL,
    email         VARCHAR(254) NULL,
    password_hash VARCHAR(100) NOT NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- One-time, 15-minute password reset links (only a SHA-256 hash is stored).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id          INT      NOT NULL AUTO_INCREMENT,
    admin_id    INT      NOT NULL,
    token_hash  CHAR(64) NOT NULL,
    expires_at  DATETIME NOT NULL,
    used_at     DATETIME NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_reset_token_hash (token_hash),
    KEY idx_reset_admin (admin_id),
    CONSTRAINT fk_reset_admin FOREIGN KEY (admin_id)
        REFERENCES admin_users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Upgrade helper: older databases may not have admin_users.email.
-- ------------------------------------------------------------
SET @has_email = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'campus_feedback'
      AND TABLE_NAME   = 'admin_users'
      AND COLUMN_NAME  = 'email');
SET @sql = IF(@has_email = 0,
    'ALTER TABLE admin_users ADD COLUMN email VARCHAR(254) NULL AFTER username',
    'SELECT ''admin_users.email already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @has_email_idx = (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'campus_feedback'
      AND TABLE_NAME   = 'admin_users'
      AND INDEX_NAME   = 'uq_admin_email');
SET @sql = IF(@has_email_idx = 0,
    'ALTER TABLE admin_users ADD UNIQUE KEY uq_admin_email (email)',
    'SELECT ''uq_admin_email already exists'' AS info');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT 'Schema ready' AS result;
