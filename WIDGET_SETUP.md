# Home Screen Widget Setup Guide

This guide explains how to set up home screen widgets for both Android and iOS.

## Android Widget Setup

### 1. Files Created
- `android/app/src/main/kotlin/com/example/quote/DailyQuoteWidgetProvider.kt` - Widget provider
- `android/app/src/main/res/xml/daily_quote_widget_info.xml` - Widget configuration
- `android/app/src/main/res/layout/daily_quote_widget.xml` - Widget layout
- `android/app/src/main/res/drawable/widget_background.xml` - Widget background
- `android/app/src/main/res/values/strings.xml` - Widget strings

### 2. AndroidManifest.xml
The widget receiver has been added to `AndroidManifest.xml`.

### 3. How It Works
- Widget reads quote data from SharedPreferences (stored by `home_widget` package)
- Updates automatically when app updates the widget data
- Tapping widget opens app to browse page (index 0) showing daily quote
- Widget updates daily via `updatePeriodMillis` (24 hours)

## iOS Widget Setup

iOS widgets require Xcode configuration. Follow these steps:

### 1. Create Widget Extension in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select "Widget Extension"
4. Name it "DailyQuoteWidget"
5. Choose "Include Configuration Intent" = No
6. Language: Swift
7. Click Finish

### 2. Configure App Group
1. Select Runner target → Signing & Capabilities
2. Add "App Groups" capability
3. Create group: `group.com.quote.app`
4. Select DailyQuoteWidget target → Signing & Capabilities
5. Add "App Groups" capability
6. Select the same group: `group.com.quote.app`

### 3. Update Widget Code
Replace the generated widget code with:

```swift
import WidgetKit
import SwiftUI

struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyQuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Shows today's inspirational quote")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quoteText: "Loading...", quoteAuthor: "Author")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            quoteText: UserDefaults(suiteName: "group.com.quote.app")?.string(forKey: "quote_text") ?? "Loading...",
            quoteAuthor: UserDefaults(suiteName: "group.com.quote.app")?.string(forKey: "quote_author") ?? "Author"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let quoteText = UserDefaults(suiteName: "group.com.quote.app")?.string(forKey: "quote_text") ?? "Loading..."
        let quoteAuthor = UserDefaults(suiteName: "group.com.quote.app")?.string(forKey: "quote_author") ?? "Author"
        
        let entry = SimpleEntry(date: Date(), quoteText: quoteText, quoteAuthor: quoteAuthor)
        
        // Update daily at midnight
        let nextUpdate = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let quoteAuthor: String
}

struct DailyQuoteWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.29, green: 0.56, blue: 0.89), Color(red: 0.61, green: 0.35, blue: 0.71)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .center, spacing: 8) {
                Text(entry.quoteText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Text("— \(entry.quoteAuthor)")
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding()
        }
        .widgetURL(URL(string: "quoteapp://daily"))
    }
}

@main
struct DailyQuoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuoteWidget()
    }
}
```

### 4. Add URL Scheme for Deep Linking
In `ios/Runner/Info.plist`, add:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>quoteapp</string>
        </array>
    </dict>
</array>
```

### 5. Handle Deep Link in Flutter
Update `main.dart` to handle the deep link:

```dart
// In MaterialApp, add:
onGenerateRoute: (settings) {
  if (settings.name == '/daily') {
    // Navigate to browse page
    return MaterialPageRoute(builder: (_) => const MainPage());
  }
  return null;
},
```

## Testing

### Android
1. Build and run the app
2. Long press home screen → Widgets
3. Find "Quote" → "Daily Quote"
4. Add widget to home screen
5. Widget should display current daily quote
6. Tap widget to open app

### iOS
1. Build and run the app
2. Long press home screen → "+" button
3. Search for "Quote"
4. Add "Daily Quote" widget
5. Widget should display current daily quote
6. Tap widget to open app

## Daily Updates

The widget updates automatically:
- **Android**: Via `updatePeriodMillis` (24 hours) and when app updates data
- **iOS**: Via WidgetKit timeline (updates daily at midnight)

The app also updates the widget:
- When app opens (if quote is from a different day)
- When daily quote is fetched
- Via `WidgetService.updateIfNeeded()`

