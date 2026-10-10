import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/main.dart';

void main() {
  testWidgets('App smoke test - verifies Expense Tracker loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pump();

    // Verify title is rendered
    expect(find.text('OCR Expense Tracker'), findsOneWidget);
  });
}
