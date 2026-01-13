import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/widget_service.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/quotes_bloc.dart';
import '../bloc/browse_quotes_bloc.dart';
import '../widgets/app_bars.dart';
import '../widgets/bottom_nav_bar.dart';
import 'browse_page.dart';
import 'favorites_tab.dart';
import '../../../auth/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void setCurrentIndex(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
      _handleBottomNavTap(index);
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if opened from widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWidgetIntent();
    });

    // Load quotes for browse page when app starts
    context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
    context.read<BrowseQuotesBloc>().add(const LoadCategoriesEvent());

    // Load likes and favorites first (in parallel) for caching
    final quotesBloc = context.read<QuotesBloc>();
    quotesBloc.add(const LoadLikedQuotesEvent());
    quotesBloc.add(const LoadFavoritesEvent());

    // Then load daily quote (will use cached likes/favorites)
    quotesBloc.add(const GetDailyQuoteEvent());

    // Reschedule notifications when app opens to ensure they're current
    // Run in background to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = getIt<NotificationService>();
      notificationService.rescheduleNotificationsIfNeeded().catchError((error) {
        // Silently handle errors
      });

      // Update widget when app opens
      final widgetService = getIt<WidgetService>();
      widgetService.updateIfNeeded().catchError((error) {
        // Silently handle errors
      });
    });
  }

  void _checkWidgetIntent() async {
    try {
      const platform = MethodChannel('com.quote.app/widget');

      // Set up listener for widget taps (iOS)
      platform.setMethodCallHandler((call) async {
        if (call.method == 'onWidgetTap' && mounted) {
          // Navigate to browse page (index 0) which shows daily quote
          setState(() {
            _currentIndex = 0;
          });
          // Load daily quote
          context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
        }
      });

      // Check if app was opened from widget (Android)
      final openDailyQuote =
          await platform.invokeMethod<bool>('getWidgetIntent') ?? false;

      if (openDailyQuote && mounted) {
        // Navigate to browse page (index 0) which shows daily quote
        setState(() {
          _currentIndex = 0;
        });
        // Load daily quote
        context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
      }
    } catch (e) {
      // Platform channel might not be available, ignore
      debugPrint('Error checking widget intent: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          BrowsePage(),
          FavoritesTab(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    // BrowsePage and ProfilePage have their own app bars
    if (_currentIndex == 1) {
      return FavoritesAppBar(
        onBackPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      );
    }
    return null;
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load data when switching tabs
    if (index == 0) {
      // Load quotes when switching to browse/discover tab
      context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
      context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
    } else if (index == 1) {
      // Load favorites when switching to favorites tab
      context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
    }
    // Index 2 is Create page (placeholder)
    // Index 3 is Settings/Profile page
  }

  Widget _buildCreatePage() {
    // Placeholder for create page - can be implemented later
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Create',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Create Page\n(Coming Soon)',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
