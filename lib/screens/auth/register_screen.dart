 
import 'package:breach_app/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_strength_indicator.dart';
import '../../widgets/custom_button.dart';
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
  final _passwordFocusNode = FocusNode();
  bool _isPasswordFieldActive = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFieldActive = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

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
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
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
          focusNode: _passwordFocusNode,
        ),

        // Password Strength Indicator
        const SizedBox(height: 8),
        PasswordStrengthIndicator(
          passwordListenable: _passwordController,
          isActive: _isPasswordFieldActive,
        ),

        const SizedBox(height: 24),

        // Register Button
        CustomButton(
          text: 'Sign Up',
          onPressed: _register,
          isLoading: isLoading,
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
