import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }
}
