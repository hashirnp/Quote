class AppStrings {
  // App Name
  static const String appName = 'Quote App';

  // Auth
  static const String welcomeBack = 'Welcome Back';
  static const String loginToInspiration =
      'Login to your daily dose of inspiration';
  static const String createAccount = 'Create Account';
  static const String joinCommunity =
      'Join our community of inspiration seekers.';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordDescription =
      "Enter your email address and we'll send you a link to get back into your account.";
  static const String yourFavorites = 'Your Favorites';
  static const String dailyInspiration = 'DAILY INSPIRATION';
  static const String profile = 'Profile';

  // Form Labels
  static const String emailAddress = 'Email Address';
  static const String password = 'Password';
  static const String fullName = 'Full Name';

  // Placeholders
  static const String emailPlaceholder = 'name@example.com';
  static const String passwordPlaceholder = 'Enter your password';
  static const String fullNamePlaceholder = 'John Doe';
  static const String searchPlaceholder = 'Search by keyword or author...';
  static const String filterPlaceholder = 'Filter by author or keyword...';

  // Buttons
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String logout = 'Logout';
  static const String sendResetLink = 'Send Reset Link';
  static const String backToLogin = 'Back to Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String newQuote = 'New Quote';
  static const String retry = 'Retry';
  static const String clearFilters = 'Clear Filters';
  static const String seeAll = 'See all';

  // Navigation
  static const String today = 'TODAY';
  static const String favorites = 'FAVORITES';
  static const String collections = 'COLLECTIONS';
  static const String profileNav = 'PROFILE';
  static const String discover = 'Discover';
  static const String categories = 'Categories';
  static const String saved = 'Saved';
  static const String create = 'Create';
  static const String settings = 'Settings';

  // Search & Filter
  static const String search = 'Search';
  static const String all = 'All';
  static const String authors = 'Authors';
  static const String categoriesFilter = 'Categories';
  static const String themes = 'Themes';
  static const String quotesMatching = 'Quotes matching';

  // Categories
  static const String motivation = 'Motivation';
  static const String love = 'Love';
  static const String success = 'Success';
  static const String wisdom = 'Wisdom';
  static const String humor = 'Humor';
  static const String moreCategories = 'More Categories';

  // Empty States
  static const String noFavoritesYet = 'No favorites yet';
  static const String startFavoriting =
      'Start favoriting quotes to see them here';
  static const String noQuotesFound = 'No quotes found';
  static const String noMatchesFound =
      "We couldn't find any matches for your current filters. Try broadening your search.";
  static const String noResults = 'No results found';

  // Profile
  static const String editProfile = 'Edit Profile';
  static const String notificationSettings = 'Notification Settings';
  static const String darkMode = 'Dark Mode';
  static const String privacySecurity = 'Privacy & Security';
  static const String account = 'ACCOUNT';
  static const String preferences = 'PREFERENCES';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String cancel = 'Cancel';

  // Error Messages (User-friendly)
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your internet connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorInvalidCredentials =
      'Invalid email or password. Please try again.';
  static const String errorEmailAlreadyExists =
      'This email is already registered. Please sign in instead.';
  static const String errorWeakPassword =
      'Password is too weak. Please use at least 8 characters.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorUserNotFound =
      'No account found with this email. Please sign up.';
  static const String errorTooManyRequests =
      'Too many attempts. Please wait a moment and try again.';
  static const String errorPasswordResetSent =
      'Password reset link has been sent to your email.';
  static const String errorFailedToLoad =
      'Failed to load data. Please try again.';
  static const String errorFailedToSave = 'Failed to save. Please try again.';
  static const String errorFailedToDelete =
      'Failed to delete. Please try again.';

  // Validation
  static const String validationEmailRequired = 'Please enter your email';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPasswordRequired = 'Please enter your password';
  static const String validationPasswordMinLength =
      'Password must be at least 8 characters';
  static const String validationFullNameRequired =
      'Please enter your full name';

  // Success Messages
  static const String successAccountCreated = 'Account created successfully!';
  static const String successLoggedIn = 'Welcome back!';
  static const String successPasswordReset =
      'Password reset link sent to your email';
  static const String successQuoteSaved = 'Quote saved to favorites';
  static const String successQuoteRemoved = 'Quote removed from favorites';

  // Notification Settings
  static const String notificationSettingsTitle = 'Notification Settings';
  static const String dailyQuoteNotifications = 'Daily Quote Notifications';
  static const String receiveDailyQuote = 'Receive a daily inspirational quote';
  static const String notificationTime = 'NOTIFICATION TIME';
  static const String time = 'Time';
  static const String quoteOfTheDay = 'Quote of the Day';
  static const String notificationInfoMessage =
      'You will receive a daily inspirational quote at the selected time each day.';
  static const String errorLoadingSettings = 'Failed to load settings';
  static const String errorSavingSettings = 'Failed to save settings';
  static const String errorSchedulingNotifications =
      'Failed to schedule notifications';

  // Share & Export
  static const String shareQuote = 'Share Quote';
  static const String shareAsImage = 'Share as Image';
  static const String shareAsText = 'Share as Text';
  static const String saveToGallery = 'Save to Gallery';
  static const String cardStyle = 'Card Style';
  static const String preview = 'Preview';
  static const String quoteSharedSuccess = 'Quote shared successfully!';
  static const String quoteSavedSuccess = 'Quote saved to gallery!';
  static const String errorSharingQuote = 'Failed to share quote';
  static const String errorSavingQuote = 'Failed to save quote';
  static const String errorSavingQuotePermissions =
      'Failed to save quote. Please check permissions.';

  // Settings
  static const String appearance = 'APPEARANCE';
  static const String accentColor = 'ACCENT COLOR';
  static const String fontSize = 'FONT SIZE';
  static const String themeMode = 'Theme Mode';
  static const String appearanceSettings = 'Appearance & Settings';
  static const String syncToProfile = 'Sync to profile';
  static const String settingsSynced = 'Settings synced to profile';
  static const String errorSyncingSettings = 'Failed to sync settings';
}
