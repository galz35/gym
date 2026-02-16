import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/main.dart';

void main() {
  testWidgets('GymApp renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GymApp());
    await tester.pumpAndSettle();

    // Verify app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
