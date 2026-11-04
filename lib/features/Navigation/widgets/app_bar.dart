import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onMenuPressed,
    this.onLayoutTogglePressed,
    this.onProfilePressed,
    this.onSearchTap,
    this.onSearchChanged,
    this.searchController,
    this.hintText = 'Search your notes',
    this.profileInitial = 'A',
    this.isGridView = false,
  });

  final VoidCallback? onMenuPressed;
  final VoidCallback? onLayoutTogglePressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final String hintText;
  final String profileInitial;
  final bool isGridView;

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.width < 360;
    final isTabletOrDesktop = screenSize.width >= 600;

    // Responsive horizontal padding based on screen width
    final horizontalPadding = isTabletOrDesktop
        ? 24.0
        : (screenSize.width * 0.04).clamp(12.0, 16.0);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 8.0,
            ),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                // Soft light-gray background matching Google Keep / the UI reference
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(26.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Color(0xFF5F6368),
                      size: 24,
                    ),
                    tooltip: 'Open navigation drawer',
                    splashRadius: 20,
                    onPressed: onMenuPressed ?? () {},
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onTap: onSearchTap,
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 16,
                      ),
                      cursorColor: const Color(0xFF202124),
                      decoration: InputDecoration(
                        hintText: isCompact ? 'Search' : hintText,
                        hintStyle: TextStyle(
                          color: const Color(0xFF5F6368),
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isGridView ? Icons.grid_view_outlined : Icons.view_agenda_outlined,
                      color: const Color(0xFF5F6368),
                      size: 24,
                    ),
                    tooltip: isGridView ? 'Grid view' : 'Single-column view',
                    splashRadius: 20,
                    onPressed: onLayoutTogglePressed ?? () {},
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7B1FA2), // Vibrant purple from the UI reference
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profileInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
