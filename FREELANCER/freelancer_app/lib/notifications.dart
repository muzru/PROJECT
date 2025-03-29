import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> notifications = [
      {
        "title": "New Job Available",
        "message": "A new job matches your skills!"
      },
      {"title": "Payment Received", "message": "You have received a payment."},
      {
        "title": "Profile Approved",
        "message": "Your profile has been approved."
      },
      {
        "title": "Job Proposal Accepted",
        "message": "Your proposal has been accepted!"
      },
      {
        "title": "System Update",
        "message": "New features have been added to the platform."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF2E6F40), // Lush Forest Theme
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No new notifications",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: const Color(0xFFCFFFD6), // Light Mint Green background
                  child: ListTile(
                    leading: const Icon(Icons.notifications,
                        color: Color(0xFF2E6F40)),
                    title: Text(notification["title"] ?? "No Title",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notification["message"] ?? "No Message"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Add functionality to remove notification
                      },
                    ),
                  ),
                );
              },
            ),
      backgroundColor: const Color(0xFFCFFFD6), // Light Mint Green background
    );
  }
}
