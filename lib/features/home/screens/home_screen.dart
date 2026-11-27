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
    // MainNavigationScreen provides the Scaffold, AppBar, FAB, and BottomAppBar.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: SummaryStatsCard(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeProvider>().refresh();
            },
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PinnedNotesList(),
                  RecentNotesList(),
                  SizedBox(height: 80), // Keeps the bottom content from hiding behind the FAB
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}