import 'package:flutter/material.dart';
import '../../domain/entities/quote.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/share_helper.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showFavoriteIcon;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showFavoriteIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171A21), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Quote Icon and Heart Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Quote Icon
              const Text(
                '”',
                style: TextStyle(
                  color: Color(0xff11254d),
                  fontSize: 60,
                  height: 0.5,
                  fontFamily: 'serif',
                ),
              ),
              // Heart Button (Blue Circle)
              if (showFavoriteIcon)
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? AppTheme.primaryBlue
                          : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.white : AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote Text
          Text(
            quote.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Divider Line
          Divider(
            color: Colors.white.withValues(alpha: 0.1),
            height: 1,
          ),
          const SizedBox(height: 16),

          // Bottom Row: Author and Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '— ${quote.author}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: () => ShareHelper.shareQuote(quote),
                child: Icon(
                  Icons.ios_share,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
