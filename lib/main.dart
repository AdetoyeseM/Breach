import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'constants/theme.dart';
import 'providers/websocket_init_provider.dart';

void main() {
  // Configure system UI overlay style to show status bar icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ProviderScope(child: BreachApp()));
}

class BreachApp extends ConsumerStatefulWidget {
  const BreachApp({super.key});

  @override
  ConsumerState<BreachApp> createState() => _BreachAppState();
}

class _BreachAppState extends ConsumerState<BreachApp> {
  @override
  void initState() {
    super.initState();
    // Initialize WebSocket connection after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(webSocketInitProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    ref.read(webSocketInitProvider.notifier).cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Breach',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
