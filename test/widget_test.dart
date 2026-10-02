import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/screens/home_screen.dart';

void main() {
  testWidgets('calendar home screen shows app bar title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    expect(find.text('Log!'), findsOneWidget);
  });
}
