# Email OTP Integration Guide (Backend-Based)

## ✅ Implementation Complete!

Your app now supports **Email OTP login** alongside phone OTP login, using your own backend API.

## 🎯 How It Works

### User Flow:

1. **Login Page**:
   - User enters mobile number OR email
   - Clicks "Login" button

2. **Email OTP Flow**:
   - App validates email format
   - Sends OTP request to your backend
   - Backend sends OTP email to user
   - User receives OTP in email
   - Navigates to OTP verification page

3. **OTP Verification**:
   - User enters 6-digit OTP code
   - App verifies OTP with backend
   - On success: Logs in user
   - On failure: Shows error message

## 📝 What You Need to Implement

### 1. Backend API Endpoints

You need to create **2 backend API endpoints**:

#### **Endpoint 1: Send Email OTP**
```
POST /api/send-email-otp
Request Body:
{
  "email": "user@example.com"
}

Response:
{
  "status": 200,
  "message": "OTP sent successfully"
}
```

#### **Endpoint 2: Verify Email OTP**
```
POST /api/verify-email-otp
Request Body:
{
  "email": "user@example.com",
  "otp": "123456"
}

Response:
{
  "status": 200,
  "message": "OTP verified successfully",
  "isValid": true
}
```

### 2. Update GeneralProvider

Add these methods to your `GeneralProvider` class:

```dart
// Send email OTP
Future<void> sendEmailOTP(String email) async {
  try {
    final response = await dio.post(
      '${Constant.baseUrl}send-email-otp',
      data: {
        'email': email,
      },
    );
    
    if (response.statusCode == 200) {
      printLog('Email OTP sent successfully');
    }
  } catch (e) {
    printLog('Error sending email OTP: $e');
    rethrow;
  }
}

// Verify email OTP
Future<bool> verifyEmailOTP(String email, String otp) async {
  try {
    final response = await dio.post(
      '${Constant.baseUrl}verify-email-otp',
      data: {
        'email': email,
        'otp': otp,
      },
    );
    
    if (response.statusCode == 200 && response.data['isValid'] == true) {
      return true;
    }
    return false;
  } catch (e) {
    printLog('Error verifying email OTP: $e');
    return false;
  }
}
```

### 3. Update weblogin.dart

Replace the TODO comment in `_handleEmailLogin()` method (~line 547):

```dart
// Replace this:
// TODO: Call your backend API to send email OTP
await Future.delayed(const Duration(seconds: 1));

// With this:
await generalProvider.sendEmailOTP(email);
```

### 4. Update webotp.dart

Replace the TODO comment in `_sendOTP()` method (~line 352):

```dart
if (widget.loginType == 'email') {
  // Replace this:
  // TODO: Send email OTP via your backend API
  await Future.delayed(const Duration(seconds: 1));
  
  // With this:
  await generalProvider.sendEmailOTP(widget.email);
  printLog("Email OTP sent to: ${widget.email}");
}
```

### 5. Update OTP Verification

In `webotp.dart`, uncomment the production code in `_validateAndLogin()` (~line 395):

```dart
// Uncomment this production code block and implement:
generalProvider.setLoading(true);

try {
  // Verify OTP with backend
  final isValid = await generalProvider.verifyEmailOTP(
    widget.loginType == 'email' ? widget.email : widget.number,
    pinPutController.text.trim(),
  );
  
  if (isValid) {
    final identifier = widget.loginType == 'email' ? widget.email : widget.number.toString();
    _login(identifier, strDeviceToken ?? "");
  } else {
    generalProvider.setLoading(false);
    Utils().showSnackBar(context, "otpinvalid", true);
  }
} catch (e) {
  generalProvider.setLoading(false);
  Utils().showSnackBar(context, "otpverificationfailed", true);
}
```

## 🧪 Testing

### Current Testing Mode:
- **Hardcoded OTP**: `123456`
- **Phone login**: Works with hardcoded OTP
- **Email login**: Works with hardcoded OTP

### Steps to Test Now:
1. Run the app
2. Navigate to login page
3. Enter email address
4. Click "Login"
5. On OTP page, enter: `123456`
6. Should login successfully

## 📧 Email Template Example

Your backend should send HTML emails like:

```html
Subject: Your Login OTP

Hello,

Your one-time password (OTP) for login is:

<h2 style="color: #007bff;">123456</h2>

This OTP is valid for 10 minutes.

If you didn't request this, please ignore this email.

Thanks,
Fanbae Team
```

## 🔐 Backend Implementation Tips

### Email Service Options:
- **SendGrid** - Easy to use, free tier available
- **AWS SES** - Cost-effective, reliable
- **Mailgun** - Developer-friendly API
- **SMTP** - Use your own email server

### OTP Generation:
```javascript
// Node.js example
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}
```

### OTP Storage:
- Store in Redis with 10-minute expiration
- Or store in database with timestamp
- Limit to 3 attempts per email

### Security:
- Rate limit OTP requests (max 3 per email per hour)
- Expire OTPs after 10 minutes
- Hash OTPs before storing
- Lock account after 5 failed attempts

## 📋 Files Modified

1. ✅ `pubspec.yaml` - Removed magic_sdk
2. ✅ `lib/webpages/weblogin.dart` - Email input + OTP sending
3. ✅ `lib/webpages/webotp.dart` - Email OTP verification
4. ✅ `assets/locales/en.json` - Translation keys

## 🎨 Features

✅ **Email TextField** - Below mobile number with OR divider  
✅ **Email Validation** - Validates format before sending  
✅ **OTP Page** - Shows email instead of phone for email login  
✅ **Unified Experience** - Same flow for both phone and email  
✅ **Resend OTP** - 60-second countdown timer  
✅ **Error Handling** - All error cases covered  
✅ **Localization** - All text in locale files  

## 🚀 Production Checklist

- [ ] Implement backend email OTP endpoints
- [ ] Update GeneralProvider with email OTP methods
- [ ] Replace hardcoded OTP verification
- [ ] Test with real email service
- [ ] Add rate limiting
- [ ] Set up email templates
- [ ] Configure SPF/DKIM for email domain
- [ ] Test spam folder delivery
- [ ] Add analytics tracking
- [ ] Update privacy policy

## 💡 Next Steps

1. **Set up email service** (SendGrid/AWS SES/etc.)
2. **Create backend API endpoints** for send/verify OTP
3. **Update GeneralProvider** with email OTP methods
4. **Replace TODO comments** in code with actual API calls
5. **Test end-to-end** with real emails
6. **Deploy to production**

---

**Need Help?**  
Check the inline TODO comments in:
- `lib/webpages/weblogin.dart` (line ~547)
- `lib/webpages/webotp.dart` (lines ~352, ~395)
