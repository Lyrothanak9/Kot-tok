import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../widgets/summary_stats_card.dart';
import '../widgets/pinned_notes_list.dart';
import '../widgets/recent_notes_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We remove the Scaffold, AppBar, FAB, and BottomAppBar from here
    // because MainNavigationScreen is now handling them.
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeProvider>().refresh();
      },
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryStatsCard(),
            SizedBox(height: 24),
            PinnedNotesList(),
            SizedBox(height: 24),
            RecentNotesList(),
            SizedBox(height: 80), // Keeps the bottom content from hiding behind the FAB
          ],
        ),
      ),
    );
  }
}