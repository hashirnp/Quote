import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/quotes/presentation/pages/main_page.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      debugPrint('Auth state changed - Session: ${session != null}');
      if (session != null) {
        // User is authenticated, check auth status
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      } else {
        // User is not authenticated
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      }
    });
    
    // Check if app was opened from widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWidgetIntent();
    });
  }
  
  void _checkWidgetIntent() {
    // This will be handled by MainActivity in native code
    // For now, we'll check in MainPage
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainPage();
        } else if (state is Unauthenticated) {
          return const LoginPage();
        } else if (state is AuthError) {
          // Show login page even on error, with error message
          return const LoginPage();
        } else {
          // Loading state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
