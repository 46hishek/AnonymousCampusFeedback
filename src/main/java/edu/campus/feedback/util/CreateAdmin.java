
package edu.campus.feedback.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Scanner;

import org.mindrot.jbcrypt.BCrypt;

public class CreateAdmin {

    public static void main(String[] args) {

        Scanner scanner = new Scanner(System.in);

        System.out.print("Enter admin username: ");
        String username = scanner.nextLine().trim();

        System.out.print("Enter admin e-mail (used for password reset): ");
        String email = scanner.nextLine().trim();

        System.out.print("Enter admin password: ");
        String password = scanner.nextLine();

        if (!username.matches("[A-Za-z0-9_]{4,50}")) {
            System.out.println(
                "Username must be 4-50 characters: letters, numbers or underscore."
            );
            scanner.close();
            return;
        }

        if (email.length() > 254
                || !email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            System.out.println("Please enter a valid e-mail address.");
            scanner.close();
            return;
        }

        if (password.length() < 12 || password.length() > 72) {
            System.out.println(
                "Password must be between 12 and 72 characters."
            );
            scanner.close();
            return;
        }

        String passwordHash = BCrypt.hashpw(
            password, BCrypt.gensalt(12)
        );

        String sql = """
            INSERT INTO admin_users (username, email, password_hash)
            VALUES (?, ?, ?)
            """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                 connection.prepareStatement(sql)) {

            statement.setString(1, username);
            statement.setString(2, email);
            statement.setString(3, passwordHash);

            statement.executeUpdate();

            System.out.println(
                "Admin account created successfully!"
            );

        } catch (SQLException e) {
            if ("23000".equals(e.getSQLState())) {
                System.out.println(
                    "Username or e-mail already exists."
                );
            } else {
                System.out.println(
                    "Could not create admin account: " + e.getMessage()
                );
            }
        } finally {
            scanner.close();
        }
    }
}
