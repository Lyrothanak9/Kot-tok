import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String? image;
  final VoidCallback? onPressed;
  final double? size;

  const SocialAuthButton({
    super.key,
    this.image,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    final buttonSize = size ?? (screenSize.width * 0.15);
    final padding = buttonSize * 0.25;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8D2FA).withValues(alpha: 0.6),
            blurRadius: buttonSize * 0.3,
            spreadRadius: 2,
            offset: Offset(0, buttonSize * 0.12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () {},
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: image != null
                ? Image.network(
                    image!,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
