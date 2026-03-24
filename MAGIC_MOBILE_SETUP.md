# Magic Labs Mobile Integration - Setup Guide

## ✅ What Has Been Implemented

Magic Labs SDK has been successfully integrated into the **mobile app** (login.dart).

### Changes Made:

1. **Added Magic SDK Package** - `magic_sdk: ^4.1.0` added to pubspec.yaml
2. **Initialized Magic SDK** - Added in `_initMagicSDK()` method
3. **Email Authentication** - Uses Magic Labs for passwordless email login
4. **Backend Integration** - After Magic verification, logs in with type "5"
5. **User Data Saved** - Saves user credentials from backend response

## 🔧 Setup Steps

### Step 1: Get Your Magic Labs API Key

1. Go to [Magic Labs Dashboard](https://dashboard.magic.link/)
2. Sign up or log in to your account
3. Create a new application (or use existing one)
4. Copy your **Publishable API Key** (starts with `pk_live_` or `pk_test_`)

### Step 2: Configure Magic SDK

Update the Magic SDK initialization in **`lib/pages/login.dart`** (around line 60):

```dart
/// Initialize Magic SDK
void _initMagicSDK() {
  try {
    // TODO: Replace with your actual Magic Labs Publishable API Key
    // Get your API key from https://dashboard.magic.link/
    magic = Magic('pk_live_YOUR_MAGIC_PUBLISHABLE_KEY');  // ⚠️ REPLACE THIS
    printLog("✅ Magic SDK initialized successfully");
  } catch (e) {
    printLog("❌ Error initializing Magic SDK: $e");
  }
}
```

**Replace `pk_live_YOUR_MAGIC_PUBLISHABLE_KEY` with your actual Magic API key.**

### Step 3: Test the Integration

1. Run the app on a mobile device or emulator
2. Navigate to the login screen
3. Enter an email address
4. Magic Labs will send an email with a magic link
5. Click the link in your email (or it may auto-verify)
6. The app will automatically log you in with type "5"

## 🎯 How It Works

### User Flow:

1. **Login Page** (`login.dart`):
   - User enters email address
   - App validates email format
   - Calls Magic Labs SDK: `magic.auth.loginWithEmailOTP(email: email)`

2. **Magic Labs Authentication**:
   - Magic sends email with magic link to user
   - User clicks link or enters OTP code
   - Magic returns authentication token

3. **Backend Login**:
   - App receives Magic token
   - Calls your backend API with type "5" (Magic Labs)
   - Backend creates/updates user account
   - App saves user credentials locally
   - Navigates to home screen (Bottombar)

## 📱 Platform Support

### Mobile (Android/iOS):
- ✅ Magic SDK fully integrated
- ✅ Email OTP authentication
- ✅ Type "5" backend login
- ✅ User credentials saved

### Web:
- ✅ Magic Labs JavaScript SDK integrated in weblogin.dart
- ✅ Uses same type "5" backend login

## 🔐 Security Notes

1. **Never expose your Secret Key** - Only use the Publishable API Key
2. **API Key is safe in mobile apps** - The publishable key is designed to be used in client apps
3. **Backend Verification** - For production, consider verifying Magic tokens on your backend for additional security

## 🔍 Backend API Requirements

Your backend login API should accept these parameters for type "5":

```dart
await provider.login(
  "5",                    // Type 5 = Magic Labs Email OTP
  email,                  // User's email address
  "",                     // Mobile (empty for email login)
  strDeviceType ?? "",    // Device type (1=Android, 2=iOS)
  strDeviceToken ?? "",   // Device token for push notifications
  "",                     // Country code (empty for email login)
  "",                     // Country name (empty for email login)
);
```

## 🐛 Troubleshooting

### Magic SDK not initialized
- Ensure you've replaced the placeholder API key with your actual key
- Check that the API key is valid and active in Magic dashboard

### Email not received
- Check spam/junk folder
- Verify email address is correct
- Check Magic dashboard for delivery logs

### Login fails after Magic authentication
- Ensure your backend API supports type "5" login
- Check that backend is creating/finding user by email
- Review backend API response in logs

## 📝 Additional Notes

- The same Magic API key can be used for both web and mobile
- Magic handles email deliverability and link generation
- Users don't need to create passwords
- Magic authentication is secure and encrypted
- The integration works on both iOS and Android

## 🎉 You're All Set!

Once you've added your Magic API key, the mobile app will have passwordless email authentication working seamlessly!
