# Pusher Beams Push Notification Setup Guide

This guide will help you set up Pusher Beams push notifications in your Flutter app.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Pusher Beams Account Setup](#pusher-beams-account-setup)
3. [iOS Configuration](#ios-configuration)
4. [Android Configuration](#android-configuration)
5. [Flutter Implementation](#flutter-implementation)
6. [Backend Server Setup](#backend-server-setup)
7. [Testing Notifications](#testing-notifications)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Flutter SDK installed
- A Pusher account (free tier available)
- For iOS: Apple Developer account with APNs certificates
- For Android: Firebase project for FCM credentials

---

## Pusher Beams Account Setup

### Step 1: Create a Pusher Account

1. Go to [Pusher Beams Dashboard](https://dashboard.pusher.com/beams)
2. Sign up or log in to your account
3. Click **"Create a new Beams instance"**
4. Name your instance (e.g., `fanbae-notifications`)
5. Copy your **Instance ID** - you'll need this later

### Step 2: Configure Your Instance

1. In the Pusher Beams dashboard, select your instance
2. Note your **Instance ID** (looks like: `a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6`)

---

## iOS Configuration

### Step 1: Generate APNs Certificates

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Create a new **Apple Push Notification service SSL Certificate**
4. Download the `.p12` certificate

### Step 2: Upload APNs Certificate to Pusher

1. In Pusher Beams dashboard, go to your instance
2. Click on **iOS** tab
3. Upload your `.p12` certificate
4. Enter the certificate password

### Step 3: Update iOS Project

1. Open `ios/Runner.xcworkspace` in Xcode
2. Enable **Push Notifications** capability:
   - Select your target
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Push Notifications**

3. Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import PusherBeams

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PusherBeams.registerDeviceToken(deviceToken)
  }
  
  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    PusherBeams.handleNotification(userInfo: userInfo)
  }
}
```

---

## Android Configuration

### Step 1: Set up Firebase Cloud Messaging (FCM)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** > **Cloud Messaging**
4. Copy your **Server Key**

### Step 2: Configure Pusher with FCM

1. In Pusher Beams dashboard, select your instance
2. Click on **Android** tab
3. Paste your **FCM Server Key**
4. Save the configuration

### Step 3: Update Android Project

1. Ensure `android/app/build.gradle` has minimum SDK version:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Minimum required for Pusher Beams
        targetSdkVersion 33
    }
}
```

2. Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- Your existing configuration -->
    </application>
</manifest>
```

---

## Flutter Implementation

### Step 1: Update Instance ID

Open `lib/utils/pusher_beams_service.dart` and replace the placeholder:

```dart
// Replace with your actual Pusher Beams instance ID
static const String instanceId = 'YOUR_PUSHER_BEAMS_INSTANCE_ID';
```

**Example:**
```dart
static const String instanceId = 'a1b2c3d4-e5f6-7g8h-9i0j-k1l2m3n4o5p6';
```

### Step 2: Subscribe to Interests (Channels)

After user logs in, subscribe them to interests:

```dart
// Subscribe to user-specific channel
await PusherBeamsService().addInterest('user-${userId}');

// Subscribe to general notifications
await PusherBeamsService().addInterest('general');

// Subscribe to role-based channels
await PusherBeamsService().addInterest('creators');
```

### Step 3: Set User ID (for Authenticated Users)

Update the `setUserId` method in `pusher_beams_service.dart`:

```dart
Future<void> setUserId(String userId) async {
  try {
    final beamsAuthProvider = BeamsAuthProvider()
      ..authUrl = 'https://your-server.com/pusher/beams-auth'  // Your auth endpoint
      ..headers = {'Content-Type': 'application/json'}
      ..queryParams = {'user_id': userId}
      ..credentials = 'same-origin';

    await PusherBeams.instance.setUserId(
      userId,
      beamsAuthProvider,
      (error) {
        print('❌ Beams auth error: $error');
      },
    );
    print('✅ User ID set: $userId');
  } catch (e) {
    print('❌ Error setting user ID: $e');
  }
}
```

### Step 4: Handle User Logout

When user logs out, clear Pusher Beams state:

```dart
await PusherBeamsService().clearUserId();
```

---

## Backend Server Setup

### Option 1: Node.js Server

Install Pusher Beams SDK:
```bash
npm install @pusher/push-notifications-server
```

**Send notification to an interest:**

```javascript
const PushNotifications = require('@pusher/push-notifications-server');

const beamsClient = new PushNotifications({
  instanceId: 'YOUR_INSTANCE_ID',
  secretKey: 'YOUR_SECRET_KEY'
});

// Send to interest (channel)
beamsClient.publishToInterests(['general'], {
  apns: {
    aps: {
      alert: {
        title: 'Hello!',
        body: 'This is a test notification'
      },
      sound: 'default'
    },
    data: {
      apptype: 'chat',
      receiver_id: '123',
      receiver_name: 'John Doe'
    }
  },
  fcm: {
    notification: {
      title: 'Hello!',
      body: 'This is a test notification'
    },
    data: {
      apptype: 'chat',
      receiver_id: '123',
      receiver_name: 'John Doe'
    }
  }
}).then((publishResponse) => {
  console.log('Just published:', publishResponse.publishId);
}).catch((error) => {
  console.error('Error:', error);
});
```

**Send to specific user:**

```javascript
beamsClient.publishToUsers(['user-123'], {
  apns: {
    aps: {
      alert: 'Hello user 123!'
    }
  },
  fcm: {
    notification: {
      title: 'Hello',
      body: 'Hello user 123!'
    }
  }
});
```

**Beams Auth Endpoint (for user authentication):**

```javascript
const express = require('express');
const app = express();

app.get('/pusher/beams-auth', (req, res) => {
  const userId = req.query.user_id;
  
  // Verify user session/token here
  if (!userId) {
    return res.status(401).send('Unauthorized');
  }

  const beamsToken = beamsClient.generateToken(userId);
  res.send(JSON.stringify(beamsToken));
});

app.listen(3000);
```

### Option 2: PHP Server

```php
<?php
require 'vendor/autoload.php';

use Pusher\PushNotifications\PushNotifications;

$beamsClient = new PushNotifications([
    'instanceId' => 'YOUR_INSTANCE_ID',
    'secretKey' => 'YOUR_SECRET_KEY'
]);

// Send notification
$publishResponse = $beamsClient->publishToInterests(
    ['general'],
    [
        'apns' => [
            'aps' => [
                'alert' => [
                    'title' => 'Hello!',
                    'body' => 'Test notification'
                ]
            ]
        ],
        'fcm' => [
            'notification' => [
                'title' => 'Hello!',
                'body' => 'Test notification'
            ]
        ]
    ]
);
```

### Option 3: Python Server

```python
from pusher_push_notifications import PushNotifications

beams_client = PushNotifications(
    instance_id='YOUR_INSTANCE_ID',
    secret_key='YOUR_SECRET_KEY',
)

response = beams_client.publish_to_interests(
    interests=['general'],
    publish_body={
        'apns': {
            'aps': {
                'alert': {
                    'title': 'Hello!',
                    'body': 'Test notification'
                }
            }
        },
        'fcm': {
            'notification': {
                'title': 'Hello!',
                'body': 'Test notification'
            }
        }
    }
)
```

---

## Testing Notifications

### Method 1: Using Pusher Dashboard

1. Go to your Pusher Beams instance
2. Click on **Debug Console**
3. Select **Publish to Interests**
4. Choose platform (iOS/Android)
5. Enter your interest (e.g., `general`)
6. Write notification content
7. Click **Publish**

### Method 2: Using cURL

```bash
curl -X POST "https://INSTANCE_ID.pushnotifications.pusher.com/publish_api/v1/instances/INSTANCE_ID/publishes/interests" \
  -H "Authorization: Bearer SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "interests": ["general"],
    "apns": {
      "aps": {
        "alert": {
          "title": "Test",
          "body": "Hello from Pusher Beams!"
        }
      }
    },
    "fcm": {
      "notification": {
        "title": "Test",
        "body": "Hello from Pusher Beams!"
      }
    }
  }'
```

---

## Troubleshooting

### Notifications not received on iOS

1. **Check APNs certificate:**
   - Ensure certificate is valid and uploaded to Pusher
   - Verify certificate matches your app's Bundle ID

2. **Verify Push Notifications capability:**
   - Open Xcode
   - Check if Push Notifications is enabled in Signing & Capabilities

3. **Check device registration:**
   ```dart
   final interests = await PusherBeamsService().getInterests();
   print('Subscribed interests: $interests');
   ```

### Notifications not received on Android

1. **Check FCM configuration:**
   - Verify FCM Server Key in Pusher dashboard
   - Ensure Firebase is properly configured

2. **Check permissions:**
   - For Android 13+, ensure POST_NOTIFICATIONS permission is granted

3. **Enable debug logging:**
   ```dart
   await PusherBeams.instance.start(instanceId);
   print('Pusher Beams started');
   ```

### Common Issues

**Issue: "Instance ID not found"**
- Solution: Verify your Instance ID in `pusher_beams_service.dart`

**Issue: "Invalid FCM token"**
- Solution: Regenerate FCM Server Key in Firebase Console

**Issue: "User authentication failed"**
- Solution: Implement and test your Beams auth endpoint

---

## Additional Resources

- [Pusher Beams Documentation](https://pusher.com/docs/beams)
- [Pusher Beams Flutter SDK](https://pub.dev/packages/pusher_beams)
- [Server SDKs](https://pusher.com/docs/beams/reference/server-sdk-node)

---

## Support

If you encounter issues:
1. Check Pusher Beams dashboard for error logs
2. Review device logs for detailed error messages
3. Contact Pusher support at support@pusher.com

---

**Last Updated:** February 2, 2026
