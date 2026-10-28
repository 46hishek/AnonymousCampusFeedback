
package edu.campus.feedback.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Opens MySQL connections. The URL, user and password come from
 * src/main/resources/campus-feedback.properties (see AppConfig).
 */
public class DBConnection {

    private DBConnection() {
        // Prevent object creation
    }

    public static Connection getConnection()
            throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL JDBC driver not found. Check the Maven dependency.",
                e
            );
        }

        String url = AppConfig.get("db.url",
            "jdbc:mysql://localhost:3306/campus_feedback"
            + "?useUnicode=true&characterEncoding=UTF-8");
        String user = AppConfig.get("db.user", "root");
        String password = AppConfig.get("db.password", "");

        return DriverManager.getConnection(url, user, password);
    }
}
