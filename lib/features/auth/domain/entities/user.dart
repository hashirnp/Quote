import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;

  const User({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl];

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

