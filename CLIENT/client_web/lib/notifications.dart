import 'package:flutter/material.dart';

class ClientNotificationsPage extends StatefulWidget {
  const ClientNotificationsPage({super.key});

  @override
  State<ClientNotificationsPage> createState() =>
      _ClientNotificationsPageState();
}

class _ClientNotificationsPageState extends State<ClientNotificationsPage> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "New Proposal Received",
      "message": "John Doe sent a proposal for your project.",
      "time": "5m ago",
      "isRead": false
    },
    {
      "title": "Project Update",
      "message": "Freelancer updated the project status.",
      "time": "1h ago",
      "isRead": false
    },
    {
      "title": "Payment Processed",
      "message": "Your payment has been successfully processed.",
      "time": "Yesterday",
      "isRead": true
    },
    {
      "title": "Freelancer Message",
      "message": "You have a new message from a freelancer.",
      "time": "2d ago",
      "isRead": false
    },
  ];

  void markAsRead(int index) {
    setState(() {
      notifications[index]["isRead"] = true;
    });
  }

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Notifications"),
        backgroundColor: const Color(0xFF2E6F40),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                notifications.clear();
              });
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                "No new notifications",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
                  key: Key(notification["title"]),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => deleteNotification(index),
                  child: Card(
                    color: notification["isRead"]
                        ? Colors.white
                        : Colors.green.shade100,
                    child: ListTile(
                      title: Text(notification["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(notification["message"]),
                      trailing: Text(notification["time"],
                          style: TextStyle(color: Colors.grey.shade600)),
                      onTap: () => markAsRead(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
