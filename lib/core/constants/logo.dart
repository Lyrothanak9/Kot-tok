import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double? width;
  final double? height;

  const Logo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    final containerWidth = width ?? screenSize.width * 0.4;
    final containerHeight = height ?? screenSize.height * 0.15;

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          "assets/images/logo/Logo_app.png",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.blueAccent,
            child: const Icon(
              Icons.edit_note,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
