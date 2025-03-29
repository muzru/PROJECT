import 'package:flutter/material.dart';

class DisputesPage extends StatefulWidget {
  @override
  _DisputesPageState createState() => _DisputesPageState();
}

class _DisputesPageState extends State<DisputesPage> {
  // Sample dispute data
  List<Map<String, String>> disputes = [
    {
      "name": "John Doe",
      "role": "Freelancer",
      "reason": "Client refused to pay",
      "date": "2025-03-20",
      "status": "Pending"
    },
    {
      "name": "Jane Smith",
      "role": "Client",
      "reason": "Freelancer did not submit work",
      "date": "2025-03-21",
      "status": "Pending"
    },
    {
      "name": "Alice Brown",
      "role": "Freelancer",
      "reason": "Client canceled after work started",
      "date": "2025-03-22",
      "status": "Resolved"
    }
  ];

  void updateStatus(int index, String newStatus) {
    setState(() {
      disputes[index]["status"] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Disputes"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Disputes Received",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: disputes.length,
                itemBuilder: (context, index) {
                  var dispute = disputes[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("${dispute['name']} (${dispute['role']})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reason: ${dispute['reason']}"),
                          Text("Date: ${dispute['date']}"),
                          Text("Status: ${dispute['status']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String newStatus) {
                          updateStatus(index, newStatus);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: "Pending", child: Text("Pending")),
                          PopupMenuItem(
                              value: "Resolved", child: Text("Resolved")),
                          PopupMenuItem(
                              value: "Rejected", child: Text("Rejected")),
                        ],
                        icon: Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
