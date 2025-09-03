import 'package:breach_app/constants/assets.dart';
import 'package:breach_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../widgets/custom_button.dart';
import 'interest_selection_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Icon
              Image.asset(
                Assets.mascotCircular,
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.celebration,
                    size: 60,
                    color: AppColors.primary,
                  );
                },
              ),

              const SizedBox(height: 32),

              // Welcome Title
              const Text(
                'Welcome to Breach 🥳',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Welcome Subtitle
              const Text(
                'Just a few quick questions to help personalise your Breach experience. Are you ready?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Get Started Button
              CustomButton(
                text: 'Let\'s begin',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const InterestSelectionScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                height: 56,
              ),

              // Skip Button
              TextButton(
                onPressed: () { 
              Navigator.of(context).pushAndRemoveUntil(
                 MaterialPageRoute(
                   builder: (_) => const HomeScreen(),
                 ),
                 (route) => false, 
               );
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
