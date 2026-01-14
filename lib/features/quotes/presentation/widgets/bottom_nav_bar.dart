import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          top: BorderSide(
            color: theme.scaffoldBackgroundColor,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: theme.textTheme.bodyMedium?.color,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: AppStrings.discover,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: AppStrings.saved,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}
