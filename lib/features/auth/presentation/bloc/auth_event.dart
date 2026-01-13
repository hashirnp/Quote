part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const SignUpEvent({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object> get props => [email, password, fullName];
}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignOutEvent extends AuthEvent {}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class UpdateProfileEvent extends AuthEvent {
  final String? fullName;
  final String? avatarUrl;

  const UpdateProfileEvent({
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object> get props => [
        if (fullName != null) fullName!,
        if (avatarUrl != null) avatarUrl!,
      ];
}

