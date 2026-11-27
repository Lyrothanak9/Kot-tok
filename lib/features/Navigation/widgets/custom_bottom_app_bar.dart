import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// A custom bottom application bar widget displaying quick-action icon buttons.
///
/// It dynamically positions its layout to accommodate the FAB location and restricts
/// its maximum width on tablet/desktop displays for better ergonomics.
class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({
    super.key,
    required this.fabLocation,
    this.shape,
    required this.onOpenEditor,
    this.onOpenChecklist,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final VoidCallback onOpenEditor;
  final VoidCallback? onOpenChecklist;

  /// Helper list to determine if the FAB is docked in the center of the bottom bar.
  static final List<FloatingActionButtonLocation> centerLocations =
      <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    // Check if the FAB is in the center so we can distribute the Spacers properly.
    final isCenter = centerLocations.contains(fabLocation);

    // Responsive constraints for larger screens.
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;

    return BottomAppBar(
      shape: shape,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // Restrict bottom bar action width on tablets for easier thumb reach.
            maxWidth: isTabletOrDesktop ? 720 : double.infinity,
          ),
          child: IconTheme(
            data: const IconThemeData(color: AppColors.textPrimaryColor),
            child: Row(
              children: <Widget>[
                // Checklist Action
                IconButton(
                  tooltip: 'Check Box',
                  icon: const Icon(Icons.check_box_outlined),
                  onPressed: onOpenChecklist ?? onOpenEditor,
                ),

                // If the FAB is in the center, add spacers to push buttons to the sides
                if (isCenter) const Spacer(),

                // Painting/Drawing Action
                IconButton(
                  tooltip: 'Painting',
                  icon: const Icon(Icons.brush_outlined),
                  onPressed: onOpenEditor,
                ),

                if (isCenter) const Spacer(),

                // Voice Note Action
                IconButton(
                  tooltip: 'Voice',
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: onOpenEditor,
                ),

                if (isCenter) const Spacer(),

                // Image/Photo Action
                IconButton(
                  tooltip: 'Add image',
                  icon: const Icon(Icons.image_outlined),
                  onPressed: onOpenEditor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
