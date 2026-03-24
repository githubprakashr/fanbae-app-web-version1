# Mobile Email OTP Integration Guide

Since Magic Labs doesn't have native mobile SDK support, here are your options for email OTP on Android/iOS:

---

## Option 1: Firebase Auth Email Link (RECOMMENDED)

### Benefits:
✅ Official Flutter support  
✅ Free tier available  
✅ Easy to implement  
✅ Passwordless authentication  

### Setup Steps:

#### 1. Add Firebase Auth (already in pubspec.yaml):
```yaml
dependencies:
  firebase_auth: ^4.12.1
  firebase_core: ^2.32.0
```

#### 2. Add method to login.dart:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Add this method after _handleEmailLogin()
Future<void> _sendFirebaseEmailLink(String email) async {
  try {
    final auth = FirebaseAuth.instance;
    
    // Configure action code settings
    var acs = ActionCodeSettings(
      url: 'https://yourapp.page.link/emailauth',  // Your deep link
      handleCodeInApp: true,
      androidPackageName: 'com.your.app',  // Your Android package
      androidInstallApp: true,
      androidMinimumVersion: '21',
      iOSBundleId: 'com.your.app',  // Your iOS bundle ID
    );

    await auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);
    
    // Save email for verification
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailForSignIn', email);
    
    generalProvider.setLoading(false);
    
    if (mounted) {
      setState(() {
        emailForOTP = email;
        isOTP = true;
        isEmailOTP = true;
      });
      Utils().showSnackBar(context, "Check your email for sign-in link", false);
    }
  } catch (e) {
    generalProvider.setLoading(false);
    printLog("Firebase email link error: $e");
    if (mounted) {
      Utils().showSnackBar(context, "Failed to send email link", false);
    }
  }
}

// Add OTP verification for Firebase
Future<void> _verifyFirebaseEmailLink() async {
  try {
    final auth = FirebaseAuth.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('emailForSignIn');
    
    if (email == null) {
      throw Exception("Email not found");
    }

    // Verify with Firebase
    final credential = await auth.signInWithEmailLink(
      email: email, 
      emailLink: "link-from-email"  // Get from deep link
    );

    if (credential.user != null) {
      // Login successful, proceed with backend
      await _verifyEmailOTPAndLogin();
    }
  } catch (e) {
    generalProvider.setLoading(false);
    printLog("Firebase verification error: $e");
    if (mounted) {
      Utils().showSnackBar(context, "Invalid verification link", false);
    }
  }
}
```

#### 3. Update _handleEmailLogin() else block:

```dart
} else {
  // For mobile platforms, use Firebase Auth
  printLog("📱 Mobile: Using Firebase Auth for email authentication");
  await _sendFirebaseEmailLink(email);
}
```

#### 4. Configure Deep Links:
- Add deep link handling in AndroidManifest.xml and Info.plist
- Handle incoming links in app

---

## Option 2: Custom Email OTP with Twilio SendGrid

### Benefits:
✅ Full control over email templates  
✅ Works on all platforms  
✅ Can use existing backend  

### Setup Steps:

#### 1. Backend generates and sends OTP via email

#### 2. Update _handleEmailLogin() else block:

```dart
} else {
  // For mobile platforms, send OTP via backend
  printLog("📱 Mobile: Sending OTP via backend email service");
  
  try {
    // Call backend API to send OTP email
    await generalProvider.sendEmailOTP(email);
    
    generalProvider.setLoading(false);
    
    if (mounted) {
      setState(() {
        emailForOTP = email;
        isOTP = true;
        isEmailOTP = true;
      });
      Utils().showSnackBar(context, "OTP sent to your email", false);
    }
  } catch (e) {
    generalProvider.setLoading(false);
    printLog("Failed to send OTP: $e");
    if (mounted) {
      Utils().showSnackBar(context, "Failed to send OTP", false);
    }
  }
}
```

#### 3. Update _verifyMagicOTPAndLogin() else block:

```dart
} else {
  // For mobile platforms, verify with backend
  printLog("📱 Mobile: Verifying OTP with backend");
  
  try {
    // Call backend API to verify OTP
    final verified = await generalProvider.verifyEmailOTP(emailForOTP, otpCode);
    
    if (verified) {
      await _verifyEmailOTPAndLogin();
    } else {
      generalProvider.setLoading(false);
      Utils().showSnackBar(context, "Invalid OTP code", false);
    }
  } catch (e) {
    generalProvider.setLoading(false);
    printLog("OTP verification error: $e");
    if (mounted) {
      Utils().showSnackBar(context, "Failed to verify OTP", false);
    }
  }
}
```

---

## Option 3: Keep Web-Only (Simplest)

If you want to keep it simple, just guide mobile users to use:
- **Phone number login** (already implemented with "123456" OTP)
- **Google Sign-In** (already implemented)

Current implementation shows: "Email login is only available on web. Please use phone or Google login."

---

## Recommendation

**For production app:**
1. **Web**: Use Magic Labs (already done) ✅
2. **Mobile**: 
   - Use **Firebase Auth Email Link** (easiest) 
   - OR implement **custom OTP via backend**
   - OR disable email login and use **phone + Google** only

**Next Steps:**
1. Choose an option above
2. Implement the code changes
3. Test on Android/iOS devices
4. Update backend API if needed

---

## Current Status

- ✅ Web: Magic Labs with popup UI working
- ✅ Google Sign-In: Working on all platforms  
- ✅ Phone OTP: Ready (needs real SMS provider)
- ⚠️ Email OTP Mobile: Choose implementation above
