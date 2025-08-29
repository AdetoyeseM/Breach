import 'dart:convert';
import 'package:breach_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user.dart';
import '../onboarding/welcome_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Navigator.of(context)

    await ref
        .read(authProvider.notifier)
        .register(_emailController.text.trim(), _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); 
    ref.listen<AsyncValue<UserDTO?>>(authProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && previous?.value == null) { 
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            ),
          );
         
        }
      });

      next.whenOrNull(
        error: (error, stackTrace) {
          // Show error SnackBar only when error state changes
          if (previous?.hasError != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: authState.when(
              data: (user) {
                // If user is registered, show success state

                // Show registration form if user is null
                return _buildRegisterForm(authState.isLoading);
              },
              loading: () => _buildRegisterForm(true),
              error:
                  (error, stackTrace) =>
                      _buildRegisterForm(false, errorMessage: error.toString()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(bool isLoading, {String? errorMessage}) {
    return ListView(
      children: [
        // Title
        const Text(
          'Create Account',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const Text(
          'Join Breach to stay informed',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Show error message if available
        if (errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Email Field
        CustomTextField(
          hintText: "johndoe@gmail.com",
          validator: Validators.email,
          labelText: "Email",
          controller: _emailController,
        ),

        CustomTextField(
          isPasswordField: true,
          validator: Validators.password,
          labelText: 'Password',
          hintText: 'Password',
          controller: _passwordController,
        ),
        CustomTextField(
          controller: _confirmPasswordController,
          obscureText: true,
          isPasswordField: true,
          labelText: 'Confirm Password',
          hintText: 'Confirm your password',
          validator: (p0) {
            return Validators.confirmPassword(_passwordController.text, p0);
          },
        ),

        const SizedBox(height: 24),

        // Register Button
        ElevatedButton(
          onPressed: isLoading ? null : _register,
          child:
              isLoading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Sign Up'),
        ),

        const SizedBox(height: 16),

        // Login Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ],
    );
  }
}
