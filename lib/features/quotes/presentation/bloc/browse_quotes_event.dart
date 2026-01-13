part of 'browse_quotes_bloc.dart';

abstract class BrowseQuotesEvent extends Equatable {
  const BrowseQuotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuotesEvent extends BrowseQuotesEvent {
  final String? categoryId;
  final String? searchQuery;
  final String? author;

  const LoadQuotesEvent({
    this.categoryId,
    this.searchQuery,
    this.author,
  });

  @override
  List<Object?> get props => [categoryId, searchQuery, author];
}

class LoadMoreQuotesEvent extends BrowseQuotesEvent {
  const LoadMoreQuotesEvent();
}

class LoadCategoriesEvent extends BrowseQuotesEvent {
  const LoadCategoriesEvent();
}

class SearchQuotesEvent extends BrowseQuotesEvent {
  final String query;
  final String? categoryId;
  final String? author;

  const SearchQuotesEvent({
    required this.query,
    this.categoryId,
    this.author,
  });

  @override
  List<Object?> get props => [query, categoryId, author];
}

class FilterByCategoryEvent extends BrowseQuotesEvent {
  final String? categoryId;
  final String? categoryName;

  const FilterByCategoryEvent({
    this.categoryId,
    this.categoryName,
  });

  @override
  List<Object?> get props => [categoryId, categoryName];
}

class FilterByAuthorEvent extends BrowseQuotesEvent {
  final String? author;

  const FilterByAuthorEvent({this.author});

  @override
  List<Object?> get props => [author];
}

class ClearFiltersEvent extends BrowseQuotesEvent {
  const ClearFiltersEvent();
}

class RefreshQuotesEvent extends BrowseQuotesEvent {
  const RefreshQuotesEvent();
}

class LoadAuthorsEvent extends BrowseQuotesEvent {
  final String? searchQuery;

  const LoadAuthorsEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}
