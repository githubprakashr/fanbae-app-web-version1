# Pusher Beams Quick Start Guide

## ✅ What's Been Done

1. **Removed old notification systems:**
   - Firebase Messaging (FCM)
   - OneSignal

2. **Added Pusher Beams:**
   - Package installed: `pusher_beams: ^1.1.2`
   - Created service: `lib/utils/pusher_beams_service.dart`
   - Updated main app initialization

3. **Files Modified:**
   - `pubspec.yaml` - Added Pusher Beams dependency
   - `lib/main.dart` - Initialize Pusher Beams
   - `lib/utils/pusher_beams_service.dart` - New service file
   - `lib/utils/customads.dart` - Updated token retrieval
   - `lib/utils/utils.dart` - Updated token methods
   - `lib/pages/setting.dart` - Removed FCM import

## 🚀 Next Steps

### 1. Get Your Pusher Beams Instance ID

1. Visit [Pusher Dashboard](https://dashboard.pusher.com/beams)
2. Create a new Beams instance or select existing one
3. Copy your Instance ID

### 2. Update Instance ID

Edit `lib/utils/pusher_beams_service.dart`:

```dart
static const String instanceId = 'YOUR_INSTANCE_ID_HERE';
```

Replace `'YOUR_INSTANCE_ID_HERE'` with your actual Instance ID from Pusher dashboard.

### 3. Configure Platform-Specific Settings

**For Android:**
- Add FCM Server Key to Pusher dashboard
- Minimum SDK: 21 (already configured)

**For iOS:**
- Upload APNs certificate to Pusher dashboard
- Enable Push Notifications in Xcode

See [PUSHER_BEAMS_SETUP.md](./PUSHER_BEAMS_SETUP.md) for detailed platform setup.

### 4. Subscribe Users to Channels

After user login, subscribe them:

```dart
// In your login success handler
final userId = userDataYouGet['id'].toString();

// Subscribe to user-specific notifications
await PusherBeamsService().addInterest('user-$userId');

// Subscribe to general notifications
await PusherBeamsService().addInterest('general');

// For authenticated notifications, set user ID
await PusherBeamsService().setUserId(userId);
```

### 5. Handle User Logout

In your logout handler:

```dart
await PusherBeamsService().clearUserId();
```

### 6. Update Backend Server

Your backend needs to send notifications through Pusher Beams API instead of FCM/OneSignal.

**Example (Node.js):**
```javascript
const beamsClient = new PushNotifications({
  instanceId: 'YOUR_INSTANCE_ID',
  secretKey: 'YOUR_SECRET_KEY'
});

beamsClient.publishToInterests(['user-123'], {
  fcm: {
    notification: {
      title: 'New Message',
      body: 'You have a new message!'
    },
    data: {
      apptype: 'chat',
      receiver_id: '123'
    }
  }
});
```

## 📱 Testing

### Test with Pusher Dashboard

1. Go to your Pusher Beams instance
2. Click "Debug Console"
3. Select "Publish to Interests"
4. Enter interest: `general`
5. Add notification content
6. Click "Publish"

### Check Device Subscription

```dart
final interests = await PusherBeamsService().getInterests();
print('Subscribed to: $interests');
```

## 🔍 Debugging

Enable debug logs in your app:

```dart
// In pusher_beams_service.dart initialize method
print('✅ Pusher Beams initialized');
print('Subscribed interests: ${await PusherBeamsService().getInterests()}');
```

## 📚 Documentation

- Complete setup: [PUSHER_BEAMS_SETUP.md](./PUSHER_BEAMS_SETUP.md)
- Official docs: https://pusher.com/docs/beams

## ⚠️ Important Notes

1. **Instance ID Required:** App won't receive notifications until you set the correct Instance ID
2. **Platform Config:** iOS needs APNs certificate, Android needs FCM Server Key
3. **Backend Changes:** Your server must use Pusher Beams API to send notifications
4. **Interests vs Users:** 
   - Use "interests" for topic-based notifications (e.g., 'general', 'news')
   - Use "setUserId" for user-specific notifications

## 🆘 Common Issues

**"Pusher Beams not receiving notifications"**
- Check Instance ID is correct
- Verify platform configuration (APNs/FCM)
- Confirm device is subscribed to interests

**"Authentication failed"**
- Implement Beams auth endpoint on your server
- Update auth URL in `setUserId` method

## 📞 Need Help?

Refer to [PUSHER_BEAMS_SETUP.md](./PUSHER_BEAMS_SETUP.md) for detailed troubleshooting.
