import 'package:flutter_test/flutter_test.dart';
import 'package:spice_box/main.dart';

void main() {
  testWidgets('shows Spice Box', (tester) async {
    await tester.pumpWidget(const SpiceBoxApp());
    expect(find.text('Spice Box'), findsOneWidget);
  });
}
