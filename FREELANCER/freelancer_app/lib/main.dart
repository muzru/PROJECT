import 'package:flutter/material.dart';
import 'package:freelancer_app/login.dart';
import 'package:freelancer_app/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lxoefvgukuhmfenizheb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b2Vmdmd1a3VobWZlbml6aGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwNTUzNTksImV4cCI6MjA1ODYzMTM1OX0.LylLA1Qnwcx7K3CSjjlUZWdQFtxA1vcWPAKe6A0kyJs',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2E6F40), // Dark Green
        scaffoldBackgroundColor: Color(0xFFCFFFD6), // Light Mint Green
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2E6F40), // Dark Green
          foregroundColor: Colors.white, // Ensures text is readable
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF68BA7F), // Medium Green
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF253D2C)), // Darkest Green
          bodyMedium: TextStyle(color: Color(0xFF253D2C)),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
