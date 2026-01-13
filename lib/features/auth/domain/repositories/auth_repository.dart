import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signUp({
    required String email,
    required String password,
    required String fullName,
  });
  
  Future<User> signIn({
    required String email,
    required String password,
  });
  
  Future<void> signOut();
  
  Future<void> resetPassword({required String email});
  
  Future<User?> getCurrentUser();
  
  Future<User> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });
  
  Stream<User?> get authStateChanges;
}

