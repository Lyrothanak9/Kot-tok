import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/app/app.dart';
import 'package:kot_tok/features/Navigation/provider/bottom_app_bar_provider.dart';
import 'package:kot_tok/features/Navigation/screen/main_navigation_screen.dart';
import 'package:kot_tok/features/Navigation/widgets/search_app_bar.dart';
import 'package:kot_tok/features/auth/screens/sign_in_screen.dart';
import 'package:kot_tok/features/home/models/note_model.dart';
import 'package:kot_tok/features/home/providers/category_provider.dart';
import 'package:kot_tok/features/home/providers/home_provider.dart';
import 'package:kot_tok/features/home/providers/note_editor_provider.dart';
import 'package:kot_tok/features/home/screens/home_screen.dart';
import 'package:kot_tok/features/home/screens/note_editor_screen.dart';
import 'package:kot_tok/features/home/widgets/summary_stats_card.dart';
import 'package:kot_tok/features/splash/screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://hdvwaehfgrclnpxdlkyy.supabase.co',
      publishableKey: 'sb_publishable_w4Sf74zyDLcNh0ERUqdoeQ_JHINX269',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.instance.client.auth.signOut();
  });

  testWidgets('App smoke test - starts on SplashScreen and navigates to SignInScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance timer past splash delay
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('MainNavigationScreen smoke test - renders SearchAppBar and toggles grid/single column icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    expect(find.byType(SearchAppBar), findsOneWidget);
    expect(find.text('Search your notes'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);

    // Initial state: single-column icon (Icons.grid_view_outlined shown to switch to grid)
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.view_agenda_outlined), findsNothing);

    // Tap toggle button -> switches to grid view (shows Icons.view_agenda_outlined to switch back)
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsNothing);

    // Tap toggle button again -> switches back to single-column view
    await tester.tap(find.byIcon(Icons.view_agenda_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
  });

  testWidgets('MainNavigationScreen - tapping Create FAB opens NoteEditorScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditorScreen), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
  });

  testWidgets('MainNavigationScreen - tapping Check Box opens NoteEditorScreen in checklist mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    final checkBoxButton = find.byTooltip('Check Box');
    expect(checkBoxButton, findsOneWidget);
    await tester.tap(checkBoxButton);
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditorScreen), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('List item'), findsWidgets);

    // Test adding another checkbox via tapping "+ List item"
    await tester.tap(find.text('List item').last);
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('NoteEditorScreen - pasting multiline text creates multiple checkbox items', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: const MaterialApp(
          home: NoteEditorScreen(isChecklist: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsOneWidget);

    // Enter multiline text into the first checklist TextField
    final firstItemFinder = find.byType(TextField).last; // first TextField is Title, second is list item
    await tester.enterText(firstItemFinder, 'Apples\nBananas\nOranges');
    await tester.pumpAndSettle();

    // Now there should be 3 checkboxes
    expect(find.byType(Checkbox), findsNWidgets(3));
    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Bananas'), findsOneWidget);
    expect(find.text('Oranges'), findsOneWidget);
  });

  test('NoteEditorProvider.reorderUncheckedItem matches onReorderItem adjusted indices', () {
    final provider = NoteEditorProvider();
    addTearDown(provider.dispose);

    provider.init(
      NoteModel(
        id: 'n1',
        userId: 'u1',
        title: 'List',
        content: '☐ First\n☐ Second\n☐ Third',
        isPinned: false,
        isFavorite: false,
        createdAt: DateTime(2026),
      ),
    );

    // Move index 0 ('First') to adjusted index 2 (after 'Third')
    provider.reorderUncheckedItem(0, 2);
    expect(
      provider.uncheckedItems.map((e) => e.controller.text).toList(),
      ['Second', 'Third', 'First'],
    );

    // Move index 2 ('First') back to index 0
    provider.reorderUncheckedItem(2, 0);
    expect(
      provider.uncheckedItems.map((e) => e.controller.text).toList(),
      ['First', 'Second', 'Third'],
    );
  });

  test('HomeProvider.setSearchQuery updates searchQuery without errors when signed out', () {
    final provider = HomeProvider();
    addTearDown(provider.dispose);

    expect(provider.searchQuery, '');
    provider.setSearchQuery('groceries');
    expect(provider.searchQuery, 'groceries');
    expect(provider.pinnedNotes, isEmpty);
    expect(provider.recentNotes, isEmpty);
  });

  testWidgets('HomeScreen keeps SummaryStatsCard fixed at the top when scrolling notes area', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardFinder = find.byType(SummaryStatsCard);
    expect(cardFinder, findsOneWidget);
    final initialTopLeft = tester.getTopLeft(cardFinder);

    // Drag the notes scroll area downward and upward
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -150));
    await tester.pump();
    expect(tester.getTopLeft(cardFinder), initialTopLeft);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 150));
    await tester.pump();
    expect(tester.getTopLeft(cardFinder), initialTopLeft);
  });
}
