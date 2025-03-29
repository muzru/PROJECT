import 'package:flutter/material.dart';

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

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending report to admin (Replace with backend integration)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your dispute has been submitted.")),
      );

      // Clear fields after submission
      setState(() {
        _selectedIssue = null;
        _detailsController.clear();
      });
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
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF68BA7F), // Medium Green
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Submit Report",
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFCFFFD6), // Light Mint Green background
    );
  }
}
