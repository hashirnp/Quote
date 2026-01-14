import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../bloc/browse_quotes_bloc.dart';
import '../widgets/quote_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Authors, 2: Categories, 3: Themes
  String? _selectedCategoryId;
  String? _selectedAuthor;

  @override
  void initState() {
    super.initState();
    context.read<BrowseQuotesBloc>().add(const LoadCategoriesEvent());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<BrowseQuotesBloc>().add(const LoadQuotesEvent());
    } else {
      context.read<BrowseQuotesBloc>().add(
            SearchQuotesEvent(
              query: query,
              categoryId: _selectedCategoryId,
              author: _selectedAuthor,
            ),
          );
      // Load authors when searching
      if (_selectedFilterIndex == 1) {
        context
            .read<BrowseQuotesBloc>()
            .add(LoadAuthorsEvent(searchQuery: query));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.search,
          style: GoogleFonts.poppins(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
          // Filter Tabs
          _buildFilterTabs(),
          // Content
          Expanded(
            child: BlocBuilder<BrowseQuotesBloc, BrowseQuotesState>(
              builder: (context, state) {
                if (state is BrowseQuotesLoading) {
                  return _buildLoadingState();
                } else if (state is BrowseQuotesError) {
                  return _buildErrorState(state.message);
                } else if (state is BrowseQuotesLoaded) {
                  if (state.quotes.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildQuotesList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.search,
              color: AppTheme.primaryBlue,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.searchPlaceholder,
                hintStyle: GoogleFonts.poppins(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: theme.textTheme.bodyMedium?.color),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterTab(AppStrings.all, 0),
          const SizedBox(width: 12),
          _buildFilterTab(AppStrings.authors, 1),
          const SizedBox(width: 12),
          _buildFilterTab(AppStrings.categoriesFilter, 2),
          const SizedBox(width: 12),
          _buildFilterTab(AppStrings.themes, 3),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQuotesList(BrowseQuotesLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Authors Section (if authors available)
        // if (state.authors.isNotEmpty && _selectedFilterIndex == 1) ...[
        //   _buildAuthorsSection(state.authors),
        //   const SizedBox(height: 24),
        // ],
        // Quotes Section
        if (state.quotes.isNotEmpty) ...[
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${AppStrings.quotesMatching} "${_searchController.text}"',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ...state.quotes.map((quote) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuoteCard(quote: quote),
              )),
        ],
      ],
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
    final theme = Theme.of(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 16,
            width: 150,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
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
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _onSearchChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                AppStrings.retry,
                style: GoogleFonts.poppins(
                  color: Colors.white,
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
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noQuotesFound,
              style: GoogleFonts.poppins(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noMatchesFound,
              style: GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
