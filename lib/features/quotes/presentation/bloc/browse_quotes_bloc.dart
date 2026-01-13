import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/quote.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_quotes.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/search_quotes.dart';
import '../../domain/usecases/get_authors.dart';

part 'browse_quotes_event.dart';
part 'browse_quotes_state.dart';

class BrowseQuotesBloc extends Bloc<BrowseQuotesEvent, BrowseQuotesState> {
  final GetQuotes getQuotes;
  final GetCategories getCategories;
  final SearchQuotes searchQuotes;
  final GetAuthors getAuthors;

  BrowseQuotesBloc({
    required this.getQuotes,
    required this.getCategories,
    required this.searchQuotes,
    required this.getAuthors,
  }) : super(BrowseQuotesInitial()) {
    on<LoadQuotesEvent>(_onLoadQuotes);
    on<LoadMoreQuotesEvent>(_onLoadMoreQuotes);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SearchQuotesEvent>(_onSearchQuotes);
    on<FilterByCategoryEvent>(_onFilterByCategory);
    on<FilterByAuthorEvent>(_onFilterByAuthor);
    on<ClearFiltersEvent>(_onClearFilters);
    on<RefreshQuotesEvent>(_onRefreshQuotes);
    on<LoadAuthorsEvent>(_onLoadAuthors);
  }

  Future<void> _onLoadQuotes(
    LoadQuotesEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    emit(BrowseQuotesLoading());
    try {
      final quotes = await getQuotes(
        page: 1,
        limit: 20,
        categoryId: event.categoryId,
        searchQuery: event.searchQuery,
        author: event.author,
      );

      // Get category name if categoryId is provided
      String? categoryName;
      if (event.categoryId != null && state is BrowseQuotesLoaded) {
        final currentState = state as BrowseQuotesLoaded;
        try {
          final category = currentState.categories.firstWhere(
            (cat) => cat.id == event.categoryId,
          );
          categoryName = category.name.isNotEmpty ? category.name : null;
        } catch (e) {
          // Category not found in current state, will be loaded later
          categoryName = null;
        }
      }

      emit(BrowseQuotesLoaded(
        quotes: quotes,
        hasMore: quotes.length >= 20,
        page: 1,
        categoryId: event.categoryId,
        categoryName: categoryName,
        searchQuery: event.searchQuery,
        author: event.author,
      ));
    } catch (e) {
      emit(BrowseQuotesError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreQuotes(
    LoadMoreQuotesEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    if (state is BrowseQuotesLoaded) {
      final currentState = state as BrowseQuotesLoaded;
      if (!currentState.hasMore || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final newQuotes = await getQuotes(
          page: currentState.page + 1,
          limit: 20,
          categoryId: currentState.categoryId,
          searchQuery: currentState.searchQuery,
          author: currentState.author,
        );

        final updatedQuotes = [...currentState.quotes, ...newQuotes];
        emit(currentState.copyWith(
          quotes: updatedQuotes,
          page: currentState.page + 1,
          hasMore: newQuotes.length >= 20,
          isLoadingMore: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
        emit(BrowseQuotesError(message: e.toString()));
      }
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    try {
      final categories = await getCategories();
      if (state is BrowseQuotesLoaded) {
        final currentState = state as BrowseQuotesLoaded;
        // Update category name if categoryId exists but name is missing
        String? categoryName = currentState.categoryName;
        if (currentState.categoryId != null && categoryName == null) {
          try {
            final category = categories.firstWhere(
              (cat) => cat.id == currentState.categoryId,
            );
            categoryName = category.name.isNotEmpty ? category.name : null;
          } catch (e) {
            // Category not found, keep existing categoryName
            categoryName = currentState.categoryName;
          }
        }
        emit(currentState.copyWith(
          categories: categories,
          categoryName: categoryName,
        ));
      } else {
        emit(BrowseQuotesCategoriesLoaded(categories: categories));
      }
    } catch (e) {
      // Don't emit error for categories, just log it
    }
  }

  Future<void> _onSearchQuotes(
    SearchQuotesEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    emit(BrowseQuotesLoading());
    try {
      final quotes = await searchQuotes(
        query: event.query,
        categoryId: event.categoryId,
        author: event.author,
      );
      emit(BrowseQuotesLoaded(
        quotes: quotes,
        hasMore: false,
        page: 1,
        searchQuery: event.query,
        categoryId: event.categoryId,
        author: event.author,
      ));
    } catch (e) {
      emit(BrowseQuotesError(message: e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    // Get categories first if not loaded
    if (state is! BrowseQuotesLoaded ||
        (state as BrowseQuotesLoaded).categories.isEmpty) {
      await _onLoadCategories(const LoadCategoriesEvent(), emit);
    }

    // Find category name
    String? categoryName;
    if (event.categoryId != null) {
      List<Category> categories = [];
      if (state is BrowseQuotesLoaded) {
        categories = (state as BrowseQuotesLoaded).categories;
      } else if (state is BrowseQuotesCategoriesLoaded) {
        categories = (state as BrowseQuotesCategoriesLoaded).categories;
      }

      if (categories.isNotEmpty) {
        try {
          final category = categories.firstWhere(
            (cat) => cat.id == event.categoryId,
          );
          categoryName = category.name.isNotEmpty ? category.name : null;
        } catch (e) {
          // Category not found, use the provided categoryName from event
          categoryName = event.categoryName;
        }
      } else {
        // If categories list is empty, use the provided categoryName from event
        categoryName = event.categoryName;
      }
    }

    emit(BrowseQuotesLoading());
    try {
      final quotes = await getQuotes(
        page: 1,
        limit: 20,
        categoryId: event.categoryId,
      );

      // Get categories if not already loaded
      List<Category> categories = [];
      if (state is BrowseQuotesLoaded) {
        categories = (state as BrowseQuotesLoaded).categories;
      } else if (state is BrowseQuotesCategoriesLoaded) {
        categories = (state as BrowseQuotesCategoriesLoaded).categories;
      }

      if (categories.isEmpty) {
        categories = await getCategories();
      }

      emit(BrowseQuotesLoaded(
        quotes: quotes,
        categories: categories,
        hasMore: quotes.length >= 20,
        page: 1,
        categoryId: event.categoryId,
        categoryName: categoryName ?? event.categoryName,
      ));
    } catch (e) {
      emit(BrowseQuotesError(message: e.toString()));
    }
  }

  Future<void> _onFilterByAuthor(
    FilterByAuthorEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    add(LoadQuotesEvent(author: event.author));
  }

  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    add(const LoadQuotesEvent());
  }

  Future<void> _onRefreshQuotes(
    RefreshQuotesEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    if (state is BrowseQuotesLoaded) {
      final currentState = state as BrowseQuotesLoaded;
      add(LoadQuotesEvent(
        categoryId: currentState.categoryId,
        searchQuery: currentState.searchQuery,
        author: currentState.author,
      ));
    } else {
      add(const LoadQuotesEvent());
    }
  }

  Future<void> _onLoadAuthors(
    LoadAuthorsEvent event,
    Emitter<BrowseQuotesState> emit,
  ) async {
    try {
      final authors = await getAuthors(searchQuery: event.searchQuery);
      if (state is BrowseQuotesLoaded) {
        final currentState = state as BrowseQuotesLoaded;
        emit(currentState.copyWith(authors: authors));
      }
    } catch (e) {
      // Don't emit error for authors
    }
  }
}
