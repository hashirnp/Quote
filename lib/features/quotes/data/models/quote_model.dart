import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.id,
    required super.text,
    required super.author,
    super.authorImage,
    super.categoryId,
    super.categoryName,
    super.likes,
    super.shares,
    super.isFavorite,
    super.isLiked,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] ?? json['q'] ?? '',
      author: json['author'] ?? json['a'] ?? 'Unknown',
      authorImage: json['author_image'],
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'],
      likes: json['likes'] as int?,
      shares: json['shares'] as int?,
      isFavorite: json['is_favorite'] as bool?,
      isLiked: json['is_liked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'author_image': authorImage,
      'category_id': categoryId,
      'category_name': categoryName,
      'likes': likes,
      'shares': shares,
      'is_favorite': isFavorite,
    };
  }

  factory QuoteModel.fromString(String jsonString) {
    // Parse format: "id|||text|||author" (using ||| as separator to avoid conflicts)
    final parts = jsonString.split('|||');
    if (parts.length >= 3) {
      return QuoteModel(
        id: parts[0],
        text: parts[1],
        author: parts[2],
      );
    } else if (parts.length == 2) {
      // Backward compatibility with old format
      return QuoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: parts[0],
        author: parts[1],
      );
    }
    return QuoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: '',
      author: 'Unknown',
    );
  }

  @override
  String toString() {
    return '$id|||$text|||$author';
  }
}
