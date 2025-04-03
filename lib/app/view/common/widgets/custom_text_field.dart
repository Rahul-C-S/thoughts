import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? 1 : minLines,
          expands: expands,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, color: Colors.grey)
                    : null,
            counterText: maxLength != null ? '' : null,
          ),
        ),
      ],
    );
  }
}
