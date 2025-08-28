import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'constants/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BreachApp(),
    ),
  );
}

class BreachApp extends StatelessWidget {
  const BreachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breach',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
