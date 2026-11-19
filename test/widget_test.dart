import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/app/app.dart';
import 'package:kot_tok/features/Navigation/provider/bottom_app_bar_provider.dart';
import 'package:kot_tok/features/Navigation/screen/main_navigation_screen.dart';
import 'package:kot_tok/features/Navigation/widgets/app_bar.dart';
import 'package:kot_tok/features/auth/screens/sign_in_screen.dart';
import 'package:kot_tok/features/home/providers/category_provider.dart';
import 'package:kot_tok/features/home/providers/home_provider.dart';
import 'package:kot_tok/features/home/screens/home_screen.dart';
import 'package:kot_tok/features/home/screens/note_editor_screen.dart';
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

  testWidgets('MainNavigationScreen smoke test - renders CustomAppBar and toggles grid/single column icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomAppBarProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    expect(find.byType(CustomAppBar), findsOneWidget);
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
}
