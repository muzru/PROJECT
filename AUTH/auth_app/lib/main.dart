import 'package:auth_app/pages/client_signup.dart';
import 'package:flutter/material.dart';
import 'pages/freelance_signup.dart'; // Enancesure this path is correct

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase App',
      home: ClientSignup(), // Ensure this class exists
    );
  }
}
