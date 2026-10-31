import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/app/app.dart';
import 'package:kot_tok/features/auth/screens/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://hdvwaehfgrclnpxdlkyy.supabase.co',
      anonKey: 'sb_publishable_w4Sf74zyDLcNh0ERUqdoeQ_JHINX269',
    );
  });

  testWidgets('App smoke test - builds App and renders SignInScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
  });
}
