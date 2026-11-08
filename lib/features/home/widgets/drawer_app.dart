import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';

class DrawerApp extends StatefulWidget {
  const DrawerApp({super.key});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  String _selectedItem = 'Notes';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.78).clamp(280.0, 320.0);

    // Connect to your new CategoryProvider
    final categoryProvider = context.watch<CategoryProvider>();

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Title Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Kot Tok',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF5F6368),
                ),
              ),
            ),

            // Scrollable Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Notes',
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_none,
                    title: 'Reminders',
                  ),

                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),

                  // Labels Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Labels',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202124),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to edit labels screen
                          },
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic Label Items from Supabase
                  if (categoryProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (categoryProvider.categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        'No labels yet',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                  else
                  // Map the Supabase categories to your UI items
                    ...categoryProvider.categories.map(
                          (category) => _buildDrawerItem(
                        icon: Icons.label_outline,
                        title: category.name, // Uses the name from CategoryModel
                      ),
                    ),

                  _buildDrawerItem(
                    icon: Icons.add,
                    title: 'Create new label',
                    isSelectable: false,
                    onTap: () {
                      // TODO: Handle creating a new label
                    },
                  ),

                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),

                  // Bottom System Items
                  _buildDrawerItem(
                    icon: Icons.archive_outlined,
                    title: 'Archive',
                  ),
                  _buildDrawerItem(
                    icon: Icons.delete_outline,
                    title: 'Trash',
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isSelectable: false,
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & feedback',
                    isSelectable: false,
                  ),
                ],
              ),
            ),

            // Pinned Footer
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Privacy Policy · Terms of Service',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF5F6368),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelectable = true,
    VoidCallback? onTap,
  }) {
    final bool isSelected = isSelectable && _selectedItem == title;
    const Color activeBackgroundColor = Color(0xFF4A34B8);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        contentPadding: const EdgeInsets.only(left: 24.0, right: 16.0),
        leading: Icon(
          icon,
          size: 22,
          color: isSelected ? Colors.white : const Color(0xFF5F6368),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF202124),
          ),
        ),
        selected: isSelected,
        selectedTileColor: activeBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(30),
          ),
        ),
        onTap: () {
          if (isSelectable) {
            setState(() {
              _selectedItem = title;
            });
          }
          if (onTap != null) onTap();

          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop();
          }
        },
      ),
    );
  }
}