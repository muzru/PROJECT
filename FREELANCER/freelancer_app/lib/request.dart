import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestWorkPage extends StatefulWidget {
  final int workId;
  const RequestWorkPage({super.key, required this.workId});

  @override
  State<RequestWorkPage> createState() => _RequestWorkPageState();
}

class _RequestWorkPageState extends State<RequestWorkPage> {
  final _dateController = TextEditingController();
  final _statusController = TextEditingController(text: 'Pending');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _submitRequest() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      await Supabase.instance.client.from('tbl_workrequest').insert({
        'workrequest_date': _dateController.text,
        'work_id': widget.workId,
        'freelancer_id':
            int.parse(user.id.split('-').first), // Map UUID to int if needed
        'workrequest_status': _statusController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to submit request: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Request Work',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Request Date'),
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  _dateController.text = picked.toIso8601String().split('T')[0];
                }
              },
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status'),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                : ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(
                      'Submit Request',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage!,
                    style: GoogleFonts.poppins(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
