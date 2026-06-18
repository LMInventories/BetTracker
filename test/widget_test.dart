import 'package:flutter_test/flutter_test.dart';
import 'package:bettracker/app.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const BetTrackerApp());
    expect(find.byType(BetTrackerApp), findsOneWidget);
  });
}
