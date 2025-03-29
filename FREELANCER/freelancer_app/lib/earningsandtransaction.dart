import 'package:flutter/material.dart';

class EarningsPage extends StatefulWidget {
  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  double totalEarnings = 1250.75;
  List<Map<String, dynamic>> transactions = [
    {'date': 'Mar 21, 2025', 'amount': 250.00, 'status': 'Completed'},
    {'date': 'Mar 18, 2025', 'amount': 500.00, 'status': 'Completed'},
    {'date': 'Mar 15, 2025', 'amount': 100.50, 'status': 'Pending'},
  ];

  void _withdrawFunds() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Withdraw Funds"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter withdrawal amount:"),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Amount"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Withdrawal Requested"),
                    content:
                        Text("Your withdrawal request is being processed."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Earnings & Transactions")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Earnings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("\\${totalEarnings.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 24, color: Colors.green)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _withdrawFunds,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child:
                  Text("Withdraw Funds", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Text("Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  var transaction = transactions[index];
                  return Card(
                    child: ListTile(
                      title: Text("\\${transaction['amount']}"),
                      subtitle: Text(transaction['date']),
                      trailing: Text(transaction['status'],
                          style: TextStyle(
                            color: transaction['status'] == 'Completed'
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          )),
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
