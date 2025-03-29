import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final List<Map<String, dynamic>> payments = [
    {
      "client": "John Doe",
      "freelancer": "Alice Smith",
      "amount": 500,
      "date": "2025-03-20",
      "status": "Completed"
    },
    {
      "client": "Jane Roe",
      "freelancer": "Bob Johnson",
      "amount": 750,
      "date": "2025-03-21",
      "status": "Pending"
    },
    {
      "client": "Mike Brown",
      "freelancer": "Charlie White",
      "amount": 1200,
      "date": "2025-03-22",
      "status": "Completed"
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Search by Client or Freelancer",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Client")),
                  DataColumn(label: Text("Freelancer")),
                  DataColumn(label: Text("Amount")),
                  DataColumn(label: Text("Date")),
                  DataColumn(label: Text("Status")),
                ],
                rows: payments
                    .where((payment) =>
                        payment["client"].toLowerCase().contains(searchQuery) ||
                        payment["freelancer"]
                            .toLowerCase()
                            .contains(searchQuery))
                    .map((payment) => DataRow(cells: [
                          DataCell(Text(payment["client"])),
                          DataCell(Text(payment["freelancer"])),
                          DataCell(Text("\$${payment["amount"]}")),
                          DataCell(Text(payment["date"])),
                          DataCell(Text(payment["status"],
                              style: TextStyle(
                                  color: payment["status"] == "Completed"
                                      ? Colors.green
                                      : Colors.orange))),
                        ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
