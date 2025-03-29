import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Sample report data
  List<Map<String, String>> reports = [
    {
      "title": "User Registrations",
      "description": "Total new users registered in the last month",
      "date": "2025-03-22"
    },
    {
      "title": "Payments Processed",
      "description": "Total payments completed between clients and freelancers",
      "date": "2025-03-21"
    },
    {
      "title": "Disputes Resolved",
      "description": "Summary of disputes resolved in the last 30 days",
      "date": "2025-03-20"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Generated Reports",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  var report = reports[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(report['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report['description']!),
                          SizedBox(height: 5),
                          Text("Generated on: ${report['date']!}",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {
                          // Placeholder function for downloading report
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Downloading ${report['title']}...")),
                          );
                        },
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
