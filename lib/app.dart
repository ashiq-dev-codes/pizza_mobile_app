import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/page/splash_page.dart';
import 'package:pizza_mobile_app/shared/theme/main_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // Wrap in MultiBlocProvider (flutter_bloc) if you use Bloc/Cubit
    return MaterialApp(
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      theme: MainTheme.mainThemeData(false),
      home: const SplashScreen(),
    );
  }
}
