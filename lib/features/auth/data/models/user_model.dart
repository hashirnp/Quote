import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
    super.fullName,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'],
      fullName: json['full_name'] ?? json['fullName'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }

  factory UserModel.fromSupabaseUser(dynamic supabaseUser) {
    return UserModel(
      id: supabaseUser.id ?? '',
      email: supabaseUser.email,
      fullName: supabaseUser.userMetadata?['full_name'],
      avatarUrl: supabaseUser.userMetadata?['avatar_url'],
    );
  }
}

