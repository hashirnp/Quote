# Quote App - Daily Inspiration

A beautiful Flutter application for displaying daily inspirational quotes with favorites and sharing functionality. Built with modern architecture patterns and AI-assisted development.

## 📱 Features

- **Random Quotes**: Display daily inspirational quotes from ZenQuotes API
- **Favorites**: Save and manage your favorite quotes with persistent storage
- **Search**: Filter favorites by author or keyword
- **Share**: Share quotes via system share sheet
- **Dark Theme**: Beautiful, modern dark UI design
- **Smooth Navigation**: Tab-based navigation with state preservation

## 🏗️ Architecture

This project follows **Feature-oriented MVVM** architecture with clean separation of concerns:

- **State Management**: BLoC (Business Logic Component) pattern
- **Architecture**: Feature-oriented MVVM
- **Network Layer**: Dio with reusable client abstraction
- **Dependency Injection**: get_it service locator
- **Persistence**: SharedPreferences for local storage

### Project Structure

```
lib/
├── core/                    # Core utilities and infrastructure
│   ├── di/                 # Dependency injection setup
│   ├── network/             # Network layer (Dio client)
│   ├── storage/             # Local storage abstraction
│   ├── theme/               # App theme configuration
│   └── utils/               # Utility helpers
└── features/
    └── quotes/              # Quotes feature module
        ├── data/            # Data layer (repositories, data sources)
        ├── domain/          # Domain layer (entities, use cases)
        └── presentation/   # Presentation layer (BLoC, pages, widgets)
```

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd Quote
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**

```bash
flutter build apk --release
```

**iOS:**

```bash
flutter build ios --release
```

## 🤖 AI-Assisted Development

This project was developed using AI-powered tools to accelerate development and ensure code quality.

### AI Coding Approach

The development process leveraged AI assistance for:

1. **Architecture Design**: AI helped design the feature-oriented MVVM structure with proper separation of concerns
2. **Code Generation**: Initial boilerplate and widget structures were generated with AI assistance
3. **Code Refactoring**: AI assisted in breaking down large files into smaller, maintainable components
4. **State Management**: BLoC pattern implementation was refined with AI guidance
5. **UI Implementation**: UI components were created to match design specifications with AI assistance
6. **UI Corrections**: Gemini was used extensively for UI corrections, layout adjustments, and pixel-perfect design implementation
7. **Bug Fixing**: State preservation issues and navigation problems were identified and fixed with AI help

### Development Workflow

1. **Design Analysis**: Analyzed provided design images to understand UI requirements
2. **Architecture Planning**: Used AI to plan the feature-oriented structure
3. **Incremental Development**: Built features incrementally with AI code suggestions
4. **Refactoring**: Continuously refactored code into smaller, reusable components
5. **Testing & Debugging**: Used AI to identify and fix state management issues

## 🛠️ AI Tools Used

### 1. **Cursor**

- **Purpose**: Primary AI-powered IDE for code generation and refactoring
- **Usage**:
  - Generated initial project structure
  - Created BLoC implementations
  - Refactored large files into smaller components
  - Fixed state management issues
  - Improved code organization

### 2. **Google Stitches**

- **Purpose**: Design-to-code conversion and UI implementation
- **Usage**:
  - Converted design mockups to Flutter widgets
  - Matched UI components to design specifications
  - Ensured pixel-perfect implementation

### 3. **Gemini**

- **Purpose**: UI corrections, code review, and problem-solving
- **Usage**:
  - UI corrections and refinements
  - Pixel-perfect design implementation
  - Layout adjustments and styling fixes
  - Code quality improvements
  - State management solutions
  - Best practices guidance

## 🎨 Design References

### Design Tools

- **Stitch Designs**: https://stitch.withgoogle.com/projects/1197147559682827139

### UI Components

- **Home Screen**: Large quote display with decorative quotation marks
- **Favorites Screen**: List view with search functionality
- **Navigation**: Bottom navigation bar with tab switching
- **Theme**: Dark theme with blue accents

## 📦 Dependencies

### Core Dependencies

- `flutter_bloc: ^8.1.3` - State management
- `equatable: ^2.0.5` - Value equality
- `get_it: ^7.6.4` - Dependency injection
- `dio: ^5.4.0` - HTTP client
- `shared_preferences: ^2.2.2` - Local storage
- `share_plus: ^7.2.1` - Share functionality
- `google_fonts: ^6.2.0` - Custom fonts

## 🔧 Key Features Implementation

### State Management

- Uses BLoC pattern for predictable state management
- State preservation when switching between tabs
- Proper error handling and loading states

### Network Layer

- Reusable Dio client with interceptors
- Abstract network client interface for testability
- Error handling with custom failure types

### Local Storage

- SharedPreferences wrapper for type-safe storage
- Persistent favorites storage
- Clean abstraction for future database migration

## 📝 Code Standards

- **Naming**: Clear, descriptive names following Dart conventions
- **Structure**: Feature-oriented organization
- **Separation**: Clear boundaries between layers
- **Reusability**: Reusable widgets and utilities
- **Documentation**: Inline comments for complex logic

## 🙏 Acknowledgments

- ZenQuotes API for providing quote data
- Flutter team for the amazing framework
- AI tools (Cursor, Google Stitches, Gemini) for development assistance

---

**Note**: This project was developed with AI assistance to demonstrate modern Flutter development practices and AI-powered development workflows.
