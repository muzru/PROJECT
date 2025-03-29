import 'package:flutter/material.dart';

class ManageFreelancersPage extends StatelessWidget {
  final List<String> freelancers = ["John Doe", "Jane Smith", "Alice Brown"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Freelancers"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: ListView.builder(
        itemCount: freelancers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(freelancers[index]),
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
