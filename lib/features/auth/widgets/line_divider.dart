import 'package:flutter/material.dart';
import 'package:kot_tok/app/theme/app_colors.dart';
import 'package:kot_tok/app/theme/text_styles.dart';

class LineDivider extends StatelessWidget {
  final String text;

  const LineDivider({
    super.key,
    this.text = 'Or continue with',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
            endIndent: 12,
          ),
        ),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textHint,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
            indent: 12,
          ),
        ),
      ],
    );
  }
}
