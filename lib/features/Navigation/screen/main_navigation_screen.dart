import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/widgets/drawer_app.dart';
import '../provider/bottom_app_bar_provider.dart';
import '../../home/models/note_model.dart';
import '../../home/providers/home_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../home/screens/note_editor_screen.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/custom_bottom_app_bar.dart';

/// The root navigation structure of the application after authentication.
///
/// [MainNavigationScreen] provides the primary Scaffold containing the custom
/// AppBar, navigation drawer, floating action button, and custom BottomAppBar.
/// It switches between different top-level screens (currently just [HomeScreen]).
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  /// GlobalKey used to access the Scaffold state.
  /// This allows us to open the navigation drawer programmatically from anywhere,
  /// such as inside the custom AppBar, without needing a direct descendant context.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// The list of top-level screens available via the bottom navigation.
  static const List<Widget> _screens = [
    HomeScreen(),
  ];

  /// Opens the [NoteEditorScreen] for creating or editing a note.
  ///
  /// Optionally accepts an existing [NoteModel] to edit, or a boolean [isChecklist]
  /// flag to launch directly into a checklist creation mode.
  Future<void> _openNoteEditor({NoteModel? note, bool isChecklist = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(note: note, isChecklist: isChecklist),
      ),
    );

    // Once the editor is closed (user pops back), refresh the notes list
    // if the widget is still in the view tree.
    if (mounted) {
      context.read<HomeProvider>().refresh();
    }
  }

  /// Builds the main content area with responsive constraints.
  Widget _buildBody(BuildContext context, int currentIndex) {
    final screenSize = MediaQuery.of(context).size;
    final isTabletOrDesktop = screenSize.width >= 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTabletOrDesktop ? 960 : double.infinity,
        ),
        child: _screens[currentIndex],
      ),
    );
  }

  /// Conditionally builds the Floating Action Button.
  Widget? _buildFab(BottomAppBarProvider provider) {
    if (!provider.showFab) return null;

    return FloatingActionButton(
      onPressed: () => _openNoteEditor(),
      tooltip: 'Create',
      child: const Icon(Icons.add),
    );
  }

  String _resolveProfileInitial() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return 'A';
    final metadata = user.userMetadata ?? {};
    final displayName = (metadata['full_name'] ??
            metadata['name'] ??
            user.email ??
            'A')
        .toString()
        .trim();
    if (displayName.isEmpty) return 'A';
    return displayName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the BottomAppBarProvider for layout preferences (FAB location, Grid view).
    final provider = context.watch<BottomAppBarProvider>();

    // Ensure the current index doesn't go out of bounds of the available _screens.
    final currentIndex = provider.currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      key: _scaffoldKey,

      // Top Application Bar (Custom implementation)
      appBar: SearchAppBar(
        isGridView: provider.isGridView,
        profileInitial: _resolveProfileInitial(),
        onLayoutTogglePressed: () => provider.toggleGridView(),
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onSearchChanged: (query) =>
            context.read<HomeProvider>().setSearchQuery(query),
      ),

      // Side Navigation Drawer
      drawer: const DrawerApp(),

      // Main Body: Display the currently selected screen based on the index.
      body: _buildBody(context, currentIndex),

      // Floating Action Button (FAB) setup
      floatingActionButton: _buildFab(provider),
      floatingActionButtonLocation: provider.fabLocation,

      // Custom Bottom App Bar
      bottomNavigationBar: CustomBottomAppBar(
        fabLocation: provider.fabLocation,
        shape: provider.showNotch ? const CircularNotchedRectangle() : null,
        onOpenEditor: () => _openNoteEditor(),
        onOpenChecklist: () => _openNoteEditor(isChecklist: true),
      ),
    );
  }
}
