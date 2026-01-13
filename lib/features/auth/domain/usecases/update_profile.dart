import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<User> call({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    return await repository.updateProfile(
      userId: userId,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );
  }
}

