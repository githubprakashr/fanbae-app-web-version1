# Pusher Beams Device Registration Test

## ✅ Your Instance is Configured!

**Instance ID:** `de7c2043-6c32-463c-ae56-b8c5d7f40507`

The code has been updated to automatically subscribe to the `hello` interest when the app starts.

---

## 🚀 Quick Test (Option 1: Run Your App)

### Step 1: Run the App

```bash
flutter run
```

The app will automatically:
- Initialize Pusher Beams with your Instance ID
- Subscribe to `hello` interest
- Subscribe to `general` interest

### Step 2: Send Test Notification from Pusher Dashboard

1. Go to [Pusher Beams Dashboard](https://dashboard.pusher.com/beams)
2. Select your instance: `de7c2043-6c32-463c-ae56-b8c5d7f40507`
3. Click **"Debug Console"**
4. Click **"Publish to Interests"**
5. Enter interest: `hello`
6. Fill in notification:
   ```json
   {
     "title": "Test Notification",
     "body": "Hello from Pusher Beams!"
   }
   ```
7. Click **"Publish"**

### Step 3: Check Your Device

You should receive the notification on your device!

---

## 🧪 Use Test Screen (Option 2: Visual Testing)

### Add Test Screen to Your App

1. Open your app where you want to add a test button (e.g., Settings page)

2. Add this import:
```dart
import 'package:fanbae/pages/pusher_beams_test.dart';
```

3. Add a button to navigate to the test screen:
```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PusherBeamsTestScreen(),
      ),
    );
  },
  child: const Text('Test Pusher Beams'),
)
```

4. The test screen shows:
   - Your Instance ID
   - Current subscribed interests
   - Buttons to subscribe to channels
   - Testing instructions

---

## 📱 What Happens When App Starts

The app automatically:

1. **Initializes Pusher Beams:**
```dart
await PusherBeams.instance.start('de7c2043-6c32-463c-ae56-b8c5d7f40507');
```

2. **Subscribes to `hello` interest:**
```dart
await PusherBeams.instance.addDeviceInterest('hello');
```

3. **Subscribes to `general` interest:**
```dart
await PusherBeams.instance.addDeviceInterest('general');
```

---

## ✅ Verify Device Registration

### Method 1: Check Console Logs

Look for these logs when app starts:
```
✅ Pusher Beams initialized successfully
```

### Method 2: Check Pusher Dashboard

1. Go to your instance in Pusher Dashboard
2. Click **"Devices"** tab
3. You should see your device listed

### Method 3: Get Interests Programmatically

```dart
final interests = await PusherBeamsService().getInterests();
print('Subscribed interests: $interests');
// Should print: {hello, general}
```

---

## 🔧 Troubleshooting

### Device Not Showing in Pusher Dashboard

1. **Uninstall and reinstall the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check Android Logs:**
   ```bash
   flutter logs
   ```
   Look for Pusher Beams initialization messages

3. **Verify minSdkVersion:**
   - Open `android/app/build.gradle`
   - Ensure `minSdkVersion` is at least 21 (yours is 24 ✅)

### Notification Not Received

1. **Check notification permissions:**
   - Android 13+: Ensure POST_NOTIFICATIONS permission is granted
   - Go to Settings → Apps → Your App → Notifications

2. **Verify interest subscription:**
   ```dart
   final interests = await PusherBeamsService().getInterests();
   print(interests); // Should include 'hello'
   ```

3. **Check Pusher Dashboard:**
   - Ensure you're sending to the correct interest (`hello`)
   - Check platform is correct (Android/iOS)

---

## 📤 Send Notification from Code (Optional)

If you want to test from your backend:

```bash
curl -X POST "https://de7c2043-6c32-463c-ae56-b8c5d7f40507.pushnotifications.pusher.com/publish_api/v1/instances/de7c2043-6c32-463c-ae56-b8c5d7f40507/publishes/interests" \
  -H "Authorization: Bearer YOUR_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "interests": ["hello"],
    "fcm": {
      "notification": {
        "title": "Test from cURL",
        "body": "If you see this, Pusher Beams is working!"
      }
    }
  }'
```

Replace `YOUR_SECRET_KEY` with your secret key from Pusher Dashboard.

---

## 🎯 Expected Flow

1. ✅ App starts
2. ✅ Pusher Beams initializes with Instance ID
3. ✅ Device automatically subscribes to `hello` and `general`
4. ✅ Device registers with Pusher (visible in Dashboard)
5. ✅ Send test notification from Dashboard
6. ✅ Notification appears on device
7. ✅ Tapping notification opens app with correct navigation

---

## 📚 Next Steps After Testing

Once notifications are working:

1. **Remove test subscriptions** (optional)
2. **Subscribe users after login:**
   ```dart
   await PusherBeamsService().addInterest('user-${userId}');
   ```

3. **Update backend** to send notifications via Pusher Beams API

4. **Handle notification data** for app navigation (already implemented!)

---

## 🆘 Still Having Issues?

1. Check logs: `flutter logs`
2. Verify Instance ID in code matches Dashboard
3. Ensure app has notification permissions
4. Try uninstall/reinstall
5. Check Pusher Dashboard device list

**Need more help?** See [PUSHER_BEAMS_SETUP.md](./PUSHER_BEAMS_SETUP.md) for detailed troubleshooting.
