import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/error_handler.dart';
import '../bloc/quotes_bloc.dart';
import '../bloc/collections_bloc.dart';
import '../widgets/quote_card.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/collection.dart';
import 'collection_detail_page.dart';
import 'create_collection_page.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  bool _hasLoaded = false;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Load collections when switching to collections tab
        // Also reload if state is CollectionQuotesLoaded (coming back from detail page)
        final currentState = context.read<CollectionsBloc>().state;
        if (!_hasLoaded || currentState is! CollectionsLoaded) {
          context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotesBloc>().add(GetFavoriteQuotesEvent());
      context.read<QuotesBloc>().add(const LoadLikedQuotesEvent());
      context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
      _hasLoaded = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFavoritesList(),
              _buildCollectionsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.filterPlaceholder,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: AppStrings.favorites),
          Tab(text: AppStrings.collections),
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

  Widget _buildCollectionsList() {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        // If state is CollectionQuotesLoaded (from viewing collection detail),
        // reload collections to show the collections list
        if (state is CollectionQuotesLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
          });
          // Show previous state or loading while reloading
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          );
        }

        if (state is CollectionsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          );
        }

        if (state is CollectionsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  ErrorHandler.getErrorMessage(state.message),
                  style: GoogleFonts.poppins(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<CollectionsBloc>().add(
                          const LoadCollectionsEvent(),
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

        if (state is CollectionsLoaded) {
          final filteredCollections = _filterCollections(
            state.collections,
            _searchQuery,
          );

          if (filteredCollections.isEmpty && state.collections.isEmpty) {
            return _buildEmptyCollectionsState();
          }

          if (filteredCollections.isEmpty && _searchQuery.isNotEmpty) {
            return _buildNoResultsState();
          }

          return _buildCollectionsGrid(filteredCollections);
        }

        // If state is CollectionsInitial or unknown, load collections
        if (state is CollectionsInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<CollectionsBloc>().add(const LoadCollectionsEvent());
          });
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
    if (quotes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QuoteCard(
            quote: quote.copyWith(isFavorite: true),
            isFavorite: true,
            onFavoriteTap: () {
              context.read<QuotesBloc>().add(RemoveFavoriteQuoteEvent(quote));
            },
          ),
        );
      },
    );
  }

  Widget _buildCollectionsGrid(List<Collection> collections) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: collections.length + 1, // +1 for "Create Collection" card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCreateCollectionCard();
        }
        return _buildCollectionCard(collections[index - 1]);
      },
    );
  }

  Widget _buildCreateCollectionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateCollectionPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.1),
              AppTheme.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppTheme.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Create Collection',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(Collection collection) {
    final cardColor = collection.color != null
        ? _parseColor(collection.color!)
        : AppTheme.primaryBlue;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailPage(collection: collection),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withValues(alpha: 0.15),
              cardColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: collection.icon != null
                          ? Text(
                              collection.icon!,
                              style: const TextStyle(fontSize: 20),
                            )
                          : Icon(
                              Icons.folder_rounded,
                              color: cardColor,
                              size: 22,
                            ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showCollectionMenu(context, collection),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (collection.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      collection.description!,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 14,
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${collection.quoteCount} quotes',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppTheme.primaryBlue;
    }
  }

  void _showCollectionMenu(BuildContext context, Collection collection) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: MediaQuery.of(context).padding.top > 0
              ? MediaQuery.of(context).padding.top
              : 0,
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                  title: Text(
                    'Edit Collection',
                    style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateCollectionPage(collection: collection),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Collection',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, collection);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(
          'Delete Collection',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CollectionsBloc>().add(
                    DeleteCollectionEvent(collectionId: collection.id),
                  );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
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
            AppStrings.noFavoritesYet,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.startFavoriting,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCollectionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            color: Colors.white.withValues(alpha: 0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No collections yet',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first collection to organize quotes',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCollectionPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              'Create Collection',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Text(
        AppStrings.noResults,
        style: GoogleFonts.poppins(
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
            ErrorHandler.getErrorMessage(message),
            style: GoogleFonts.poppins(color: Colors.white),
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
            child: Text(
              AppStrings.retry,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
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

  List<Collection> _filterCollections(
    List<Collection> collections,
    String query,
  ) {
    if (query.isEmpty) return collections;
    final lowerQuery = query.toLowerCase();
    return collections.where((collection) {
      return collection.name.toLowerCase().contains(lowerQuery) ||
          (collection.description != null &&
              collection.description!.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
