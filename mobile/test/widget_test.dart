import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:codequest/main.dart';
import 'package:codequest/services/mock_data.dart';

void main() {
  setUp(() {
    Get.reset();
    final mockData = MockDataService();
    mockData.enableDelay = false;
    Get.put<MockDataService>(mockData);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('App renders without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CodeQuestApp());

    // Verify that the app renders.
    expect(find.byType(CodeQuestApp), findsOneWidget);
    
    // Wait for splash screen navigation to complete
    await tester.pump(const Duration(seconds: 3));
  });
}
