import 'package:flutter/material.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({super.key});

  @override
  State<JobPostingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobPostingPage> {
  final List<Map<String, String>> _postedJobs = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  void _postJob() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _budgetController.text.isNotEmpty) {
      setState(() {
        _postedJobs.add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'budget': _budgetController.text,
        });
      });
      _titleController.clear();
      _descriptionController.clear();
      _budgetController.clear();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  void _showPostJobDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Post a New Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _postJob,
              child: const Text('Post Job'),
            ),
          ],
        );
      },
    );
  }

  void _deleteJob(int index) {
    setState(() {
      _postedJobs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Jobs'),
        backgroundColor: Colors.green[700],
      ),
      body: _postedJobs.isEmpty
          ? const Center(child: Text('No jobs posted yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _postedJobs.length,
              itemBuilder: (context, index) {
                final job = _postedJobs[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      job['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(job['description']!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${job['budget']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteJob(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: _showPostJobDialog,
        tooltip: 'Post a Job',
        child: const Icon(Icons.add),
      ),
    );
  }
}
