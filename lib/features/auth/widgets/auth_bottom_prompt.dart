import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthBottomPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onTap;

  const AuthBottomPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(fontSize: 14);

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: promptText,
          style: bodyStyle.copyWith(color: Colors.grey.shade600),
          children: [
            TextSpan(
              text: actionText,
              style: bodyStyle.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
