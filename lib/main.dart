import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/quotes/presentation/bloc/quotes_bloc.dart';
import 'features/quotes/presentation/pages/splash_page.dart';
import 'features/quotes/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuotesBloc>(
          create: (_) => getIt<QuotesBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Quote App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/home': (context) => const MainPage(),
        },
      ),
    );
  }
}
