# Email OTP Flow Diagram

## Login Page Flow

```
┌─────────────────────────────────────────┐
│         Login Page (weblogin.dart)      │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   Phone Number Field              │  │
│  │   [+1] [_______________]          │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │         ─── OR ───                │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   Email Field (NEW!)              │  │
│  │   📧 [_______________]            │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │         [  LOGIN  ]               │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ✓ Terms & Conditions                  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   🔵 Login with Google            │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
           │
           │ (User enters email)
           ▼
┌─────────────────────────────────────────┐
│  Magic Labs Email OTP Sent              │
│  ✉️  OTP sent to: user@example.com     │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│      OTP Page (webotp.dart)             │
│                                         │
│   We have sent an OTP to your email     │
│   user@example.com                      │
│                                         │
│   ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐            │
│   │ │ │ │ │ │ │ │ │ │ │ │  (6-digit) │
│   └─┘ └─┘ └─┘ └─┘ └─┘ └─┘            │
│                                         │
│   Resend OTP in 60 seconds              │
│                                         │
│   ┌───────────────────────────────────┐ │
│   │         [  LOGIN  ]               │ │
│   └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
           │
           │ (Verify OTP with Magic Labs)
           ▼
┌─────────────────────────────────────────┐
│   ✅ Email Verified!                    │
│   🔐 Logging in...                      │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│   🏠 Home / Feed Page                   │
│   (Successfully logged in)              │
└─────────────────────────────────────────┘
```

## Technical Flow

### Phone Login (Existing)
```
User → Enter Phone → Send OTP → Enter OTP (123456) → Verify → Login (type=1)
```

### Email Login (NEW!)
```
User → Enter Email → Magic Labs Send OTP → Click Email Link / Enter Code
     → Magic Verify → Login (type=2) → Success
```

## API Parameters

### Phone Login
```dart
await provider.login(
  "1",           // type: phone
  "",            // email: empty
  mobile,        // mobile number
  deviceType,
  deviceToken,
  countrycode,
  countryName,
);
```

### Email Login (NEW!)
```dart
await provider.login(
  "2",           // type: email
  email,         // email address
  "",            // mobile: empty
  deviceType,
  deviceToken,
  "",            // countrycode: empty
  "",            // countryName: empty
);
```

## Key Features

✅ **Dual Login Support** - Phone OR Email
✅ **Magic Labs Integration** - Passwordless email authentication
✅ **Same OTP Page** - Unified experience for both methods
✅ **Email Validation** - Validates email format before sending
✅ **Localization Ready** - All text keys in locale files
✅ **Error Handling** - Comprehensive error messages
✅ **Resend OTP** - 60-second countdown timer
✅ **Loading States** - Shows progress indicators
✅ **No Breaking Changes** - Existing phone login still works

## User Experience

1. **Flexibility** - Users choose phone or email
2. **Simplicity** - No passwords to remember
3. **Security** - Magic Labs enterprise-grade security
4. **Speed** - Quick verification via email link
5. **Reliability** - Fallback to manual OTP entry
