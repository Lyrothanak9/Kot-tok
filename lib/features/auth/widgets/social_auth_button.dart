import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String? image;
  final String text;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    this.image,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: screenSize.height * 0.065,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () {},
          borderRadius: BorderRadius.circular(12), // Matches container for the ripple effect
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (image != null) ...[
                Image.network(
                  image!,
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.account_circle,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}