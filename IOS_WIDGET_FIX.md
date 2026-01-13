# iOS Widget Fix Guide

## Issues Fixed

1. **Key Format Mismatch**: The widget was looking for keys without the `home_widget.` prefix that the package uses
2. **Data Reading**: Updated widget to check both key formats for compatibility

## Changes Made

### 1. Widget Code (`ios/DailyQuoteWidget/DailyQuoteWidget.swift`)
- Updated `getSnapshot` and `getTimeline` to check for both:
  - `home_widget.quote_text` (home_widget package format)
  - `quote_text` (fallback format)
- Added better error handling and logging

### 2. Widget Service (`lib/core/services/widget_service.dart`)
- Improved logging to show data is being saved to App Group
- Added comments explaining the key format

## Required Xcode Configuration

The widget extension must be properly configured in Xcode:

### 1. Verify Widget Extension Exists
- Open `ios/Runner.xcworkspace` in Xcode
- Check that `DailyQuoteWidget` target exists

### 2. Configure App Groups (CRITICAL)
1. Select **Runner** target → **Signing & Capabilities**
2. Click **+ Capability** → Add **App Groups**
3. Add group: `group.com.quote.app`
4. Select **DailyQuoteWidget** target → **Signing & Capabilities**
5. Click **+ Capability** → Add **App Groups**
6. Add the same group: `group.com.quote.app`

**Both targets MUST have the same App Group configured!**

### 3. Verify Widget Code
- The widget code in `ios/DailyQuoteWidget/DailyQuoteWidget.swift` should match the updated version
- The widget should read from `UserDefaults(suiteName: "group.com.quote.app")`

### 4. Build and Run
1. Clean build folder (Cmd+Shift+K)
2. Build the app (Cmd+B)
3. Run on device or simulator
4. Add widget to home screen
5. Widget should display the daily quote

## Testing

1. **Check Data Storage**:
   - Run the app
   - Check console logs for "Saved to HomeWidget (iOS App Group)"
   - Verify data is being saved

2. **Check Widget**:
   - Add widget to home screen
   - Widget should show "Loading quote..." initially
   - After app updates data, widget should refresh

3. **Debug if Not Working**:
   - Check Xcode console for widget errors
   - Verify App Groups are configured in both targets
   - Check that widget extension is included in build
   - Verify bundle identifier matches

## Troubleshooting

### Widget Shows "Loading quote..."
- **Issue**: Data not being shared between app and widget
- **Fix**: Verify App Groups are configured in both Runner and DailyQuoteWidget targets

### Widget Not Appearing
- **Issue**: Widget extension not built or not included
- **Fix**: 
  - Check that DailyQuoteWidget target exists
  - Verify it's included in the build scheme
  - Clean and rebuild

### Data Not Updating
- **Issue**: Widget timeline not refreshing
- **Fix**: 
  - Widget updates daily at midnight
  - App can trigger update via `HomeWidget.updateWidget()`
  - Check that `updateDailyQuote()` is being called

## Key Points

- `home_widget` package stores data in `UserDefaults` with suite name `group.com.quote.app`
- Keys are stored with `home_widget.` prefix (e.g., `home_widget.quote_text`)
- Widget reads from the same App Group UserDefaults
- Both app and widget must have App Groups capability configured
- Widget updates via WidgetKit timeline (daily at midnight)

