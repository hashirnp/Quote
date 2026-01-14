import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/quote.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/settings_helper.dart';
import '../bloc/quotes_bloc.dart';
import '../bloc/collections_bloc.dart';
import '../pages/share_quote_page.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showFavoriteIcon;
  final bool showInteractionBar;
  final bool showAddToCollection;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showFavoriteIcon = true,
    this.showInteractionBar = true,
    this.showAddToCollection = false,
  });

  void _handleFavoriteTap(BuildContext context) {
    if (onFavoriteTap != null) {
      onFavoriteTap!();
    } else {
      // Default behavior: use QuotesBloc
      final quotesBloc = context.read<QuotesBloc>();
      // Check bloc's cache for current favorite status (more reliable)
      final isCurrentlyFavorite =
          quotesBloc.isQuoteFavorite(quote) || (quote.isFavorite ?? false);
      if (isCurrentlyFavorite) {
        quotesBloc.add(RemoveFavoriteQuoteEvent(quote));
      } else {
        quotesBloc.add(SaveFavoriteQuoteEvent(quote));
      }
    }
  }

  void _handleCopyTap(BuildContext context) {
    Clipboard.setData(ClipboardData(text: '${quote.text}\n— ${quote.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleLikeTap(BuildContext context) {
    final quotesBloc = context.read<QuotesBloc>();
    // Check bloc's cache for current like status (more reliable)
    final isCurrentlyLiked =
        quotesBloc.isQuoteLiked(quote) || (quote.isLiked ?? false);

    if (isCurrentlyLiked) {
      quotesBloc.add(UnlikeQuoteEvent(quote));
    } else {
      quotesBloc.add(LikeQuoteEvent(quote));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the passed-in favorite status as default, but will be overridden by BlocBuilder
    final defaultIsFav = quote.isFavorite ?? isFavorite;
    final currentlyLiked = quote.isLiked ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getGradientForIndex(context, quote.hashCode),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote Text
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              final fontSize =
                  SettingsHelper.getFontSizeFromState(settingsState);
              return Text(
                quote.text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Author
          Row(
            children: [
              if (quote.authorImage != null) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      quote.authorImage!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Placeholder when image fails to load
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Text(
                '— ${quote.author}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          if (showInteractionBar) ...[
            const SizedBox(height: 20),
            // Interaction Bar
            Row(
              children: [
                // Like Button (separate from favorite)
                BlocBuilder<QuotesBloc, QuotesState>(
                  builder: (context, state) {
                    // Use bloc's cached data
                    final quotesBloc = context.read<QuotesBloc>();
                    final liked =
                        quotesBloc.isQuoteLiked(quote) || currentlyLiked;

                    return GestureDetector(
                      onTap: () => _handleLikeTap(context),
                      child: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked
                            ? Colors.redAccent
                            : Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                // Share Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShareQuotePage(quote: quote),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.share,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                const Spacer(),
                // Copy Button
                GestureDetector(
                  onTap: () => _handleCopyTap(context),
                  child: Icon(
                    Icons.copy,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Bookmark Button - Listen to bloc state for real-time updates
                BlocBuilder<QuotesBloc, QuotesState>(
                  builder: (context, state) {
                    // Use bloc's cached data to check favorite status
                    final quotesBloc = context.read<QuotesBloc>();
                    final isFav =
                        quotesBloc.isQuoteFavorite(quote) || defaultIsFav;

                    return GestureDetector(
                      onTap: () => _handleFavoriteTap(context),
                      child: Icon(
                        isFav ? Icons.bookmark : Icons.bookmark_border,
                        color: isFav
                            ? AppTheme.primaryBlue
                            : Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    );
                  },
                ),
                if (showAddToCollection) ...[
                  const SizedBox(width: 16),
                  // Add to Collection Button
                  GestureDetector(
                    onTap: () => _showAddToCollectionDialog(context),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddToCollectionDialog(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: BlocBuilder<CollectionsBloc, CollectionsState>(
          builder: (context, state) {
            if (state is CollectionsLoaded) {
              if (state.collections.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No collections yet',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to create collection
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                        child: Text(
                          'Create Collection',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Add to Collection',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.collections.map((collection) {
                      return ListTile(
                        leading: collection.icon != null
                            ? Text(
                                collection.icon!,
                                style: const TextStyle(fontSize: 24),
                              )
                            : const Icon(
                                Icons.folder,
                                color: AppTheme.primaryBlue,
                              ),
                        title: Text(
                          collection.name,
                          style: GoogleFonts.poppins(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          '${collection.quoteCount} quotes',
                          style: GoogleFonts.poppins(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          context.read<CollectionsBloc>().add(
                                AddQuoteToCollectionEvent(
                                  collectionId: collection.id,
                                  quote: quote,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to ${collection.name}',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              );
            }

            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LinearGradient _getGradientForIndex(BuildContext context, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDark) {
      // Dark theme gradient
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E),
          Color(0xFF16213E),
        ],
      );
    } else {
      // Light theme gradient
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4A90E2),
          Color(0xFF6BA3E8),
        ],
      );
    }
  }
}
