import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/quotes_bloc.dart';
import '../widgets/app_bars.dart';
import '../widgets/bottom_nav_bar.dart';
import 'today_tab.dart';
import 'favorites_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load random quote when app starts
    context.read<QuotesBloc>().add(GetRandomQuoteEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          TodayTab(),
          FavoritesTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex == 0) {
      return const TodayAppBar();
    }
    return FavoritesAppBar(
      onBackPressed: () {
        setState(() {
          _currentIndex = 0;
        });
      },
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load data when switching tabs
    if (index == 1) {
      // Load favorites when switching to favorites tab
      context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
    }
    // Note: We don't reload quote when switching back to Today tab
    // The TodayTab widget preserves the last quote shown
  }
}
