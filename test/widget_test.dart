import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/app/app.dart';
import 'package:kot_tok/features/Navigation/provider/bottom_app_bar_provider.dart';
import 'package:kot_tok/features/Navigation/screen/main_navigation_screen.dart';
import 'package:kot_tok/features/Navigation/widgets/app_bar.dart';
import 'package:kot_tok/features/auth/screens/sign_in_screen.dart';
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
      ChangeNotifierProvider(
        create: (_) => BottomAppBarProvider(),
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    expect(find.byType(CustomAppBar), findsOneWidget);
    expect(find.text('Search your notes'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Home Screen'), findsOneWidget);

    // Initial state: single-column icon (Icons.view_agenda_outlined)
    expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsNothing);

    // Tap toggle button -> switches to grid view icon (Icons.grid_view_outlined)
    await tester.tap(find.byIcon(Icons.view_agenda_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.view_agenda_outlined), findsNothing);

    // Tap toggle button again -> switches back to single-column icon
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.view_agenda_outlined), findsOneWidget);
  });
}
