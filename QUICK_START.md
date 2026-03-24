# 🚀 Quick Start Guide - Email OTP Integration

## ⚡ Quick Setup (3 Steps)

### 1️⃣ Get Magic Labs API Key
```
1. Visit: https://dashboard.magic.link/
2. Sign up / Login
3. Create new app
4. Copy your Publishable API Key (pk_live_...)
```

### 2️⃣ Update Your Code
Replace in **2 files**:

**File: lib/webpages/weblogin.dart** (~line 60)
```dart
magic = Magic("YOUR_ACTUAL_API_KEY_HERE");
```

**File: lib/webpages/webotp.dart** (~line 70)
```dart
magic = Magic("YOUR_ACTUAL_API_KEY_HERE");
```

### 3️⃣ Install & Run
```bash
flutter pub get
flutter run
```

## ✅ That's It!

Your app now supports:
- ✉️ Email OTP login
- 📱 Phone OTP login (existing)
- 🔒 Passwordless authentication

## 🧪 Test It

1. Open app → Login page
2. Enter email: `test@example.com`
3. Tap "Login"
4. Check email inbox
5. Click Magic Link or enter code
6. ✨ Logged in!

## 📋 What Was Changed

| File | Changes |
|------|---------|
| `pubspec.yaml` | Added magic_sdk package |
| `weblogin.dart` | + Email field + Magic Labs |
| `webotp.dart` | + Email OTP verification |
| `en.json` | + Translation keys |

## 🎯 Key Features

✅ Email field below mobile number
✅ "OR" divider between options  
✅ Email validation
✅ Magic Labs OTP
✅ Same OTP page for both
✅ Same login flow after verification
✅ All localized text

## 🔑 Important Notes

- Use **Publishable** key (pk_live_...) NOT Secret key
- Email validation happens automatically
- OTP page shows email instead of phone
- Login API type: "1" = phone, "2" = email
- Free tier: 10,000 monthly active users

## 📱 Backend API

Your backend should accept:
```dart
{
  "type": "2",              // "1" for phone, "2" for email
  "email": "user@email.com", // when type = 2
  "mobile": "",             // empty when type = 2
  "device_type": "3",
  "device_token": "...",
  "country_code": "",       // empty for email
  "country_name": ""        // empty for email
}
```

## 🆘 Common Issues

**Issue**: "Magic SDK not initialized"  
**Fix**: Add your API key in both files

**Issue**: Email not received  
**Fix**: Check spam folder, verify API key

**Issue**: Login fails  
**Fix**: Ensure backend accepts type "2" for email

## 📚 Full Documentation

See `MAGIC_LABS_SETUP.md` for complete details.

## 💡 Pro Tips

1. Test with your own email first
2. Check Magic Labs dashboard for logs
3. Customize email template in dashboard
4. Monitor usage quota
5. Add error tracking in production

---

**Ready to go!** 🚀 Replace the API keys and start testing!
