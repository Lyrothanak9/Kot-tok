import 'package:flutter/material.dart';
import 'package:kot_tok/app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';

class SummaryStatsCard extends StatelessWidget {
  const SummaryStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          'Error: ${provider.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'Total Notes',
            count: provider.totalNotes.toString(),
            icon: Icons.note_alt_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'Categories',
            count: provider.totalCategories.toString(),
            icon: Icons.folder_outlined,
            color: Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}