import '../../domain/entities/quote.dart';

class QuoteModel extends Quote {
  const QuoteModel({
    required super.text,
    required super.author,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      text: json['q'] ?? '',
      author: json['a'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': text,
      'a': author,
    };
  }

  factory QuoteModel.fromString(String jsonString) {
    // Parse format: "text|||author" (using ||| as separator to avoid conflicts)
    final parts = jsonString.split('|||');
    if (parts.length == 2) {
      return QuoteModel(text: parts[0], author: parts[1]);
    }
    return const QuoteModel(text: '', author: 'Unknown');
  }

  @override
  String toString() {
    return '$text|||$author';
  }
}

