import 'package:flutter/material.dart';
import 'package:freelancer_app/chat.dart';
import 'package:freelancer_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart'; // Matching import
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('tbl_workrequest')
          .select(
              'workrequest_id, work_id, workrequest_status, tbl_work (work_name, client_id)')
          .eq('freelancer_id', user.id)
          .order('workrequest_id', ascending: true);

      setState(() {
        _requests = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load requests: $e";
        _isLoading = false;
      });
    }
  }

  // Update status to Work Started (3)
  Future<void> _updateToWorkStarted(int workrequestId) async {
    try {
      await Supabase.instance.client.from('tbl_workrequest').update(
          {'workrequest_status': 3}).eq('workrequest_id', workrequestId);
      _loadRequests(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated to Work Started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  // Update status to Work Ended (4)
  Future<void> _updateToWorkEnded(int workrequestId) async {
    try {
      await Supabase.instance.client.from('tbl_workrequest').update(
          {'workrequest_status': 4}).eq('workrequest_id', workrequestId);
      _loadRequests(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated to Work Ended')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  // Upload work file when status is Work Ended
  Future<void> _uploadWorkFile(int workrequestId) async {
    try {
      // Pick file using file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any, // Allow any file type as in CreatePostPage
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() => _isLoading = true);

        // Upload file to Supabase storage
        final fileExt = file.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        Uint8List? fileBytes;

        // Handle file bytes for web or mobile
        if (file.bytes != null) {
          // Web platform
          fileBytes = file.bytes!;
        } else if (file.path != null) {
          // Mobile platform
          fileBytes = await File(file.path!).readAsBytes();
        } else {
          throw Exception('No file bytes or path available');
        }

        final bucketName = 'workfiles';
        await supabase.storage
            .from(bucketName)
            .uploadBinary(fileName, fileBytes);

        // Get public URL
        final publicUrl =
            supabase.storage.from(bucketName).getPublicUrl(fileName);

        // Update tbl_workrequest with file URL
        await supabase.from('tbl_workrequest').update(
            {'work_file': publicUrl}).eq('workrequest_id', workrequestId);

        _loadRequests(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('File uploaded successfully and linked to request')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Open chat with client_id from tbl_work
  void _openChat(int workrequestId) {
    final request = _requests.firstWhere(
      (req) => req['workrequest_id'] == workrequestId,
      orElse: () => {},
    );
    final clientId = request['tbl_work']?['client_id'] as String?;
    if (clientId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            freelancerId: Supabase.instance.client.auth.currentUser!.id,
            clientId: clientId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client ID not found for this request')),
      );
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Rejected';
      case 3:
        return 'Work Started';
      case 4:
        return 'Work Ended';
      case 5:
        return 'Payment Received';
      default:
        return 'Unknown';
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
          'My Requests',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _errorMessage != null
              ? Center(
                  child: Text(
                  _errorMessage!,
                  style: GoogleFonts.poppins(color: Colors.red),
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    final status = request['workrequest_status'] as int? ?? 0;
                    final workName =
                        request['tbl_work']?['work_name'] ?? 'Untitled Work';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request #${request['workrequest_id']} - $workName',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${_getStatusText(status)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(status),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Action buttons
                                if (status == 1)
                                  ElevatedButton(
                                    onPressed: () => _updateToWorkStarted(
                                        request['workrequest_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Start Work',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                if (status == 3)
                                  ElevatedButton(
                                    onPressed: () => _updateToWorkEnded(
                                        request['workrequest_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400]!,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'End Work',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                if (status == 4)
                                  ElevatedButton(
                                    onPressed: () => _uploadWorkFile(
                                        request['workrequest_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A11CB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Upload File',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                                // Chat button
                                if (status == 1 || status >= 4)
                                  ElevatedButton(
                                    onPressed: () =>
                                        _openChat(request['workrequest_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[600]!,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Chat',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.green; // Accepted
      case 2:
        return Colors.red; // Rejected
      case 3:
        return Colors.blue; // Work Started
      case 4:
        return Colors.purple; // Work Ended
      case 5:
        return Colors.teal; // Payment Received
      default:
        return Colors.grey;
    }
  }
}
