package edu.campus.feedback.util;

import java.util.Scanner;

/**
 * Checks your e-mail settings without the website.
 * In Eclipse: right-click this file > Run As > Java Application,
 * then type the address that should receive the test message.
 */
public class MailTest {

    public static void main(String[] args) {

        if (!EmailService.isConfigured()) {
            System.out.println(
                "E-mail is NOT configured. Fill mail.username and "
                + "mail.app.password in campus-feedback.properties.");
            return;
        }

        try (Scanner scanner = new Scanner(System.in)) {
            System.out.print("Send test e-mail to: ");
            String to = scanner.nextLine().trim();

            EmailService.sendTest(to);
            System.out.println("SUCCESS - test e-mail sent to " + to
                + ". Check the inbox (and spam).");
        } catch (Exception e) {
            System.out.println("FAILED - " + EmailService.describeFailure(e));
        }
    }
}
