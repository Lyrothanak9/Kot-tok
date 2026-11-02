import 'package:flutter_test/flutter_test.dart';
import 'package:kot_tok/app/app.dart';
import 'package:kot_tok/features/splash/screen/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://hdvwaehfgrclnpxdlkyy.supabase.co',
      publishableKey: 'sb_publishable_w4Sf74zyDLcNh0ERUqdoeQ_JHINX269',
    );
  });

  testWidgets('App smoke test - builds App and renders SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
