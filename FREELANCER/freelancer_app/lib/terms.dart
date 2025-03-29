import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms & Conditions"),
        backgroundColor: Color(0xFF2E6F40), // Dark Green
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Terms & Conditions",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "By using our platform, you agree to the following terms...",
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF2E6F40)), // Dark Green
              ),
              SizedBox(height: 20),
              Text(
                "1. User Responsibilities",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "Users must follow guidelines and use the platform responsibly...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "2. Service Limitations",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "We reserve the right to modify or discontinue services at any time...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "3. Account Suspension",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "Violating terms may result in account suspension or termination...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
            ],
          ),
        ),
      ),
    );
  }
}
