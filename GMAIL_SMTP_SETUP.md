# Gmail SMTP Setup Guide for OTP Service

## ⚠️ IMPORTANT: You MUST configure Gmail credentials before OTP will work!

The OTP service now uses **real Gmail SMTP** to send verification emails. Follow these steps:

## Step 1: Create a Gmail Account (if you don't have one)
- Go to https://accounts.google.com/signup
- Create a new Gmail account (or use an existing one)
- **Recommended**: Create a dedicated account like `straycare.noreply@gmail.com`

## Step 2: Enable 2-Step Verification
1. Go to https://myaccount.google.com/security
2. Scroll to "How you sign in to Google"
3. Click "2-Step Verification"
4. Follow the steps to enable it

## Step 3: Generate App Password
1. Go to https://myaccount.google.com/apppasswords
2. Select "Mail" as the app
3. Select "Other (Custom name)" as the device
4. Enter "StrayCare OTP Service"
5. Click "Generate"
6. **COPY the 16-character password** (e.g., `abcd efgh ijkl mnop`)

## Step 4: Update OTP Service Configuration

Open `lib/core/services/otp_service.dart` and update these lines:

```dart
static const String _gmailUsername = 'your-email@gmail.com'; // Replace with your Gmail
static const String _gmailPassword = 'your-app-password'; // Replace with the 16-char App Password
```

**Example:**
```dart
static const String _gmailUsername = 'straycare.noreply@gmail.com';
static const String _gmailPassword = 'abcd efgh ijkl mnop'; // Remove spaces: abcdefghijklmnop
```

## Step 5: Test the OTP Service

1. Run the app: `flutter run`
2. Go to Signup screen
3. Enter your email
4. Click "Verify"
5. Check your Gmail inbox (and spam folder)
6. You should receive a beautiful email with a 6-digit code!

## Troubleshooting

### "Authentication failed" error
- Make sure you're using an **App Password**, not your regular Gmail password
- Verify 2-Step Verification is enabled
- Remove any spaces from the App Password

### Emails going to spam
- This is normal for new sender accounts
- After a few successful sends, Gmail will trust the sender
- Tell users to check spam folder

### "Network error"
- Check your internet connection
- Make sure your firewall isn't blocking SMTP (port 587)

## Security Best Practices

⚠️ **NEVER commit Gmail credentials to Git!**

For production, use environment variables:
1. Create a `.env` file (add to `.gitignore`)
2. Use `flutter_dotenv` package
3. Load credentials from environment

## Alternative: Use SendGrid (Recommended for Production)

For better deliverability and security:
1. Sign up at https://sendgrid.com (free tier: 100 emails/day)
2. Get API key
3. Use SendGrid's API instead of Gmail SMTP

Let me know if you need help setting up SendGrid!
