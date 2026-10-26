import 'package:flutter/material.dart';

class LineDivider extends StatelessWidget {
  const LineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 2,
            endIndent: 12,
          ),
        ),
        Text(
          'Or continue with',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 2,
            indent: 12,
          ),
        ),
      ],
    );
  }
}