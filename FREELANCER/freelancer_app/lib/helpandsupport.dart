import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Color(0xFF8C735B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need Assistance?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'If you have any questions or need support, feel free to reach out to us.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Contact Section
            ListTile(
              leading: Icon(Icons.email, color: Color(0xFF8C735B)),
              title: Text('Email Support'),
              subtitle: Text('support@skillconnect.com'),
              onTap: () {
                // Add email functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Color(0xFF8C735B)),
              title: Text('Call Us'),
              subtitle: Text('+1 234 567 890'),
              onTap: () {
                // Add call functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Color(0xFF8C735B)),
              title: Text('Live Chat'),
              subtitle: Text('Chat with our support team'),
              onTap: () {
                // Navigate to chat support page if available
              },
            ),
            SizedBox(height: 20),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ExpansionTile(
              title: Text('How do I submit a proposal?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'To submit a proposal, go to the Job Listings page, select a job, and click "Submit Proposal".',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('How do I withdraw my earnings?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Go to the Earnings & Transactions page and follow the withdrawal steps.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('How do I update my skills?'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Navigate to the Add Skills page from the dashboard and edit your skills.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
