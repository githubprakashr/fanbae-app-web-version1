# Magic Labs Email OTP Integration Setup Guide

## Overview
This guide will help you complete the Magic Labs email OTP verification integration for your Fanbae app.

## ✅ What Has Been Implemented

1. **Magic SDK Package** - Added to `pubspec.yaml`
2. **Email Input Field** - Added below mobile number field with OR divider
3. **Email OTP Flow** - Complete email authentication flow
4. **OTP Verification Page** - Updated to support both phone and email OTP
5. **Translation Keys** - Added all necessary locale strings

## 🔧 Setup Steps

### Step 1: Get Your Magic Labs API Key

1. Go to [Magic Labs Dashboard](https://dashboard.magic.link/)
2. Sign up or log in to your account
3. Create a new application
4. Copy your **Publishable API Key** (starts with `pk_live_` or `pk_test_`)

### Step 2: Configure Magic SDK

Update the Magic SDK initialization in **two files**:

#### File 1: `lib/webpages/weblogin.dart` (Line ~60)
```dart
/// Initialize Magic SDK (Replace with your actual Magic Publishable API Key)
void _initMagicSDK() {
  try {
    // TODO: Replace with your actual Magic Labs Publishable API Key
    // Get your API key from https://dashboard.magic.link/
    magic = Magic("pk_live_YOUR_MAGIC_PUBLISHABLE_KEY");  // ⚠️ REPLACE THIS
    printLog("Magic SDK initialized successfully");
  } catch (e) {
    printLog("Error initializing Magic SDK: $e");
  }
}
```

#### File 2: `lib/webpages/webotp.dart` (Line ~70)
```dart
/// Initialize Magic SDK
void _initMagicSDK() {
  try {
    // TODO: Replace with your actual Magic Labs Publishable API Key
    magic = Magic("pk_live_YOUR_MAGIC_PUBLISHABLE_KEY");  // ⚠️ REPLACE THIS
    printLog("Magic SDK initialized in OTP page");
  } catch (e) {
    printLog("Error initializing Magic SDK in OTP: $e");
  }
}
```

**Replace `pk_live_YOUR_MAGIC_PUBLISHABLE_KEY` with your actual key in both files.**

### Step 3: Install Dependencies

Run the following command in your terminal:

```bash
flutter pub get
```

### Step 4: Update Backend API (if needed)

The login API call in `webotp.dart` sends:
- Login type: `"1"` for phone, `"2"` for email
- Email parameter when login type is email
- Mobile parameter when login type is phone

Ensure your backend API supports email login with type `"2"`.

## 🎯 How It Works

### User Flow:

1. **Login Page** (`weblogin.dart`):
   - User can enter either mobile number OR email
   - If mobile: Traditional phone OTP flow
   - If email: Magic Labs passwordless email OTP

2. **Email OTP Flow**:
   - User enters email address
   - Magic Labs sends OTP link to email
   - User clicks link or enters code
   - App verifies with Magic Labs
   - Success → Login to app

3. **OTP Page** (`webotp.dart`):
   - Shows appropriate message based on login type
   - For email: Verifies with Magic Labs SDK
   - For phone: Uses existing phone OTP verification
   - After verification: Calls your backend login API

## 🔐 Security Notes

1. **Never expose your Secret Key** - Only use the Publishable API Key in the app
2. **Backend Verification** - For production, verify Magic tokens on your backend
3. **HTTPS Only** - Magic Labs requires HTTPS in production

## 📱 Testing

### Test Email Login:

1. Run the app
2. Navigate to login page
3. Enter an email address (instead of phone number)
4. Tap "Login"
5. Check your email for Magic Link
6. Click the link or enter the code
7. Verify successful login

### Test Phone Login:

1. Enter a phone number (leave email empty)
2. Tap "Login"
3. Enter OTP code "123456" (development mode)
4. Verify successful login

## 🐛 Troubleshooting

### "Magic SDK not initialized"
- Check that you replaced the API key in both files
- Verify your API key is correct
- Make sure `flutter pub get` was run

### "Failed to send email"
- Check internet connection
- Verify Magic Labs API key is valid
- Check Magic Labs dashboard for quota limits

### Email not received
- Check spam folder
- Verify email address is correct
- Check Magic Labs dashboard logs

## 📚 Additional Resources

- [Magic Labs Documentation](https://magic.link/docs)
- [Magic Labs Flutter SDK](https://magic.link/docs/auth/api-reference/client-side-sdks/flutter)
- [Magic Labs Dashboard](https://dashboard.magic.link/)

## 🚀 Production Checklist

- [ ] Replace test API key with production key
- [ ] Test email delivery on production domain
- [ ] Verify backend accepts email login (type "2")
- [ ] Add rate limiting for OTP requests
- [ ] Monitor Magic Labs usage/quota
- [ ] Test on iOS and Android devices
- [ ] Update privacy policy to mention Magic Labs

## 📝 Files Modified

1. `pubspec.yaml` - Added magic_sdk package
2. `lib/webpages/weblogin.dart` - Added email input and Magic Labs integration
3. `lib/webpages/webotp.dart` - Added email OTP verification
4. `assets/locales/en.json` - Added translation keys

## 💡 Tips

- Magic Labs provides 10,000 free monthly active users
- Email OTP is more user-friendly than remembering passwords
- Consider adding social login (Google/Apple) for even better UX
- You can customize the Magic Link email template in the dashboard

---

**Need Help?** Visit [Magic Labs Support](https://magic.link/docs/support) or check their Discord community.
