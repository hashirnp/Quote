import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });

  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      log('SignUp response: ${response.toString()}');
      log('Session: ${response.session}');
      log('User: ${response.user}');

      if (response.user == null) {
        throw const ServerFailure('Failed to create user');
      }

      // If session is null, email confirmation might be required
      // But we still return the user so they can be shown a confirmation message
      // The session will be created after email confirmation
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      log('SignUp error: $e');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerFailure('Failed to sign in');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      // Only return user if there's an active session
      // This ensures user is actually authenticated
      if (user != null && session != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) {
        updates['full_name'] = fullName;
      }
      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );

      final updatedUser = _supabase.auth.currentUser;
      if (updatedUser == null) {
        throw const ServerFailure('User not found');
      }

      return UserModel.fromSupabaseUser(updatedUser);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );
}
