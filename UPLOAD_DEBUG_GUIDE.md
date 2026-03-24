# Upload Debug Guide

## Issues Found and Fixed

### 1. **No Error Handling in uploadApi()** ❌ FIXED ✅
**Problem:** When the API call fails, no error feedback is shown to the user. The loading indicator just stays there indefinitely.

**Solution:** Added comprehensive try-catch-finally block with:
- Detailed console logging at each step
- Catch blocks for DioException and general exceptions
- User-friendly error messages shown via SnackBar
- Proper cleanup in finally block

**Location:** [lib/pages/uploadfeed.dart](lib/pages/uploadfeed.dart#L1085-L1115)

### 2. **No Timeout Configuration** ❌ FIXED ✅
**Problem:** The dio.post() request has no timeout set. If the server doesn't respond, the request hangs forever.

**Solution:** Added:
- Send timeout: 60 seconds
- Receive timeout: 60 seconds  
- Overall timeout: 120 seconds with custom error message

**Location:** [lib/webservice/apiservice.dart](lib/webservice/apiservice.dart#L2300-L2310)

### 3. **Missing Exception Handling in API Service** ❌ FIXED ✅
**Problem:** DioException and other errors weren't caught, causing silent failures.

**Solution:** Added:
- `try-catch` for DioException with detailed logging
- Generic catch for unexpected exceptions
- Returns proper SuccessModel with error status and message
- Logs request/response details for debugging

**Location:** [lib/webservice/apiservice.dart](lib/webservice/apiservice.dart#L2290-L2350)

---

## Debugging Steps

### Check Console Logs

When upload fails, check the console/logcat for these key messages:

```
===== Starting Upload =====
Selected Content: X
Caption: ...
Type: free/pay

===== Upload API Response =====
Status: 200/500
Message: ...

===== Upload Success/Failed =====

// OR if error:

===== Upload Timeout =====
===== Dio Exception =====
DioException: ...
Error Type: ...

===== General Exception =====
Exception: ...
```

### Common Issues to Check

1. **"No file selected" error**
   - Ensure at least one image/video is selected before upload
   - Check if selectedContent array is populated

2. **Network timeout**
   - Check server availability
   - Verify API endpoint URL: `$baseurl/upload_post`
   - Check internet connection

3. **"Error uploading feed post" message**
   - Check the detailed error message in console
   - Verify all required fields are filled:
     - Caption (title)
     - At least one content file
     - Channel ID is set

4. **File upload fails**
   - On Web: Check if fileBytes and fileName are properly set
   - On Mobile: Check if File path is valid
   - Check file size limitations

---

## Testing the Upload

### Prerequisites
- User must be logged in (Constant.userID != null)
- At least one content item selected
- Caption filled in

### Steps
1. Select image/video using bottom sheet
2. Enter caption
3. Select pricing type (free/pay)
4. If pay: enter price
5. Click upload button
6. Watch console for detailed logs

---

## Key Changes Made

### [uploadfeed.dart](lib/pages/uploadfeed.dart#L1085-L1115)
```dart
try {
  print("===== Starting Upload =====");
  // ... upload logic ...
  print("===== Upload API Response =====");
  // ... response handling ...
} catch (e) {
  print("===== Upload Exception =====");
  Utils().showSnackBar(context, "Error: $e", true);
} finally {
  Utils().hideProgress(context);
}
```

### [apiservice.dart](lib/webservice/apiservice.dart#L2290-L2350)
```dart
try {
  Response response = await dio.post(
    "$baseurl$apiname",
    data: formData,
    options: Options(
      sendTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  ).timeout(
    const Duration(seconds: 120),
    onTimeout: () { /* handle timeout */ },
  );
} on DioException catch (e) {
  // Handle DioException with detailed logging
} catch (e) {
  // Handle general exceptions
}
```

---

## What to Check If Still Having Issues

1. **API Endpoint Verification**
   - Ensure `baseurl` and `upload_post` endpoint are correct
   - Test endpoint manually with curl or Postman

2. **Dio Configuration**
   - Check if Dio is properly configured with baseOptions
   - Verify interceptors aren't blocking requests

3. **File Size**
   - Check maximum file size limit on server
   - Check if device has enough free space

4. **Server Response**
   - Check server logs for upload requests
   - Verify response JSON format matches SuccessModel

5. **Network**
   - Test on different network (WiFi vs mobile data)
   - Check if firewall/VPN is blocking requests

---

## Performance Tips

- Compress images before upload
- Limit video duration to 5 minutes (as set in picker)
- Upload on stable WiFi connection for larger files
- Monitor upload progress via console logs

---

## Next Steps for Further Debugging

If issues persist after these fixes:

1. Add Dio interceptor to log all requests/responses
2. Implement upload progress callback
3. Add network connectivity check before upload
4. Verify SuccessModel JSON parsing
5. Check server-side upload limits

