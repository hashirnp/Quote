import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

class TodayAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TodayAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.darkBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        AppStrings.dailyInspiration,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8),
      //     child: IconButton(
      //       icon: const Icon(
      //         Icons.settings,
      //         color: AppTheme.textPrimary,
      //         size: 24,
      //       ),
      //       onPressed: () {
      //         // Settings action
      //       },
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class FavoritesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;

  const FavoritesAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).textTheme.titleLarge?.color,
          size: 24,
        ),
        onPressed: onBackPressed,
      ),
      title: Text(
        AppStrings.yourFavorites,
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.only(right: 8),
      //     child: IconButton(
      //       icon: const Icon(
      //         Icons.more_vert,
      //         color: AppTheme.textPrimary,
      //         size: 24,
      //       ),
      //       onPressed: () {
      //         // Menu action
      //       },
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
