import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisputeResolutionPage extends StatefulWidget {
  const DisputeResolutionPage({super.key});

  @override
  State<DisputeResolutionPage> createState() => _DisputeResolutionPageState();
}

class _DisputeResolutionPageState extends State<DisputeResolutionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIssue;
  final TextEditingController _detailsController = TextEditingController();

  final List<String> _issueTypes = [
    "Payment Issue",
    "Job Dispute",
    "Client Misconduct",
    "Account Problem",
    "Other"
  ];

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_complaint')
          .select()
          .eq('freelancer_id', userId)
          .order('created_at', ascending: false);
      setState(() {
        _complaints =
            (response as List).map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_complaint').insert({
        'freelancer_id': userId,
        'category': _selectedIssue,
        'description': _detailsController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your dispute has been submitted.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedIssue = null;
        _detailsController.clear();
      });
      _fetchComplaints(); // Refresh the complaint list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting dispute: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispute Resolution"),
        backgroundColor: const Color(0xFF2E6F40), // Lush Forest Theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Report an Issue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Dropdown for selecting issue type
              DropdownButtonFormField<String>(
                value: _selectedIssue,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Issue Type",
                ),
                items: _issueTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedIssue = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select an issue" : null,
              ),

              const SizedBox(height: 15),

              // Text field for additional details
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Describe the issue",
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter details"
                    : null,
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF68BA7F), // Medium Green
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Submit Report",
                          style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Your Disputes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _complaints.isEmpty
                        ? const Center(child: Text("No disputes found"))
                        : ListView.builder(
                            itemCount: _complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = _complaints[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    complaint['category'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(complaint['description']),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Submitted on: ${complaint['created_at']?.toString().split('T')[0] ?? 'N/A'}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFCFFFD6), // Light Mint Green background
    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
