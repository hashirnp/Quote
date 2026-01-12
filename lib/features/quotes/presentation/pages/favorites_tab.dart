import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/quotes_bloc.dart';
import '../widgets/quote_card.dart';
import '../../domain/entities/quote.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  String _searchQuery = '';
  bool _hasLoaded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
      _hasLoaded = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildFavoritesList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Search Icon Box (Optional based on exact look, or integrated)
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF171A21),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          // Search Input
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF171A21), // Dark background
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  bottom:
                      BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Filter by author or keyword...',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return BlocBuilder<QuotesBloc, QuotesState>(
      builder: (context, state) {
        if (!_hasLoaded &&
            state is! FavoritesLoaded &&
            state is! FavoritesLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
            _hasLoaded = true;
          });
        }

        if (state is FavoritesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          );
        }

        if (state is FavoritesLoaded) {
          final filteredQuotes = _filterQuotes(state.quotes, _searchQuery);

          if (filteredQuotes.isEmpty && state.quotes.isEmpty) {
            return _buildEmptyState();
          }

          if (filteredQuotes.isEmpty && _searchQuery.isNotEmpty) {
            return _buildNoResultsState();
          }

          return _buildQuotesList(filteredQuotes);
        }

        if (state is QuotesError) {
          return _buildErrorState(state.message);
        }

        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        );
      },
    );
  }

  Widget _buildQuotesList(List<Quote> quotes) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return QuoteCard(
          quote: quote,
          isFavorite: true,
          onFavoriteTap: () {
            context.read<QuotesBloc>().add(RemoveFavoriteQuoteEvent(quote));
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white.withValues(alpha: 0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Text(
        'No quotes found',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 18,
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
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<Quote> _filterQuotes(List<Quote> quotes, String query) {
    if (query.isEmpty) return quotes;
    final lowerQuery = query.toLowerCase();
    return quotes.where((quote) {
      return quote.text.toLowerCase().contains(lowerQuery) ||
          quote.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
