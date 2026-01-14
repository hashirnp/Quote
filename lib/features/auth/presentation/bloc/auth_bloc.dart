import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/update_profile.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUp signUp;
  final SignIn signIn;
  final SignOut signOut;
  final ResetPassword resetPassword;
  final GetCurrentUser getCurrentUser;
  final UpdateProfile updateProfile;

  AuthBloc({
    required this.signUp,
    required this.signIn,
    required this.signOut,
    required this.resetPassword,
    required this.getCurrentUser,
    required this.updateProfile,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );

      // Check if there's an active session after sign up
      // If email confirmation is disabled, session will be created immediately
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        // User has active session, emit authenticated
        emit(Authenticated(user: currentUser));
      } else {
        // No session - email confirmation might be required
        // Still emit authenticated so navigation can happen
        // The AuthGuard will check session on rebuild
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await signIn(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await resetPassword(email: event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      // Save current state before emitting loading
      final currentState = state as Authenticated;
      emit(AuthLoading());
      try {
        final updatedUser = await updateProfile(
          userId: currentState.user.id,
          fullName: event.fullName,
          avatarUrl: event.avatarUrl,
        );
        emit(Authenticated(user: updatedUser));
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    }
  }
}
