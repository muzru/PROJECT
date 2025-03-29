import 'package:flutter/material.dart';

class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});
  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  final List<Map<String, String>> proposals = [
    {'job': 'Graphic Designer', 'status': 'Pending'},
    {'job': 'Web Developer', 'status': 'Accepted'},
    {'job': 'Content Writer', 'status': 'Rejected'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Submitted Proposals")),
      body: ListView.builder(
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text("Proposal for ${proposals[index]['job']}"),
              subtitle: Text("Status: ${proposals[index]['status']}"),
              trailing: Icon(
                proposals[index]['status'] == 'Accepted'
                    ? Icons.check_circle
                    : proposals[index]['status'] == 'Rejected'
                        ? Icons.cancel
                        : Icons.hourglass_empty,
                color: proposals[index]['status'] == 'Accepted'
                    ? Colors.green
                    : proposals[index]['status'] == 'Rejected'
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }
}
