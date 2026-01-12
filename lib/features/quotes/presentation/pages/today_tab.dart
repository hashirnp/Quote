import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/share_helper.dart';
import '../bloc/quotes_bloc.dart';
// Note: I am replacing ActionButton usage with custom widgets locally
// to match the specific shapes (Circle vs Large Square) in the screenshot exactly.
import '../../domain/entities/quote.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  Quote? _lastQuote;
  bool _lastIsFavorite = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuotesBloc, QuotesState>(
      listener: (context, state) {
        if (state is QuotesLoaded) {
          _lastQuote = state.quote;
          _lastIsFavorite = state.isFavorite;
        }
      },
      builder: (context, state) {
        // Use cached data if available to prevent flicker
        if ((state is FavoritesLoaded || state is QuotesLoading) &&
            _lastQuote != null) {
          return _buildQuoteContent(_lastQuote!, _lastIsFavorite);
        }

        if (state is QuotesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          );
        }

        if (state is QuotesError) {
          return _buildErrorState(state.message);
        }

        if (state is QuotesLoaded) {
          return _buildQuoteContent(state.quote, state.isFavorite);
        }

        if (_lastQuote != null) {
          return _buildQuoteContent(_lastQuote!, _lastIsFavorite);
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        );
      },
    );
  }

  Widget _buildQuoteContent(Quote quote, bool isFavorite) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Quote Text Section
                  _buildQuoteText(quote.text),
                  const SizedBox(height: 30),

                  // 2. Author Section
                  _buildAuthor(quote.author),
                ],
              ),
            ),

            // 4. Bottom Action Buttons
            _buildActionButtons(quote, isFavorite),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteText(String text) {
    return Stack(
      children: [
        // Opening Quote (Top Left)
        const Positioned(
          left: 0,
          top: 0,
          child: Text(
            '“', // Double quote char
            style: TextStyle(
              color: Color(0xff11254d), fontSize: 60,
              height: 1,
              fontFamily: 'serif', // Often quote marks look better in serif
            ),
          ),
        ),

        // Actual Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Text(
            text,
            style: GoogleFonts.gotu(
              color: Colors.white, // Explicitly white based on screenshot
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Closing Quote (Bottom Right)
        const Positioned(
          right: 0,
          bottom: 0,
          child: Text(
            '”',
            style: TextStyle(
              color: Color(0xff11254d),
              fontSize: 60,
              height: 0.5,
              fontFamily: 'serif',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthor(String author) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 1, // Thinner line
          color: AppTheme.primaryBlue,
        ),
        const SizedBox(width: 12),
        Text(
          author,
          style: GoogleFonts.gotu(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 30,
          height: 1,
          color: AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildActionButtons(Quote quote, bool isFavorite) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Favorite Button (Circle)
            _buildCircleButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              onTap: () {
                if (isFavorite) {
                  context
                      .read<QuotesBloc>()
                      .add(RemoveFavoriteQuoteEvent(quote));
                } else {
                  context.read<QuotesBloc>().add(SaveFavoriteQuoteEvent(quote));
                }
              },
            ),

            const SizedBox(width: 30),

            // Center: New Quote Button (Big Blue Square)
            Container(
              height: 70, // Larger size
              width: 70,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    context.read<QuotesBloc>().add(GetRandomQuoteEvent());
                  },
                  child: const Icon(
                    Icons.shuffle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 30),

            // Right: Share Button (Circle)
            _buildCircleButton(
              icon: Icons
                  .ios_share, // Use iOS style share icon if available, or just share
              onTap: () {
                ShareHelper.shareQuote(quote);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Text label below the center button
        const Text(
          'New Quote',
          style: TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2229), // Dark grey/blue background for buttons
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(
            icon,
            color: Colors.grey, // Grey icon color
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<QuotesBloc>().add(GetRandomQuoteEvent());
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
