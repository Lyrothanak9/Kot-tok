import 'package:flutter/material.dart';

/// Reusable responsive profile avatar graphics for authentication screens.
class ProfileAvatar extends StatelessWidget {
  final double? size;

  const ProfileAvatar({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final avatarSize = size ?? screenSize.width * 0.26;
    final scale = avatarSize / 106.0;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2610FF),
        border: Border.all(
          color: const Color(0xFF1B00E8),
          width: 4 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3214FF).withValues(alpha: 0.30),
            blurRadius: 24 * scale,
            spreadRadius: 5 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Head
            Positioned(
              top: 18 * scale,
              child: CircleAvatar(
                radius: 16 * scale,
                backgroundColor: Colors.white,
              ),
            ),

            // Body
            Positioned(
              bottom: -9 * scale,
              child: Container(
                width: 66 * scale,
                height: 43 * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40 * scale),
                  ),
                ),
              ),
            ),

            // Purple translucent accent circle
            Positioned(
              right: -5 * scale,
              bottom: -2 * scale,
              child: Container(
                width: 45 * scale,
                height: 45 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF8170FF).withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile header card containing avatar and title label.
class ImageProfileAuth extends StatelessWidget {
  final double? avatarSize;
  final String title;

  const ImageProfileAuth({
    super.key,
    this.avatarSize, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileAvatar(size: avatarSize),
        SizedBox(height: screenSize.height * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: screenSize.width * 0.08,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF211D2B),
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}
