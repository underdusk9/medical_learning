import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medical_workbuddy/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MedicalWorkbuddyApp(),
      ),
    );

    // Verify app bar title exists
    expect(find.text('医学刷题助手'), findsOneWidget);
  });
}
