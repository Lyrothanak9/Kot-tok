import 'package:flutter/material.dart';

/// A reusable, responsive application logo widget.
///
/// The [Logo] adjusts its size dynamically based on the current screen height,
/// ensuring it maintains appropriate proportions across devices.
class Logo extends StatelessWidget {
  final double? height;
  final double? width;

  /// Creates a [Logo] widget.
  const Logo({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch the current screen size to make the logo responsive.
    final screenSize = MediaQuery.sizeOf(context);

    // Compact responsive size matching the trimmed square logo asset.
    final resolvedHeight =
        height ?? (screenSize.height * 0.11).clamp(72.0, 96.0);
    final resolvedWidth = width ?? resolvedHeight;

    return SizedBox(
      width: resolvedWidth,
      height: resolvedHeight,
      child: Image.asset(
        // Path to the application's logo image in the assets directory.
        "assets/images/logo/Logo_app.png",

        // Use BoxFit.contain to ensure the entire logo is always visible
        // within the box without getting cropped, regardless of the container's proportions.
        fit: BoxFit.contain,

        // A fallback builder that displays an icon if the image fails to load
        // (e.g., if the asset path is incorrect or missing).
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.edit_note,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
