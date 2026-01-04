import 'package:flutter_test/flutter_test.dart';
import 'package:mediscribe_app/main.dart';

void main() {
  testWidgets('Mediscribe app loads', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MediscribeApp());

    // Verify app title exists
    expect(find.text('Mediscribe'), findsWidgets);
  });
}
