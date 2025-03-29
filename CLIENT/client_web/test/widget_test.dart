import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client_web/main.dart'; // Ensure this matches your actual main file

void main() {
  testWidgets('Navigation test: Can switch between pages',
      (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MainApp());

    // Verify Home Page is shown initially
    expect(find.text('Home'), findsOneWidget);

    // Tap on "Job Postings" in the drawer
    await tester.tap(find.byIcon(Icons.menu)); // Open drawer
    await tester.pumpAndSettle(); // Wait for animations

    await tester.tap(find.text('Job Postings'));
    await tester.pumpAndSettle(); // Wait for new page to load

    // Verify Job Postings page is shown
    expect(find.text('Job Posting'), findsOneWidget);
  });

  testWidgets('Profile Page allows profile picture change',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    // Open drawer and navigate to Profile
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify Profile Page is shown
    expect(find.text('Profile'), findsOneWidget);

    // Find and tap the "Change Profile Picture" button
    final Finder changePicButton = find.text('Change Profile Picture');
    expect(changePicButton, findsOneWidget);
    await tester.tap(changePicButton);
    await tester.pump();

    // Normally, file selection is not testable in integration tests.
    // Here, we just confirm that the button is tappable.
  });
}
