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
        return """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Welcome to PokéCollect</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        line-height: 1.6;
                        color: #333;
                        max-width: 600px;
                        margin: 0 auto;
                        padding: 20px;
                        background-color: #f8f9fa;
                    }
                    .container {
                        background: white;
                        border-radius: 12px;
                        padding: 40px;
                        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                    }
                    .header {
                        text-align: center;
                        margin-bottom: 30px;
                    }
                    .logo {
                        background: linear-gradient(135deg, #10b981, #06b6d4);
                        color: white;
                        width: 80px;
                        height: 80px;
                        border-radius: 50%;
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 36px;
                        margin-bottom: 20px;
                    }
                    .title {
                        color: #1f2937;
                        font-size: 28px;
                        font-weight: bold;
                        margin: 0;
                    }
                    .subtitle {
                        color: #6b7280;
                        font-size: 16px;
                        margin: 8px 0 0 0;
                    }
                    .content {
                        margin: 30px 0;
                    }
                    .greeting {
                        font-size: 18px;
                        color: #1f2937;
                        margin-bottom: 20px;
                    }
                    .features {
                        background: #f9fafb;
                        border-radius: 8px;
                        padding: 24px;
                        margin: 24px 0;
                    }
                    .feature {
                        display: flex;
                        align-items: center;
                        margin-bottom: 16px;
                    }
                    .feature:last-child {
                        margin-bottom: 0;
                    }
                    .feature-icon {
                        background: #10b981;
                        color: white;
                        width: 32px;
                        height: 32px;
                        border-radius: 50%;
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 16px;
                        margin-right: 16px;
                        flex-shrink: 0;
                    }
                    .cta-button {
                        display: inline-block;
                        background: linear-gradient(135deg, #fbbf24, #f59e0b);
                        color: white;
                        text-decoration: none;
                        padding: 16px 32px;
                        border-radius: 8px;
                        font-weight: 600;
                        font-size: 16px;
                        text-align: center;
                        margin: 24px 0;
                    }
                    .footer {
                        text-align: center;
                        margin-top: 40px;
                        padding-top: 24px;
                        border-top: 1px solid #e5e7eb;
                        color: #6b7280;
                        font-size: 14px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <div class="logo">🧩</div>
                        <h1 class="title">Welcome to PokéCollect!</h1>
                        <p class="subtitle">Your Pokémon card collection journey starts here</p>
                    </div>
                    
                    <div class="content">
                        <p class="greeting">Hi %s!</p>
                        
                        <p>We're thrilled to have you join the PokéCollect community! Your account has been successfully created, and you're now ready to start building and tracking your Pokémon card collection.</p>
                        
                        <div class="features">
                            <div class="feature">
                                <div class="feature-icon">📦</div>
                                <div>
                                    <strong>Collection Management</strong><br>
                                    Add, update, and organize your cards by set and rarity
                                </div>
                            </div>
                            <div class="feature">
                                <div class="feature-icon">🗂</div>
                                <div>
                                    <strong>Set Browser</strong><br>
                                    Explore English and Japanese TCG sets with detailed card info
                                </div>
                            </div>
                            <div class="feature">
                                <div class="feature-icon">📊</div>
                                <div>
                                    <strong>Progress Tracking</strong><br>
                                    See your completion percentage for each set you collect
                                </div>
                            </div>
                        </div>
                        
                        <p>Ready to get started? Open the PokéCollect app and begin exploring sets or adding your first cards to your collection!</p>
                        
                        <p>If you have any questions or need help getting started, don't hesitate to reach out to our support team.</p>
                        
                        <p>Happy collecting!<br>
                        <strong>The PokéCollect Team</strong></p>
                    </div>
                    
                    <div class="footer">
                        <p>This email was sent to %s because you signed up for PokéCollect.</p>
                        <p>© 2025 PokéCollect. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>
            """.formatted(user.getName(), user.getEmail());
    }
}
