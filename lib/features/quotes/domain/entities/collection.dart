import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int quoteCount;

  const Collection({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.createdAt,
    this.updatedAt,
    this.quoteCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        color,
        icon,
        createdAt,
        updatedAt,
        quoteCount,
      ];

  Collection copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? quoteCount,
  }) {
    return Collection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quoteCount: quoteCount ?? this.quoteCount,
    );
  }
}

