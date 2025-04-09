import 'package:flutter/material.dart';
import 'package:freelancer_app/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lxoefvgukuhmfenizheb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4b2Vmdmd1a3VobWZlbml6aGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMwNTUzNTksImV4cCI6MjA1ODYzMTM1OX0.LylLA1Qnwcx7K3CSjjlUZWdQFtxA1vcWPAKe6A0kyJs',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}
