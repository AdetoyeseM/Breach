import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Widget? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 56,
    this.width,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.padding,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 56.0;
    final buttonWidth = width ?? double.infinity;
    final buttonRadius = borderRadius ?? BorderRadius.circular(16);
    final buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);

    if (isOutlined) {
      return SizedBox(
        width: buttonWidth,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primary,
            side: BorderSide(
              color: foregroundColor ?? AppColors.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
            padding: buttonPadding,
          ),
          child: _buildButtonContent(),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: buttonPadding,
          elevation: 4,
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          TextView(
            text: text,
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: foregroundColor ?? Colors.white,
          ),
        ],
      );
    }

    return TextView(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: foregroundColor ?? Colors.white,
    );
  }
}
