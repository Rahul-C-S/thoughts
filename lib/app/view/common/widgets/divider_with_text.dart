import 'package:flutter/material.dart';
import 'package:thoughts/app/config/theme/app_colors.dart';


class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider,
          ),
        ),
      ],
    );
  }
}