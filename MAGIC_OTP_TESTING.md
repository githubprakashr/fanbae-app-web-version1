# Magic Labs OTP Integration - Testing Guide

## ✅ What Was Fixed

The static OTP "123456" has been **completely removed for email authentication**. Now the app uses **real Magic Labs OTP** for email login.

## 🔄 How It Works Now

### Email OTP Flow (Magic Labs):
1. User enters email address → clicks "Continue"
2. **Magic Labs sends a real OTP code to the email**
3. User checks their email inbox for the OTP
4. User enters the **6-digit OTP code** from the email
5. App verifies the code with Magic Labs API
6. ✅ If valid → User is logged in
7. ❌ If invalid → Shows "Invalid OTP code" error

### Phone OTP Flow (Temporary):
- Still uses "123456" as a placeholder
- Replace with real SMS provider (Twilio, Firebase Auth, etc.) later

## 📝 Testing Instructions

### On Web (Flutter Web):
1. Build and run: `flutter run -d chrome --web-renderer html`
2. Enter a valid email address
3. Check the email inbox for OTP from Magic Labs
4. Enter the OTP code (should be 6 digits)
5. Verify login works

### On Mobile (Android/iOS):
- Uses simulated OTP (still "123456") for testing
- Real Magic SDK integration requires Flutter web platform

## 🔍 Console Logs to Watch

When testing, check browser console for:
- `✅ Magic initialized`
- `📧 Sending Magic email OTP to: user@example.com`
- `✅ Magic OTP email sent successfully`
- `🔐 Verifying Magic OTP code: XXXXXX`
- `✅ OTP verified successfully!`

## ⚠️ Common Issues

### 1. "Magic SDK not initialized"
- Check that `magic_helper.js` is loaded in `index.html`
- Verify Magic SDK script: `<script src="https://auth.magic.link/sdk"></script>`

### 2. "Failed to send email verification"
- Check Magic API key: `pk_live_8E2F3F0BBA90BD08`
- Verify email format is valid
- Check network connection

### 3. "Invalid OTP code"
- User entered wrong OTP
- OTP may have expired (usually 10-15 minutes validity)
- Click "Resend" to get a new OTP

## 🔧 Code Changes Made

### Files Modified:
1. **`web/magic_helper.js`**
   - `sendMagicEmailOTP()` - Sends OTP email via Magic
   - `verifyMagicOTP()` - Verifies entered OTP code

2. **`lib/pages/login.dart`**
   - `_handleEmailLogin()` - Triggers OTP sending
   - `_verifyMagicOTPAndLogin()` - Verifies OTP with Magic
   - `codeSend()` - Handles resend functionality
   - `_checkOTPAndLogin()` - Routes to correct verification method

## 🎯 Key Features

✅ Real OTP emails sent by Magic Labs  
✅ Custom UI for OTP entry (no Magic popup)  
✅ OTP resend functionality  
✅ Proper error handling  
✅ Loading states during verification  
✅ No more static "123456" for email OTP  

## 📧 Email Example

When user requests OTP, Magic Labs sends an email like:

```
Subject: Your verification code

Your verification code is: 123456

This code expires in 10 minutes.
```

## 🚀 Next Steps

1. **Test on web platform** with real email addresses
2. **Verify OTP delivery** to various email providers (Gmail, Outlook, etc.)
3. **Test resend functionality**
4. **Check spam folders** if emails don't arrive
5. **Monitor Magic Labs dashboard** for authentication logs

## 📚 Resources

- [Magic Labs Documentation](https://magic.link/docs)
- [Magic Auth API](https://magic.link/docs/auth/api-reference/client-side-sdks/web)
- [Magic Dashboard](https://dashboard.magic.link/)
