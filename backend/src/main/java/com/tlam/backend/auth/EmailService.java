package com.tlam.backend.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.resend.Resend;
import com.resend.core.exception.ResendException;
import com.resend.services.emails.model.CreateEmailOptions;
import com.resend.services.emails.model.CreateEmailResponse;
import com.tlam.backend.user.User;

import lombok.extern.slf4j.Slf4j;

/**
 * EmailService handles sending emails using Resend API
 * This service is responsible for sending welcome emails, password resets,
 * and other transactional emails to users.
 */
@Slf4j
@Service
public class EmailService {
    private final Resend resend;
    private final String fromEmail;

    public EmailService(@Value("${RESEND_API_KEY}") String apiKey, @Value("${FROM_EMAIL}") String fromEmail) {
        this.resend = new Resend(apiKey);
        this.fromEmail = fromEmail;
    }

    // Send a welcome email to the user
    public boolean sendWelcomeEmail(User user) {
        try {
            log.info("Sending welcome email to: {}", user.getEmail());

            CreateEmailOptions params = CreateEmailOptions.builder()
                .from(fromEmail)
                .to(user.getEmail())
                .subject("Welcome to PokeCollect!")
                .html(buildWelcomeEmailHTML(user))
                .build();

            CreateEmailResponse data = resend.emails().send(params);
            log.info("Welcome email sent successfully to {}: {}", user.getEmail(), data.getId());
            return true;
        } catch (ResendException e) {
            log.error("Failed to send welcome email to {}: {}", user.getEmail(), e.getMessage());
            return false;
        } catch (Exception e) {
            log.error("Unexpected error while sending welcome email to {}: {}", user.getEmail(), e.getMessage());
            return false;
        }
    }

    // Build the email content for the welcome email
    private String buildWelcomeEmailHTML(User user) {
        // Use String.replace() instead of formatted() to avoid issues with CSS semicolons
        String template = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="UTF-8">
            <title>Welcome to Pokémon Card Collection Tracker</title>
            </head>
            <body style="font-family: Arial, sans-serif; background-color: #f8f9fa; margin: 0; padding: 0;">
            <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                <td align="center" style="padding: 20px;">
                    <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
                    <tr style="background-color: #10b981;">
                        <td style="padding: 20px; text-align: center; color: #ffffff; font-size: 24px;">
                        Welcome to Pokémon Card Collection Tracker!
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 30px;">
                        <p style="font-size: 16px; color: #333333;">Hi <strong>{{USER_NAME}}</strong>,</p>
                        <p style="font-size: 16px; color: #333333;">Thanks for signing up with <strong>{{USER_EMAIL}}</strong>!</p>
                        <p style="font-size: 16px; color: #333333;">
                            We're thrilled to have you on board. With our app, you can:
                        </p>
                        <ul style="font-size: 16px; color: #333333;">
                            <li>📦 Manage your Pokémon card collection</li>
                            <li>🗂 Browse all English and Japanese TCG sets</li>
                            <li>🃏 View high-res images and card details</li>
                            <li>📊 Track your collection progress</li>
                        </ul>
                        <p style="font-size: 16px; color: #333333;">
                            Start exploring and organizing your collection now!
                        </p>
                        <p style="font-size: 16px; color: #333333;">Gotta catch 'em all!<br/>– The Tracker Team</p>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color: #f1f1f1; padding: 20px; text-align: center; font-size: 12px; color: #666666;">
                        If you did not sign up for this account, please ignore this email.
                        </td>
                    </tr>
                    </table>
                </td>
                </tr>
            </table>
            </body>
            </html>
            """;

        // Replace placeholders with actual values
        return template
            .replace("{{USER_NAME}}", user.getName())
            .replace("{{USER_EMAIL}}", user.getEmail());
    }
}
