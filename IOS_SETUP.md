# iOS Setup Guide

This guide ensures all Android features are available and working on iOS.

## ✅ Features Status

### 1. Widget Support
- ✅ **Widget Extension Code**: Created `ios/DailyQuoteWidget/DailyQuoteWidget.swift`
- ✅ **App Group Configuration**: Set to `group.com.quote.app` in `WidgetService`
- ✅ **Deep Linking**: URL scheme `quoteapp://daily` configured in `Info.plist`
- ✅ **AppDelegate**: Handles widget taps and notifies Flutter

**To Complete Setup:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name: "DailyQuoteWidget"
4. Copy code from `ios/DailyQuoteWidget/DailyQuoteWidget.swift`
5. Configure App Groups for both Runner and Widget targets

### 2. Notifications
- ✅ **Permissions**: Configured in `NotificationService`
- ✅ **Local Notifications**: `flutter_local_notifications` works on iOS
- ✅ **Scheduling**: Daily quote notifications scheduled
- ✅ **Time Zone**: Set to Asia/Kolkata (IST)

**iOS Permissions:**
- Alert permission: ✅ Requested
- Badge permission: ✅ Requested
- Sound permission: ✅ Requested

### 3. Photo Library Access
- ✅ **Permissions**: `NSPhotoLibraryUsageDescription` and `NSPhotoLibraryAddUsageDescription` in `Info.plist`
- ✅ **Save to Gallery**: `saver_gallery` package works on iOS
- ✅ **Permissions Handler**: `permission_handler` configured

### 4. Deep Linking
- ✅ **URL Scheme**: `quoteapp://daily` configured in `Info.plist`
- ✅ **AppDelegate**: Handles URL scheme and notifies Flutter
- ✅ **Flutter Handler**: `main.dart` handles deep links via `onGenerateRoute`
- ✅ **Widget Taps**: Opens app to browse page (index 0) showing daily quote

### 5. Shared Preferences / App Groups
- ✅ **Widget Data**: Uses `home_widget` package which uses App Groups on iOS
- ✅ **App Group ID**: `group.com.quote.app`
- ✅ **Data Sharing**: Widget reads from UserDefaults with suite name

## Configuration Files

### Info.plist
```xml
<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save quote cards to your photo library</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save quote cards to your photo library</string>

<!-- Deep Linking -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>quoteapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.quote.app</string>
    </dict>
</array>
```

### AppDelegate.swift
- Handles URL scheme for widget deep linking
- Sets up MethodChannel for widget intent communication
- Notifies Flutter when widget is tapped

## Testing Checklist

### Widget
- [ ] Create Widget Extension in Xcode
- [ ] Configure App Groups
- [ ] Build and run app
- [ ] Add widget to home screen
- [ ] Verify widget shows daily quote
- [ ] Tap widget to verify app opens to browse page

### Notifications
- [ ] Grant notification permissions
- [ ] Set notification time in settings
- [ ] Verify notification appears at scheduled time
- [ ] Tap notification to verify app opens

### Photo Library
- [ ] Grant photo library permissions
- [ ] Share quote as image
- [ ] Save quote card to gallery
- [ ] Verify image appears in Photos app

### Deep Linking
- [ ] Open URL `quoteapp://daily` in Safari
- [ ] Verify app opens to browse page
- [ ] Tap widget to verify deep link works

## Differences from Android

1. **Widget Updates**: iOS uses WidgetKit timeline (updates at midnight), Android uses `updatePeriodMillis`
2. **SharedPreferences**: iOS uses App Groups (UserDefaults with suite name), Android uses SharedPreferences
3. **Permissions**: iOS requests at runtime, Android uses manifest
4. **Deep Linking**: iOS uses URL schemes, Android uses Intent extras

## Troubleshooting

### Widget Not Showing Data
- Check App Groups are configured correctly
- Verify `group.com.quote.app` matches in both Runner and Widget targets
- Check UserDefaults keys match: `quote_text`, `quote_author`

### Deep Link Not Working
- Verify URL scheme in Info.plist
- Check AppDelegate handles URL correctly
- Verify Flutter route handler in main.dart

### Notifications Not Appearing
- Check notification permissions are granted
- Verify timezone is set correctly
- Check notification scheduling logic

### Photo Library Access Denied
- Check Info.plist has usage descriptions
- Verify permissions are requested before saving
- Check `permission_handler` is configured correctly

