import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisputesPage extends StatefulWidget {
  const DisputesPage({super.key});

  @override
  _DisputesPageState createState() => _DisputesPageState();
}

class _DisputesPageState extends State<DisputesPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('*, tbl_client(client_name), tbl_freelancer(freelancer_name)')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching complaints: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitReply(int id) async {
    if (_replyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('tbl_complaint').update({
        'complaint_reply': _replyController.text,
        'complaint_status': 0, // Mark as replied
      }).eq('id', id);

      if (mounted) {
        _fetchComplaints(); // Refresh the list
        Navigator.of(context).pop(); // Close the dialog
        _replyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting reply: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReplyDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Complaint'),
        content: TextField(
          controller: _replyController,
          decoration: const InputDecoration(labelText: 'Enter your reply'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitReply(id),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Disputes"),
        backgroundColor: const Color(0xFF2E6F40),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Disputes Received",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _complaints.isEmpty
                      ? const Center(
                          child: Text(
                            'No disputes found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 16,
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Client Name')),
                              DataColumn(label: Text('Freelancer Name')),
                              DataColumn(label: Text('Category')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Reply')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _complaints.map((complaint) {
                              final id = complaint['id'] as int;
                              final clientName = complaint['tbl_client']
                                      ?['client_name'] ??
                                  'N/A';
                              final freelancerName = complaint['tbl_freelancer']
                                      ?['freelancer_name'] ??
                                  'N/A';
                              final category =
                                  complaint['category'] as String? ?? 'N/A';
                              final description =
                                  complaint['description'] as String? ?? 'N/A';
                              final createdAt =
                                  complaint['created_at'] as String? ?? 'N/A';
                              final reply =
                                  complaint['complaint_reply'] as String? ??
                                      'Pending';

                              return DataRow(cells: [
                                DataCell(Text(id.toString())),
                                DataCell(Text(clientName)),
                                DataCell(Text(freelancerName)),
                                DataCell(Text(category)),
                                DataCell(Text(description)),
                                DataCell(Text(createdAt)),
                                DataCell(Text(reply)),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: reply == 'Pending'
                                        ? () => _showReplyDialog(id)
                                        : null,
                                    child: const Text('Reply'),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
