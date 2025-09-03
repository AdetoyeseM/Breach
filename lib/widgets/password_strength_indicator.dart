import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'custom_text.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final ValueListenable<TextEditingValue> passwordListenable;
  final double height;
  final bool isActive;

  const PasswordStrengthIndicator({
    super.key,
    required this.passwordListenable,
    this.height = 4.0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: passwordListenable,
      builder: (context, value, child) {
        final strength = _calculateStrength(value.text);

        if (value.text.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: strength.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: strength.color,
                          borderRadius: BorderRadius.circular(height / 2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                            TextView(
              text: strength.label,
              fontSize: 12,
              color: strength.color,
              fontWeight: FontWeight.w500,
            ),
              ],
            ),
            const SizedBox(height: 4),
                    TextView(
          text: strength.description,
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
          ],
        );
      },
    );
  }

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) {
      return PasswordStrength(
        value: 0.0,
        color: Colors.grey,
        label: '',
        description: '',
      );
    }

    int score = 0;
    List<String> feedback = [];

    // Length check
    if (password.length >= 8) {
      score += 1;
    } else {
      feedback.add('At least 8 characters');
    }

    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    } else {
      feedback.add('Include uppercase letter');
    }

    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    } else {
      feedback.add('Include lowercase letter');
    }

    // Number check
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    } else {
      feedback.add('Include number');
    }

    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    } else {
      feedback.add('Include special character');
    }

    // Determine strength level
    switch (score) {
      case 0:
      case 1:
        return PasswordStrength(
          value: 0.2,
          color: Colors.red,
          label: 'Very Weak',
          description: feedback.join(', '),
        );
      case 2:
        return PasswordStrength(
          value: 0.4,
          color: Colors.orange,
          label: 'Weak',
          description: feedback.join(', '),
        );
      case 3:
        return PasswordStrength(
          value: 0.6,
          color: Colors.yellow.shade700,
          label: 'Fair',
          description: feedback.join(', '),
        );
      case 4:
        return PasswordStrength(
          value: 0.8,
          color: Colors.lightGreen,
          label: 'Good',
          description: feedback.join(', '),
        );
      case 5:
        return PasswordStrength(
          value: 1.0,
          color: Colors.green,
          label: 'Strong',
          description: 'Excellent password strength!',
        );
      default:
        return PasswordStrength(
          value: 0.0,
          color: Colors.grey,
          label: '',
          description: '',
        );
    }
  }
}

class PasswordStrength {
  final double value;
  final Color color;
  final String label;
  final String description;

  PasswordStrength({
    required this.value,
    required this.color,
    required this.label,
    required this.description,
  });
}
