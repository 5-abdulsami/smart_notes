import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const PrimaryButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        padding: EdgeInsets.symmetric(vertical: Responsive.spacing16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.radius12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: Responsive.fontSize16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
