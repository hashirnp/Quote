import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_handler.dart';
import '../bloc/collections_bloc.dart';
import '../bloc/quotes_bloc.dart';
import '../widgets/quote_card.dart';
import '../../domain/entities/collection.dart';

class CollectionDetailPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailPage({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  bool _quotesLoadedForThisCollection = false;

  @override
  void initState() {
    super.initState();
    // Check if we already have quotes loaded for this collection
    final currentState = context.read<CollectionsBloc>().state;
    if (currentState is CollectionQuotesLoaded &&
        currentState.collectionId == widget.collection.id) {
      _quotesLoadedForThisCollection = true;
    } else {
      // Load quotes for this collection
      context.read<CollectionsBloc>().add(
            LoadCollectionQuotesEvent(collectionId: widget.collection.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
              Navigator.pop(context);
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.collection.name,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.collection.description != null)
                Text(
                  widget.collection.description!,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        body: BlocBuilder<CollectionsBloc, CollectionsState>(
          builder: (context, state) {
            debugPrint('CollectionDetailPage state: $state');
            // Mark that we have quotes loaded when CollectionQuotesLoaded is emitted
            if (state is CollectionQuotesLoaded &&
                state.collectionId == widget.collection.id) {
              _quotesLoadedForThisCollection = true;
            }

            // If state is CollectionsLoaded and we haven't loaded quotes yet,
            // trigger a reload (this happens when navigating from collections list)
            if (state is CollectionsLoaded && !_quotesLoadedForThisCollection) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // context.read<CollectionsBloc>().add(
                //       LoadCollectionQuotesEvent(
                //         collectionId: widget.collection.id,
                //       ),
                //     );
              });
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              );
            }

            if (state is CollectionsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              );
            }

            if (state is CollectionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      ErrorHandler.getErrorMessage(state.message),
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CollectionsBloc>().add(
                              LoadCollectionQuotesEvent(
                                collectionId: widget.collection.id,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      child: Text(
                        AppStrings.retry,
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if ((state is CollectionQuotesLoaded) &&
                state.collectionId == widget.collection.id) {
              if (state.quotes.isEmpty) {
                return _buildEmptyState();
              }

              return BlocBuilder<QuotesBloc, QuotesState>(
                builder: (context, quotesState) {
                  // Get updated quotes with like/favorite status directly from state
                  // No need to update CollectionsBloc state, just compute here
                  final updatedQuotes = state.quotes.map((q) {
                    bool isLiked = q.isLiked ?? false;
                    bool isFavorite = q.isFavorite ?? false;

                    // Check like status from LikedQuotesState
                    if (quotesState is LikedQuotesState) {
                      final quoteId =
                          q.id.isNotEmpty ? q.id : '${q.text}|||${q.author}';
                      isLiked = quotesState.likedQuoteIds.contains(quoteId);
                    }

                    // Check favorite status
                    if (quotesState is FavoritesLoaded) {
                      isFavorite = quotesState.quotes.any(
                        (fav) => fav.text == q.text && fav.author == q.author,
                      );
                    }

                    // Only update if status changed
                    if (isLiked != (q.isLiked ?? false) ||
                        isFavorite != (q.isFavorite ?? false)) {
                      return q.copyWith(
                        isLiked: isLiked,
                        isFavorite: isFavorite,
                      );
                    }

                    return q;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: updatedQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = updatedQuotes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuoteCard(
                          quote: quote,
                          showFavoriteIcon: true,
                          showAddToCollection: false,
                          // Don't remove from collection when favorited/liked
                          // Only remove when user explicitly removes from collection
                        ),
                      );
                    },
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: (theme.textTheme.titleLarge?.color ?? Colors.white).withValues(alpha: 0.3),
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'No quotes in this collection',
            style: GoogleFonts.poppins(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add quotes to this collection to see them here',
            style: GoogleFonts.poppins(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
