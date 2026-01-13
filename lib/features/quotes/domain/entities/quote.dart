import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final String text;
  final String author;
  final String? authorImage;
  final String? categoryId;
  final String? categoryName;
  final int? likes;
  final int? shares;
  final bool? isFavorite;
  final bool? isLiked;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    this.categoryId,
    this.categoryName,
    this.likes,
    this.shares,
    this.isFavorite,
    this.isLiked,
    this.authorImage,
  });

  @override
  List<Object> get props => [id, text, author];

  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? authorImage,
    String? categoryId,
    String? categoryName,
    int? likes,
    int? shares,
    bool? isFavorite,
    bool? isLiked,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      authorImage: authorImage ?? this.authorImage,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      isFavorite: isFavorite ?? this.isFavorite,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
