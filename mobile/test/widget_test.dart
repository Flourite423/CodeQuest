import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_app_mobile/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LearningApp());

    // Verify that the app renders.
    expect(find.byType(LearningApp), findsOneWidget);
  });
}
