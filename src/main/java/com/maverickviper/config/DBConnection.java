package com.maverickviper.config;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    private static volatile boolean schemaInitialized = false;

    public static Connection getConnection() {
        Connection connection = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            String jdbcUrl = null;
            String user = null;
            String password = null;

            // 1. Check for cloud database URL (Render, Railway, TiDB, Aiven, etc.)
            String envUrl = System.getenv("MYSQL_URL");
            if (envUrl == null || envUrl.isBlank()) {
                envUrl = System.getenv("DATABASE_URL");
            }
            if (envUrl == null || envUrl.isBlank()) {
                envUrl = System.getenv("DB_URL");
            }

            if (envUrl != null && !envUrl.isBlank()) {
                envUrl = envUrl.trim();
                if (envUrl.startsWith("jdbc:mysql://")) {
                    jdbcUrl = envUrl;
                } else if (envUrl.startsWith("mysql://")) {
                    try {
                        URI uri = new URI(envUrl.replace("mysql://", "http://"));
                        String host = uri.getHost();
                        int port = uri.getPort() == -1 ? 3306 : uri.getPort();
                        String path = uri.getPath();
                        String dbName = (path != null && path.length() > 1) ? path.substring(1) : "maverick_viper";
                        String userInfo = uri.getUserInfo();
                        if (userInfo != null && userInfo.contains(":")) {
                            String[] parts = userInfo.split(":", 2);
                            user = URLDecoder.decode(parts[0], StandardCharsets.UTF_8);
                            password = URLDecoder.decode(parts[1], StandardCharsets.UTF_8);
                        } else if (userInfo != null) {
                            user = URLDecoder.decode(userInfo, StandardCharsets.UTF_8);
                        }

                        String query = uri.getQuery();
                        StringBuilder params = new StringBuilder("?allowPublicKeyRetrieval=true&autoReconnect=true&characterEncoding=UTF-8&serverTimezone=UTC");
                        if (query != null && !query.isBlank()) {
                            params.append("&").append(query);
                        } else if (host != null && (host.contains("tidbcloud.com") || host.contains("aivencloud.com"))) {
                            params.append("&sslMode=VERIFY_IDENTITY");
                        } else {
                            params.append("&useSSL=false");
                        }
                        jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName + params.toString();
                    } catch (Exception ex) {
                        System.err.println("Could not parse mysql:// URL, falling back: " + ex.getMessage());
                        jdbcUrl = envUrl.replace("mysql://", "jdbc:mysql://");
                    }
                }
            }

            // 2. Check for individual host/port/user/password variables or default to local MySQL
            if (jdbcUrl == null) {
                String host = getEnv("MYSQLHOST", getEnv("DB_HOST", "localhost"));
                String port = getEnv("MYSQLPORT", getEnv("DB_PORT", "3306"));
                String dbName = getEnv("MYSQLDATABASE", getEnv("DB_NAME", "maverick_viper"));
                user = getEnv("MYSQLUSER", getEnv("DB_USER", "root"));
                password = getEnv("MYSQLPASSWORD", getEnv("DB_PASSWORD", "Pass@123"));
                String ssl = getEnv("DB_SSL", "false");

                String sslParam = "true".equalsIgnoreCase(ssl) ? "&useSSL=true" : "&useSSL=false";
                if (host != null && host.contains("tidbcloud.com")) {
                    sslParam = "&sslMode=VERIFY_IDENTITY";
                }

                jdbcUrl = "jdbc:mysql://" + host + ":" + port + "/" + dbName
                        + "?allowPublicKeyRetrieval=true&autoReconnect=true&characterEncoding=UTF-8&serverTimezone=UTC"
                        + sslParam;
            }

            if (user != null && password != null) {
                connection = DriverManager.getConnection(jdbcUrl, user, password);
            } else {
                connection = DriverManager.getConnection(jdbcUrl);
            }

            // Auto-create database tables and seed data if connecting to a fresh remote DB
            if (!schemaInitialized && connection != null) {
                synchronized (DBConnection.class) {
                    if (!schemaInitialized) {
                        initSchemaIfRequired(connection);
                        schemaInitialized = true;
                    }
                }
            }

        } catch (ClassNotFoundException | SQLException e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }

        return connection;
    }

    private static String getEnv(String name, String fallback) {
        String val = System.getenv(name);
        return (val != null && !val.isBlank()) ? val.trim() : fallback;
    }

    private static void initSchemaIfRequired(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            // 1. Admins table
            stmt.execute("CREATE TABLE IF NOT EXISTS admins ("
                    + "admin_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "username VARCHAR(50) NOT NULL UNIQUE, "
                    + "password_hash VARCHAR(255) NOT NULL"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 2. Courses table
            stmt.execute("CREATE TABLE IF NOT EXISTS courses ("
                    + "course_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "course_name VARCHAR(200) NOT NULL, "
                    + "course_code VARCHAR(50) DEFAULT NULL, "
                    + "description TEXT, "
                    + "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 3. Students table
            stmt.execute("CREATE TABLE IF NOT EXISTS students ("
                    + "student_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "full_name VARCHAR(100) NOT NULL, "
                    + "email VARCHAR(150) NOT NULL UNIQUE, "
                    + "password_hash VARCHAR(255) NOT NULL, "
                    + "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "last_login TIMESTAMP NULL DEFAULT NULL"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 4. Weeks table
            stmt.execute("CREATE TABLE IF NOT EXISTS weeks ("
                    + "week_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "course_id INT NOT NULL, "
                    + "week_number INT NOT NULL, "
                    + "week_name VARCHAR(150) NOT NULL, "
                    + "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "UNIQUE KEY uq_course_week (course_id, week_number)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 5. Questions table
            stmt.execute("CREATE TABLE IF NOT EXISTS questions ("
                    + "question_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "course_id INT NOT NULL, "
                    + "week_id INT DEFAULT NULL, "
                    + "week_number INT NOT NULL, "
                    + "question_text TEXT NOT NULL, "
                    + "option_a VARCHAR(500) NOT NULL, "
                    + "option_b VARCHAR(500) NOT NULL, "
                    + "option_c VARCHAR(500) NOT NULL, "
                    + "option_d VARCHAR(500) NOT NULL, "
                    + "correct_option CHAR(1) NOT NULL, "
                    + "category VARCHAR(50) DEFAULT 'WEEKWISE', "
                    + "explanation TEXT, "
                    + "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
                    + "KEY idx_course_id (course_id)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 6. Tests table
            stmt.execute("CREATE TABLE IF NOT EXISTS tests ("
                    + "test_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "course_id INT NOT NULL, "
                    + "test_name VARCHAR(255) NOT NULL, "
                    + "test_type VARCHAR(50) NOT NULL, "
                    + "week_id INT DEFAULT NULL, "
                    + "duration_minutes INT DEFAULT 30, "
                    + "marks_per_question DECIMAL(5,2) DEFAULT 1.00, "
                    + "negative_marks DECIMAL(5,2) DEFAULT 0.00, "
                    + "shuffle_options TINYINT(1) DEFAULT 0, "
                    + "total_questions INT DEFAULT 0, "
                    + "created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "KEY idx_test_type (test_type)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 7. Test Questions table
            stmt.execute("CREATE TABLE IF NOT EXISTS test_questions ("
                    + "id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "test_id INT NOT NULL, "
                    + "question_id INT NOT NULL, "
                    + "question_order INT DEFAULT 1, "
                    + "KEY idx_test (test_id), "
                    + "KEY idx_question (question_id)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 8. Test Attempts table
            stmt.execute("CREATE TABLE IF NOT EXISTS test_attempts ("
                    + "attempt_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "student_id INT NOT NULL, "
                    + "test_id INT DEFAULT NULL, "
                    + "test_name VARCHAR(255) NOT NULL, "
                    + "test_type VARCHAR(50) NOT NULL, "
                    + "total_questions INT DEFAULT 0, "
                    + "attempted INT DEFAULT 0, "
                    + "correct INT DEFAULT 0, "
                    + "incorrect INT DEFAULT 0, "
                    + "unanswered INT DEFAULT 0, "
                    + "score DECIMAL(6,2) DEFAULT 0.00, "
                    + "accuracy DECIMAL(5,2) DEFAULT 0.00, "
                    + "percentage DECIMAL(5,2) DEFAULT 0.00, "
                    + "started_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "completed_at TIMESTAMP NULL DEFAULT NULL, "
                    + "status VARCHAR(20) DEFAULT 'IN_PROGRESS', "
                    + "KEY idx_student_attempt (student_id), "
                    + "KEY idx_attempt_status (status)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 9. Student Answers table
            stmt.execute("CREATE TABLE IF NOT EXISTS student_answers ("
                    + "answer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "attempt_id INT NOT NULL, "
                    + "question_id INT NOT NULL, "
                    + "selected_option VARCHAR(5) DEFAULT NULL, "
                    + "correct_option_snapshot VARCHAR(5) NOT NULL, "
                    + "is_correct TINYINT(1) DEFAULT 0, "
                    + "question_text_snapshot TEXT NOT NULL, "
                    + "option_a_snapshot TEXT NOT NULL, "
                    + "option_b_snapshot TEXT NOT NULL, "
                    + "option_c_snapshot TEXT NOT NULL, "
                    + "option_d_snapshot TEXT NOT NULL, "
                    + "explanation_snapshot TEXT, "
                    + "answered_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "KEY idx_attempt_answer (attempt_id), "
                    + "KEY idx_q_answer (question_id)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 10. Login History table
            stmt.execute("CREATE TABLE IF NOT EXISTS login_history ("
                    + "login_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "student_id INT NOT NULL, "
                    + "login_time TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, "
                    + "logout_time TIMESTAMP NULL DEFAULT NULL, "
                    + "status VARCHAR(50) DEFAULT 'SUCCESS', "
                    + "KEY idx_student_login (student_id)"
                    + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // Seed Admin if not exists
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM admins")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO admins (username, password_hash) VALUES ('admin', '7676aaafb027c825bd9abab78b234070e702752f625b752e55e55b48e607e358')");
                    System.out.println("Default admin initialized: admin / admin@123");
                }
            }

            // Seed Course if not exists
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM courses")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO courses (course_id, course_name, course_code, description) VALUES (1, 'foundation of digital business', 'none', '.')");
                }
            }

            // Seed Weeks 0-12 if not exists
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM weeks")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    String[] weekNames = {
                        "Week 0 - Introduction & Foundations",
                        "Week 1 - Digital Business Concepts",
                        "Week 2 - Digital Business Models",
                        "Week 3 - Digital Platforms & Ecosystems",
                        "Week 4 - Cloud & Digital Infrastructure",
                        "Week 5 - Data Analytics & AI in Business",
                        "Week 6 - Customer Experience & Marketing",
                        "Week 7 - Digital Operations & Supply Chain",
                        "Week 8 - Digital Strategy & Transformation",
                        "Week 9 - Security, Ethics & Governance",
                        "Week 10 - Emerging Technologies & Fintech",
                        "Week 11 - Digital Innovation & Disruption",
                        "Week 12 - Digital Enterprise & Future Trends"
                    };
                    for (int w = 0; w <= 12; w++) {
                        stmt.executeUpdate("INSERT INTO weeks (course_id, week_number, week_name) VALUES (1, " + w + ", '" + weekNames[w] + "')");
                    }
                    System.out.println("Default weeks 0-12 initialized.");
                }
            }

            // Seed Default Student if not exists
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM students")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    stmt.executeUpdate("INSERT INTO students (full_name, email, password_hash) VALUES ('Tanesh Adhane', 'rupeshadhane09@gmail.com', 'b6bc7b58510319a151d168ba3d5aecb3ac0a9708d06dd930f37fbc89b6cdc697')");
                    System.out.println("Default student initialized: rupeshadhane09@gmail.com / Pass@123");
                }
            }

        } catch (SQLException e) {
            System.err.println("Schema auto-init check: " + e.getMessage());
        }
    }
}