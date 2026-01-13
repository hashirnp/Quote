import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_handler.dart';
import '../bloc/browse_quotes_bloc.dart';
import '../bloc/quotes_bloc.dart';
import '../widgets/quote_card.dart';
import '../widgets/daily_quote_widget.dart';
import 'search_page.dart';
import 'categories_page.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
    context.read<BrowseQuotesBloc>().add(const LoadCategoriesEvent());
    // Load daily quote
    context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
    // Load favorites to check favorite status
    context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
    // Load liked quotes
    context.read<QuotesBloc>().add(const LoadLikedQuotesEvent());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BrowseQuotesBloc>().add(const LoadMoreQuotesEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
          builder: (context, state) {
            final hasCategoryFilter = state is BrowseQuotesLoaded &&
                state.categoryId != null &&
                state.categoryName != null;

            if (hasCategoryFilter) {
              return IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () {
                  context
                      .read<BrowseQuotesBloc>()
                      .add(const ClearFiltersEvent());
                },
              );
            }

            return IconButton(
              icon: const Icon(Icons.search, color: AppTheme.textPrimary),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPage()),
                );
                // Clear search query when returning from search page
                context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
              },
            );
          },
        ),
        title: BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
          builder: (context, state) {
            String title = 'Inspiration';
            if (state is BrowseQuotesLoaded && state.categoryName != null) {
              title = state.categoryName!;
            }
            return Text(
              title,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
            builder: (context, state) {
              final hasCategoryFilter = state is BrowseQuotesLoaded &&
                  state.categoryId != null &&
                  state.categoryName != null;

              if (hasCategoryFilter) {
                return IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                  onPressed: () {
                    context
                        .read<BrowseQuotesBloc>()
                        .add(const ClearFiltersEvent());
                  },
                  tooltip: 'Clear filter',
                );
              }

              return IconButton(
                icon: const Icon(Icons.tune, color: AppTheme.textPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
        builder: (context, state) {
          if (state is BrowseQuotesLoading) {
            return _buildLoadingState();
          } else if (state is BrowseQuotesError) {
            log('BrowseQuotesError: ${state.message}');
            return _buildErrorState(state.message);
          } else if (state is BrowseQuotesLoaded) {
            if (state.quotes.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<BrowseQuotesBloc>()
                    .add(const RefreshQuotesEvent());
                context.read<QuotesBloc>().add(const GetDailyQuoteEvent());
              },
              color: AppTheme.primaryBlue,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemCount: state.quotes.length +
                    (state.isLoadingMore ? 1 : 0) +
                    1, // +1 for daily quote widget
                itemBuilder: (context, index) {
                  // First item is the daily quote widget
                  if (index == 0) {
                    return const DailyQuoteWidget();
                  }

                  // Adjust index for quotes list
                  final quoteIndex = index - 1;

                  if (quoteIndex >= state.quotes.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    );
                  }

                  return BlocBuilder<QuotesBloc, QuotesState>(
                    builder: (context, quotesState) {
                      final currentQuote = state.quotes[quoteIndex];

                      // Use bloc's cache methods directly for real-time updates
                      final quotesBloc = context.read<QuotesBloc>();
                      final isFavorite =
                          quotesBloc.isQuoteFavorite(currentQuote) ||
                              (currentQuote.isFavorite ?? false);
                      final isLiked = quotesBloc.isQuoteLiked(currentQuote) ||
                          (currentQuote.isLiked ?? false);

                      // Create a quote with updated favorite and like status
                      final quote = currentQuote.copyWith(
                        isFavorite: isFavorite,
                        isLiked: isLiked,
                      );

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: QuoteCard(
                          quote: quote,
                          showAddToCollection: true,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large placeholder for quote text
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // Shorter placeholder for author
          Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          // Interaction bar placeholders
          Row(
            children: [
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              ErrorHandler.getErrorMessage(message),
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                AppStrings.retry,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Large circular icon with magnifying glass
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.textSecondary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.search_off,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.noQuotesFound,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.noMatchesFound,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<BrowseQuotesBloc>()
                          .add(const ClearFiltersEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.clearFilters,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
