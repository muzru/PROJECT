import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
        backgroundColor: Color(0xFF2E6F40), // Dark Green
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Privacy Policy",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "This Privacy Policy explains how we collect, use, and protect your information...",
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF2E6F40)), // Dark Green
              ),
              SizedBox(height: 20),
              Text(
                "1. Information We Collect",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "We collect personal information such as name, email, and usage data...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "2. How We Use Your Data",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "Your data is used to improve our services and provide a personalized experience...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
              SizedBox(height: 10),
              Text(
                "3. Data Security",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6F40)), // Dark Green
              ),
              Text(
                  "We implement security measures to protect your personal information...",
                  style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
            ],
          ),
        ),
      ),
    );
  }
}
