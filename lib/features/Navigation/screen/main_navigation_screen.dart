import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../../home/widgets/drawer_app.dart';
import '../provider/bottom_app_bar_provider.dart';
import '../../home/models/note_model.dart';
import '../../home/providers/home_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/note_editor_screen.dart';
import '../widgets/app_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // GlobalKey lets us open the drawer from the AppBar without a child context.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _screens = [
    HomeScreen(),
  ];

  Future<void> _openNoteEditor({NoteModel? note}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note),
      ),
    );
    if (mounted) {
      context.read<HomeProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BottomAppBarProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;

    final currentIndex = provider.currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        isGridView: provider.isGridView,
        onLayoutTogglePressed: () => provider.toggleGridView(),
        // Use the GlobalKey to open the drawer from anywhere safely.
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const DrawerApp(),
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
              onPressed: () => _openNoteEditor(),
              tooltip: 'Create',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: provider.fabLocation,
      bottomNavigationBar: _BottomAppBar(
        fabLocation: provider.fabLocation,
        shape: provider.showNotch ? const CircularNotchedRectangle() : null,
        onOpenEditor: () => _openNoteEditor(),
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar({
    required this.fabLocation,
    this.shape,
    required this.onOpenEditor,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final VoidCallback onOpenEditor;

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
            data: const IconThemeData(color: AppColors.textPrimaryColor),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Check Box',
                  icon: const Icon(Icons.check_box_outlined),
                  onPressed: onOpenEditor,
                ),
                if (isCenter) const Spacer(),
                IconButton(
                  tooltip: 'Painting',
                  icon: const Icon(Icons.brush_outlined),
                  onPressed: onOpenEditor,
                ),
                if (isCenter) const Spacer(),
                IconButton(
                  tooltip: 'Voice',
                  icon: const Icon(Icons.mic_outlined),
                  onPressed: onOpenEditor,
                ),
                if (isCenter) const Spacer(),
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
