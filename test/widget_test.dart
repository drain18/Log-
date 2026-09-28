import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/main.dart';

void main() {
  testWidgets('calendar home screen shows calendar and entry input', (tester) async {
    await tester.pumpWidget(const LogApp());

    expect(find.text('Journal Calendar'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
      