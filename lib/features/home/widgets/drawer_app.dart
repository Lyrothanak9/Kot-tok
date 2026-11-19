import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/home_provider.dart';
import 'dialog/create_label_dialog.dart';
import 'dialog/manage_labels_dialog.dart';

class DrawerApp extends StatefulWidget {
  const DrawerApp({super.key});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  // Tracks system items like 'Archive' or 'Trash' when not filtering by category
  String? _selectedSystemItem;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.78).clamp(280.0, 320.0);

    // Watch both providers so selection and categories update reactively
    final homeProvider = context.watch<HomeProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    // "Notes" is selected when no category is active and no system item is selected
    final isNotesSelected = _selectedSystemItem == null && homeProvider.activeCategoryId == null;

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
                  // 1. Default Notes Item
                  _buildDrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Notes',
                    isSelected: isNotesSelected,
                    onTap: () {
                      setState(() => _selectedSystemItem = null);
                      homeProvider.filterByCategory(null, 'Notes');
                    },
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
                            ManageLabelsDialog.show(
                              context,
                              categoryProvider: categoryProvider,
                              onCategoryDeleted: (deletedId) {
                                if (homeProvider.activeCategoryId == deletedId) {
                                  homeProvider.filterByCategory(null, 'Notes');
                                }
                              },
                            );
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
                  // Map categories: active highlight automatically follows activeCategoryId
                    ...categoryProvider.categories.map((category) {
                      final isSelected = homeProvider.activeCategoryId == category.id;
                      return _buildDrawerItem(
                        icon: Icons.label_outline,
                        title: category.name,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedSystemItem = null);
                          homeProvider.filterByCategory(category.id, category.name);
                        },
                      );
                    }),

                  // Create New Label Button
                  _buildDrawerItem(
                    icon: Icons.add,
                    title: 'Create new label',
                    isSelected: false,
                    closeDrawerOnTap: false,
                    onTap: () {
                      CreateLabelDialog.show(
                        context,
                        categoryProvider: categoryProvider,
                        onCategoryCreated: (newCategory) {
                          setState(() => _selectedSystemItem = null);
                          homeProvider.filterByCategory(newCategory.id, newCategory.name);
                        },
                      );
                    },
                  ),

                  const Divider(height: 24, thickness: 1, color: Color(0xFFE0E0E0)),

                  // Bottom System Items
                  _buildDrawerItem(
                    icon: Icons.archive_outlined,
                    title: 'Archive',
                    isSelected: _selectedSystemItem == 'Archive',
                    onTap: () {
                      setState(() => _selectedSystemItem = 'Archive');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.delete_outline,
                    title: 'Trash',
                    isSelected: _selectedSystemItem == 'Trash',
                    onTap: () {
                      setState(() => _selectedSystemItem = 'Trash');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    isSelected: false,
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & feedback',
                    isSelected: false,
                    onTap: () {
                      // TODO: Navigate to help
                    },
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
    required bool isSelected,
    bool closeDrawerOnTap = true,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.only(right: 12.0),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1),
        contentPadding: const EdgeInsets.only(left: 24.0, right: 16.0),

        // Tap & Selection Colors follow your button primary color
        selected: isSelected,
        selectedTileColor: AppColors.primary,
        splashColor: AppColors.primary.withValues(alpha: 0.15),
        hoverColor: AppColors.primary.withValues(alpha: 0.08),

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
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
        onTap: () {
          if (closeDrawerOnTap) {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            }
          }
          if (onTap != null) onTap();
        },
      ),
    );
  }
}