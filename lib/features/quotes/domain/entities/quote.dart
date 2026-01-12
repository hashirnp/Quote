import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;
  final String author;

  const Quote({
    required this.text,
    required this.author,
  });

  @override
  List<Object> get props => [text, author];

  Quote copyWith({
    String? text,
    String? author,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
    );
  }
}

