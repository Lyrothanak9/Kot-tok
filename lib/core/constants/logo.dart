import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final shortest = screenSize.shortestSide;

    // Responsive size: keeps fixed aspect ratio and never overstretches on tablets/desktop
    final width = (shortest * 0.35).clamp(90.0, 140.0);
    final height = width * 0.85;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          "assets/images/logo/Logo_app.png",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.blueAccent,
            child: const Icon(
              Icons.edit_note,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
