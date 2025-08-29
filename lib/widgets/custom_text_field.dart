import 'package:breach_app/utils/validators.dart';
import 'package:breach_app/widgets/custom_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
   final bool isPasswordField;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.controller,
    this.keyboardType,
    this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.initialValue,
    this.isPasswordField = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
   bool isTextObscured = true;
   
   @override
   void initState() {
     super.initState();
     // Initialize obscure text state based on whether it's a password field
     isTextObscured = widget.isPasswordField;
   }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom:16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText?.isNotEmpty ?? false)
            TextView(
              text: widget.labelText!,
              fontSize: 12.21,
              fontWeight: FontWeight.w500,
              color: AppColors.textFieldLabel,
            ),
          if (widget.labelText?.isNotEmpty ?? false) const SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPasswordField ? isTextObscured : widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          onTap: widget.onTap,
        
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          initialValue: widget.initialValue,
          validator: widget.validator,
          decoration: InputDecoration(
          suffixIcon: widget.isPasswordField
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isTextObscured = !isTextObscured; 
                      });
                    },
                    child: Icon(
                      isTextObscured
                          ? CupertinoIcons.eye_slash
                          : Icons.remove_red_eye_outlined,
                      size: 24.0,
                    ),
                  ),
                )
              : SizedBox(),
          hintText: widget.hintText,
          hintStyle: TextStyle(
              color: AppColors.textFieldHint,
              fontWeight: FontWeight.w400,
              fontSize: 14.25),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        
        )),
      ],
      )
    );
  }
}
 