import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fit_app/screens/SignUpScreen.dart';

void main() {
  testWidgets('SignUpScreen UI IntrinsicHeight test', (WidgetTester tester) async {
    final widget = const MaterialApp(home: SignUpScreen(role: 'Client'));
    
    // Pump the widget with a very small height constraint to force SingleChildScrollView to compress
    // and IntrinsicHeight to compute
    tester.view.physicalSize = const Size(400, 100); 
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(widget);
    
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
