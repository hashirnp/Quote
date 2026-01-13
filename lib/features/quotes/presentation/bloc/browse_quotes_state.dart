part of 'browse_quotes_bloc.dart';

abstract class BrowseQuotesState extends Equatable {
  const BrowseQuotesState();

  @override
  List<Object> get props => [];
}

class BrowseQuotesInitial extends BrowseQuotesState {}

class BrowseQuotesLoading extends BrowseQuotesState {}

class BrowseQuotesLoaded extends BrowseQuotesState {
  final List<Quote> quotes;
  final List<Category> categories;
  final List<String> authors;
  final bool hasMore;
  final int page;
  final bool isLoadingMore;
  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;
  final String? author;

  const BrowseQuotesLoaded({
    required this.quotes,
    this.categories = const [],
    this.authors = const [],
    required this.hasMore,
    required this.page,
    this.isLoadingMore = false,
    this.categoryId,
    this.categoryName,
    this.searchQuery,
    this.author,
  });

  @override
  List<Object> get props => [
        quotes,
        categories,
        authors,
        hasMore,
        page,
        isLoadingMore,
        categoryId ?? '',
        categoryName ?? '',
        searchQuery ?? '',
        author ?? '',
      ];

  BrowseQuotesLoaded copyWith({
    List<Quote>? quotes,
    List<Category>? categories,
    List<String>? authors,
    bool? hasMore,
    int? page,
    bool? isLoadingMore,
    String? categoryId,
    String? categoryName,
    String? searchQuery,
    String? author,
  }) {
    return BrowseQuotesLoaded(
      quotes: quotes ?? this.quotes,
      categories: categories ?? this.categories,
      authors: authors ?? this.authors,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      searchQuery: searchQuery ?? this.searchQuery,
      author: author ?? this.author,
    );
  }
}

class BrowseQuotesCategoriesLoaded extends BrowseQuotesState {
  final List<Category> categories;

  const BrowseQuotesCategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class BrowseQuotesError extends BrowseQuotesState {
  final String message;

  const BrowseQuotesError({required this.message});

  @override
  List<Object> get props => [message];
}

