import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freelancer_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class WorkDetailsPage extends StatefulWidget {
  final int workId;
  const WorkDetailsPage({super.key, required this.workId});

  @override
  State<WorkDetailsPage> createState() => _WorkDetailsPageState();
}

class _WorkDetailsPageState extends State<WorkDetailsPage> {
  Map<String, dynamic>? _work;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    _loadWorkDetails();
  }

  Future<void> _loadWorkDetails() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await Supabase.instance.client.from('tbl_work').select('''
            work_id,
            work_name,
            work_details,
            work_amount,
            work_file,
            worktype_id,
            client_id,
            tbl_worktype (worktype_name),
            tbl_client (client_name, client_email, client_contact, client_photo)
          ''').eq('work_id', widget.workId).single();

      // Check if a request already exists for this work and current freelancer
      final user = supabase.auth.currentUser;
      if (user != null) {
        final requestResponse = await Supabase.instance.client
            .from('tbl_workrequest')
            .select('workrequest_id')
            .eq('work_id', widget.workId)
            .eq('freelancer_id', user.id)
            .maybeSingle();

        setState(() {
          _hasRequested = requestResponse != null;
        });
      }

      print("Fetched work data: $response");
      setState(() {
        _work = response;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading work details: $e");
      setState(() {
        _errorMessage = "Failed to load work details: $e";
        _isLoading = false;
      });
    }
  }

  Future<String?> _getFileUrl(String filePath) async {
    try {
      if (filePath.isEmpty) {
        throw Exception("File path is empty");
      }

      if (Uri.tryParse(filePath)?.isAbsolute ?? false) {
        print("Using provided URL: $filePath");
        return filePath;
      }

      String cleanPath = filePath;
      if (cleanPath.startsWith('/')) {
        cleanPath = cleanPath.substring(1);
      }
      if (cleanPath.startsWith('workfiles/')) {
        cleanPath = cleanPath.substring('workfiles/'.length);
      }

      final url = Supabase.instance.client.storage
          .from('workfiles')
          .getPublicUrl(cleanPath);
      print("Generated file URL: $url");
      if (url.isEmpty) {
        throw Exception("Generated URL is empty");
      }
      return url;
    } catch (e) {
      print("Error generating file URL: $e");
      return null;
    }
  }

  Future<void> _viewFile(String filePath) async {
    try {
      final fileUrl = await _getFileUrl(filePath);
      if (fileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to access file URL')),
        );
        return;
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            url: fileUrl,
            title: _work?['work_name'] ?? 'Work File',
          ),
        ),
      );
    } catch (e) {
      print("Error viewing file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing file: $e')),
      );
    }
  }

  Future<void> _requestJob() async {
    TextEditingController messageController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Job'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(hintText: 'Enter your message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                try {
                  await Supabase.instance.client
                      .from('tbl_workrequest')
                      .insert({
                    'work_id': widget.workId,
                    'workrequest_message': messageController.text,
                    'created_at': DateTime.now().toIso8601String(),
                    'freelancer_id': supabase.auth.currentUser!.id,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job request submitted')),
                  );
                  Navigator.pop(context);
                  setState(() {
                    _hasRequested =
                        true; // Update state after successful request
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to submit request: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a message')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Job Details',
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style:
                          GoogleFonts.poppins(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _work != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _work?['work_name'] ?? 'Untitled Job',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Details: ${_work?['work_details'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Amount: ${_work?['work_amount'] ?? '0.00'}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_work?['work_file'] != null &&
                                _work!['work_file'].toString().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attached File:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _viewFile(_work!['work_file']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A11CB),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                      'View File',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),
                            Text(
                              'Work Type: ${_work?['tbl_worktype']?['worktype_name'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Client Details:',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Name: ${_work?['tbl_client']['client_name'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Email: ${_work?['tbl_client']['client_email'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Contact: ${_work?['tbl_client']['client_contact'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            if (_work?['tbl_client']['client_photo'] != null &&
                                _work!['tbl_client']['client_photo'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.network(
                                  _work!['tbl_client']['client_photo'],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error,
                                          size: 50, color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        "No data available",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _hasRequested
            ? Text(
                'Request Already Submitted',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              )
            : ElevatedButton(
                onPressed: _requestJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Request Job',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}

// Include the PDFViewerScreen
class PDFViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerScreen({super.key, required this.url, required this.title});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? _totalPages;
  int _currentPage = 0;
  bool _isReady = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF6A11CB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final Uri uri = Uri.parse(widget.url);
              final String mimeType = _getMimeType(widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                  webViewConfiguration:
                      WebViewConfiguration(headers: {'Content-Type': mimeType}),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch ${widget.url}')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PDF(
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            defaultPage: _currentPage,
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page!;
                _totalPages = total;
              });
            },
            onViewCreated: (controller) {
              _controller.complete(controller);
              setState(() {
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _hasError = true;
              });
              print('Error loading PDF: $error');
            },
            onRender: (pages) {
              setState(() {
                _totalPages = pages;
              });
            },
          ).fromUrl(widget.url),
          if (_isReady && _totalPages != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          if (!_isReady && !_hasError) _buildLoadingWidget(),
          if (_hasError) _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 200,
              height: 280,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Loading document...',
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A11CB))),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Failed to load PDF',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade400)),
          const SizedBox(height: 8),
          Text('Please check the URL or try again later',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isReady = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  String _getMimeType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.pdf')) return 'application/pdf';
    if (lowerUrl.endsWith('.doc') || lowerUrl.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    return 'application/octet-stream';
  }
}
