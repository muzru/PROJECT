import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer_app/workdetails.dart';

class FreelancerNotificationsPage extends StatefulWidget {
  const FreelancerNotificationsPage({super.key});

  @override
  State<FreelancerNotificationsPage> createState() =>
      _FreelancerNotificationsPageState();
}

class _FreelancerNotificationsPageState
    extends State<FreelancerNotificationsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Configurable status codes
  static const int statusAccepted = 1; // Work request accepted
  static const int statusRejected = 2; // Work request rejected
  static const int statusPaymentReceived = 5; // Payment received

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = supabase.auth.currentUser!.id;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
          _isLoading = false;
          _notifications = [];
        });
        return;
      }

      print("Fetching notifications for freelancer_id: ${user}");

      final workRequestResponse = await supabase
          .from('tbl_workrequest')
          .select('''
            workrequest_id,
            work_id,
            freelancer_id,
            tbl_work (work_name),
            created_at,
            workrequest_status,
            is_readf
          ''')
          .eq('freelancer_id', user)
          .eq('is_readf', false)
          .inFilter('workrequest_status', [1, 2, 5]);

      print("Work request response: $workRequestResponse");

      setState(() {
        _notifications =
            List<Map<String, dynamic>>.from(workRequestResponse).map((req) {
          final status = req['workrequest_status'] as int? ?? 0;
          final workName = req['tbl_work'] != null
              ? (req['tbl_work']['work_name'] as String? ?? 'Unnamed Work')
              : 'Unnamed Work';
          String statusMessage;

          switch (status) {
            case statusAccepted:
              statusMessage = 'Work request accepted: $workName';
              break;
            case statusRejected:
              statusMessage = 'Work request rejected: $workName';
              break;
            case statusPaymentReceived:
              statusMessage = 'Payment received: $workName';
              break;
            default:
              statusMessage = 'Work request update: $workName';
          }

          return {
            'notification_id': req['workrequest_id'],
            'message': statusMessage,
            'created_at': req['created_at']?.toString() ?? 'N/A',
            'workrequest_id': req['workrequest_id'],
            'work_id': req['work_id'],
            'type': 'work_request',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print("Error fetching notifications: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        _errorMessage = "Failed to fetch notifications: $e";
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(dynamic notificationId, String type) async {
    try {
      if (type == 'work_request') {
        await supabase
            .from('tbl_workrequest')
            .update({'is_readf': true}).eq('workrequest_id', notificationId);
        print("Marked notification $notificationId as read");
      }
      await _fetchNotifications();
    } catch (e) {
      print("Error marking as read: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error marking as read: $e")),
      );
    }
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null || timestamp == 'N/A') return 'Unknown';
    final date = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String message) {
    if (message.contains('accepted')) {
      return Icons.check_circle;
    } else if (message.contains('rejected')) {
      return Icons.cancel;
    } else if (message.contains('Payment received')) {
      return Icons.attach_money;
    }
    return Icons.work;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: const Color(0xFFF8F2F7),
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Retry',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No new notifications.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getNotificationIcon(notification['message']),
                                color: const Color(0xFF2E7D32),
                                size: 24,
                              ),
                              title: Text(
                                notification['message'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                _getTimeAgo(notification['created_at']),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              onTap: () {
                                _markAsRead(
                                  notification['workrequest_id'],
                                  notification['type'],
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkDetailsPage(
                                        workId: notification['work_id']),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
