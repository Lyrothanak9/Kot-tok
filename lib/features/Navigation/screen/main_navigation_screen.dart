import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../provider/bottom_app_bar_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/profile_screen.dart';
import '../widgets/app_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BottomAppBarProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;
    final currentIndex = provider.currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      appBar: CustomAppBar(
        isGridView: provider.isGridView,
        onLayoutTogglePressed: () => provider.toggleGridView(),
      ),
      // Display the screen based on the current index with responsive max width
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTabletOrDesktop ? 960 : double.infinity,
          ),
          child: _screens[currentIndex],
        ),
      ),
      floatingActionButton: provider.showFab
          ? FloatingActionButton(
              onPressed: () {},
              tooltip: 'Create',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: provider.fabLocation,
      bottomNavigationBar: _BottomAppBar(
        fabLocation: provider.fabLocation,
        shape: provider.showNotch ? const CircularNotchedRectangle() : null,
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar({
    required this.fabLocation,
    this.shape,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;

  static final List<FloatingActionButtonLocation> centerLocations =
      <FloatingActionButtonLocation>[
    FloatingActionButtonLocation.centerDocked,
    FloatingActionButtonLocation.centerFloat,
  ];

  @override
  Widget build(BuildContext context) {
    final isCenter = centerLocations.contains(fabLocation);
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;

    return BottomAppBar(
      shape: shape,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTabletOrDesktop ? 720 : double.infinity,
          ),
          child: IconTheme(
            data: IconThemeData(color: AppColors.textPrimaryColor,),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Check Box', //  button click create auto create Check box note
                  icon: Icon(Icons.check_box_outlined),
                  onPressed: () {}
                ),
                if (isCenter) const Spacer(),
                IconButton(
                  tooltip: 'painting',
                  icon: Icon(Icons.brush_outlined),
                  onPressed: () {},
                ),
                if (isCenter) const Spacer(),
                IconButton(
                  tooltip: 'voice ',
                  icon: Icon(Icons.mic_outlined),
                  onPressed: () {},
                ),
                if (isCenter) const Spacer(),
                IconButton(
                  tooltip: 'add image ',
                  icon: Icon(Icons.image_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
