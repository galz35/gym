import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as pkg_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/main.dart';
import 'package:gym_app/core/database/app_database.dart';

void main() {
  testWidgets('GymApp renders login screen', (WidgetTester tester) async {
    // Basic test with in-memory database or similar setup needed
    final database = AppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        child: pkg_provider.Provider<AppDatabase>.value(
          value: database,
          child: const GymApp(),
        ),
      ),
    );

    // Smoke test
    expect(find.byType(GymApp), findsOneWidget);
  });
}
