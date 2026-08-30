import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_cast/main.dart';

void main() {
  testWidgets('App smoke test - verifies app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LightCastApp());

    // Verify that the Director Dashboard title is displayed.
    expect(find.text('LightCast Director'), findsOneWidget);
    
    // Verify that the GO LIVE button is displayed.
    expect(find.text('GO LIVE'), findsOneWidget);
  });
}
