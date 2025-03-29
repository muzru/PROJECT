import 'package:flutter/material.dart';

class ManageClientsPage extends StatelessWidget {
  final List<String> clients = ["Michael Lee", "Emma Watson", "David Johnson"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Clients"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(clients[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    // Accept logic here
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Reject logic here
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
