# Quote App - Daily Inspiration

A beautiful Flutter application for displaying daily inspirational quotes with favorites, collections, sharing, and home screen widgets. Built with modern architecture patterns and clean code principles.

## 📱 Features

### Core Features
- **Daily Quotes**: Unique quote of the day based on day of year (365+ quotes)
- **Random Quotes**: Get new random quotes on demand
- **Favorites**: Save and manage your favorite quotes with cloud sync
- **Collections**: Organize quotes into custom collections
- **Search & Filter**: Search quotes by keyword, author, or category
- **Share & Export**: Share quotes as text or beautiful image cards
- **Home Screen Widget**: Daily quote widget for iOS and Android
- **Daily Notifications**: Local push notifications for daily quotes

### Personalization
- **Dark/Light Mode**: System, light, or dark theme
- **Accent Colors**: Choose from Blue, Green, or Purple
- **Font Size**: Adjustable quote text size
- **Settings Sync**: Settings persist locally and sync to profile

### Technical Features
- **Authentication**: Email/password sign up and sign in
- **Cloud Sync**: Supabase backend for favorites, collections, and likes
- **Offline Support**: Local caching for offline access
- **Deep Linking**: Widget taps open app to daily quote

## 🏗️ Architecture

This project follows **Clean Architecture** with **Feature-oriented** organization:

### Architecture Layers
- **Presentation**: BLoC pattern for state management, UI pages and widgets
- **Domain**: Business logic, entities, use cases, and repository interfaces
- **Data**: Repository implementations, data sources (remote/local), and models

### State Management
- **BLoC Pattern**: Predictable state management with `flutter_bloc`
- **Optimistic Updates**: Instant UI updates with background sync
- **In-Memory Caching**: Efficient like/favorite status caching

### Project Structure

```
lib/
├── core/                          # Core utilities and infrastructure
│   ├── config/                   # App configuration (Supabase)
│   ├── constants/                # App-wide constants and strings
│   ├── di/                       # Dependency injection (get_it)
│   ├── errors/                   # Error handling and failures
│   ├── navigation/              # Navigation utilities
│   ├── network/                 # Network layer (Dio client)
│   ├── services/                # Core services (notifications, widgets)
│   ├── storage/                 # Local storage abstraction
│   ├── theme/                   # Theme configuration
│   └── utils/                   # Utility helpers
└── features/
    ├── auth/                    # Authentication feature
    │   ├── data/               # Auth data layer
    │   ├── domain/             # Auth domain layer
    │   └── presentation/       # Auth UI and BLoC
    ├── quotes/                 # Quotes feature
    │   ├── data/               # Quotes data layer
    │   ├── domain/             # Quotes domain layer
    │   └── presentation/       # Quotes UI and BLoC
    └── settings/               # Settings feature
        ├── data/               # Settings data layer
        ├── domain/             # Settings domain layer
        └── presentation/       # Settings UI and BLoC
```

## 🚀 Setup Instructions

### Prerequisites

- **Flutter SDK**: >=3.0.0 (check with `flutter --version`)
- **Dart SDK**: >=3.0.0
- **Android Studio** / **VS Code** with Flutter extensions
- **iOS Simulator** / **Android Emulator** or physical device
- **Xcode** (for iOS development, macOS only)
- **CocoaPods** (for iOS dependencies)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Quote
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase** (if using cloud features)
   - Update `lib/core/config/supabase_config.dart` with your Supabase URL and anon key
   - Or set up environment variables

4. **iOS Setup** (macOS only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

5. **Run the app**
   ```bash
   # Android
   flutter run

   # iOS (macOS only)
   flutter run -d ios
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Platform-Specific Setup

### Android

#### Permissions
All required permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- Internet access
- Notification permissions (Android 13+)
- Photo library access (for saving quote cards)

#### Widget Setup
The Android widget is automatically configured. To add it:
1. Long press home screen → Widgets
2. Find "Quote" → "Daily Quote"
3. Add to home screen

### iOS

#### Widget Setup
1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name: "DailyQuoteWidget"
4. Copy code from `ios/DailyQuoteWidget/DailyQuoteWidget.swift`
5. Configure App Groups:
   - Runner target → Signing & Capabilities → Add "App Groups"
   - Create group: `group.com.quote.app`
   - Widget target → Add same App Group
6. Build and run

See `IOS_SETUP.md` and `WIDGET_SETUP.md` for detailed instructions.

#### Permissions
All required permissions are configured in `ios/Runner/Info.plist`:
- Photo library access (for saving quote cards)
- Notification permissions (requested at runtime)

## 🔧 Configuration

### Supabase Configuration
Update `lib/core/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### Notification Timezone
Default timezone is set to `Asia/Kolkata` (IST). To change:
- Update `lib/core/services/notification_service.dart`
- Change `setLocalTimeZone('Asia/Kolkata')` to your timezone

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc: ^8.1.3` - State management
- `equatable: ^2.0.5` - Value equality
- `get_it: ^7.6.4` - Dependency injection
- `dio: ^5.4.0` - HTTP client
- `supabase_flutter: ^2.0.0` - Backend services

### UI & Theming
- `google_fonts: ^6.2.0` - Custom fonts
- `flutter_local_notifications: ^16.0.0` - Local notifications
- `timezone: ^0.9.0` - Timezone support

### Sharing & Media
- `share_plus: ^7.2.1` - Share functionality
- `screenshot: ^2.0.0` - Screenshot capture
- `saver_gallery: ^1.0.0` - Save images to gallery
- `permission_handler: ^11.0.0` - Permission management

### Widgets
- `home_widget: ^0.9.0` - Home screen widgets

### Storage
- `shared_preferences: ^2.2.2` - Local storage
- `path_provider: ^2.1.0` - File system paths

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Run with Coverage
```bash
flutter test --coverage
```

## 📝 Code Quality

### Standards
- **Naming**: Clear, descriptive names following Dart conventions
- **Structure**: Feature-oriented organization with clear separation
- **Error Handling**: Consistent error handling throughout
- **No Hardcoded Strings**: All strings in `AppStrings` constants
- **Documentation**: Inline comments for complex logic

### Linting
The project uses `flutter_lints` with custom rules:
- Prefer const constructors
- Avoid print statements (use `debugPrint`)
- Prefer single quotes
- Consistent code formatting

### Code Organization
- **Small, Focused Files**: Each file has a single responsibility
- **Reusable Components**: Widgets and utilities are reusable
- **Clean Architecture**: Clear boundaries between layers
- **Dependency Injection**: All dependencies injected via get_it

## 🐛 Troubleshooting

### Common Issues

**Widget not showing data:**
- Check App Groups are configured (iOS)
- Verify SharedPreferences keys match
- Ensure widget is updated after app launch

**Notifications not appearing:**
- Check notification permissions are granted
- Verify timezone is set correctly
- Check notification scheduling logic

**Photo library access denied:**
- Check Info.plist has usage descriptions (iOS)
- Verify permissions are requested before saving
- Check AndroidManifest.xml permissions (Android)

**Build errors:**
- Run `flutter clean` then `flutter pub get`
- For iOS: `cd ios && pod install && cd ..`
- Check Flutter and Dart versions match requirements

## 📚 Additional Documentation

- `WIDGET_SETUP.md` - Detailed widget setup guide
- `IOS_SETUP.md` - iOS-specific setup instructions

## 🙏 Acknowledgments

- **Supabase** for backend services
- **ZenQuotes API** for quote data fallback
- **Flutter team** for the amazing framework
- **Open source community** for excellent packages

---

**Built with ❤️ using Flutter**
