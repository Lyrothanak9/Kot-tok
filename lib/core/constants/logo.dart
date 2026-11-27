import 'package:flutter/material.dart';

/// A reusable, responsive application logo widget.
///
/// The [Logo] adjusts its size dynamically based on the current screen height,
/// ensuring it maintains appropriate proportions across devices.
class Logo extends StatelessWidget {
  /// Creates a [Logo] widget.
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch the current screen size to make the logo responsive.
    final screenSize = MediaQuery.sizeOf(context);

    // Calculates a responsive height for the logo container.
    // 25% of the total screen height.
    final height = screenSize.height * 0.25;

    // Calculates a responsive width.
    // Uses 40% of the total screen height to maintain a stable aspect ratio
    // relative to its height, preventing stretching on wide screens.
    final width = screenSize.height * 0.4;

    return SizedBox(
      width: width,
      height: height,
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
