import 'package:client_web/chat.dart';
import 'package:client_web/freelancerdetails.dart';
import 'package:client_web/payments.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProposalsPage extends StatefulWidget {
  final VoidCallback? onProposalAccepted;

  const ProposalsPage({super.key, this.onProposalAccepted});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  List<Map<String, dynamic>> proposals = [];
  bool isLoading = true;
  String? errorMessage;
  int selectedProposalIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchProposals();
  }

  Future<void> _fetchProposals() async {
    setState(() => isLoading = true);
    try {
      final client = Supabase.instance.client.auth.currentUser;
      if (client == null) {
        setState(() {
          errorMessage = "User not authenticated";
          isLoading = false;
        });
        return;
      }

      // Fetch work_ids where the client is the creator from tbl_work
      final workResponse = await Supabase.instance.client
          .from('tbl_work')
          .select('work_id')
          .eq('client_id', client.id);

      final workIds = workResponse.map((work) => work['work_id']).toList();

      if (workIds.isEmpty) {
        setState(() {
          proposals = [];
          isLoading = false;
        });
        return;
      }

      // Fetch all work requests for each work_id individually
      final queries = workIds.map((workId) =>
          Supabase.instance.client.from('tbl_workrequest').select('''
          workrequest_id,
          created_at,
          workrequest_status,
          work_id,
          workrequest_message,
          workrequest_file,
          freelancer_id,
          tbl_freelancer (freelancer_name),
          tbl_work (work_amount, work_name)
        ''').eq('work_id', workId).order('created_at', ascending: false));
      final responses = await Future.wait(queries);
      final combinedResponse = responses.expand((x) => x).toList();

      setState(() {
        proposals = combinedResponse.map((req) {
          final freelancerData =
              req['tbl_freelancer'] as Map<String, dynamic>? ?? {};
          final workData = req['tbl_work'] as Map<String, dynamic>? ?? {};
          return {
            'workrequest_id': req['workrequest_id'],
            'freelancer': freelancerData['freelancer_name'] ?? 'Unknown',
            'proposal': req['workrequest_message'] ?? 'No details provided',
            'price': workData['work_amount'] ?? 0,
            'work_name': workData['work_name'] ?? 'Unnamed Work',
            'file_url': req['workrequest_file'],
            'status': _mapStatus(req['workrequest_status']),
            'created_at': req['created_at'],
            'freelancer_id': req['freelancer_id'],
            'work_id': req['work_id'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load proposals: $e";
        isLoading = false;
      });
      print("Error fetching proposals: $e");
    }
  }

  // Map workrequest_status to a readable status based on new definitions
  String _mapStatus(dynamic status) {
    switch (status) {
      case 1:
        return 'Accepted';
      case 2:
        return 'Rejected';
      case 3:
        return 'Started';
      case 4:
        return 'Ended';
      case 5:
        return 'Paid'; // New status for when payment is completed
      default:
        return 'Pending';
    }
  }

  Future<void> _updateProposalStatus(int workrequestId, int status) async {
    try {
      await Supabase.instance.client.from('tbl_workrequest').update(
          {'workrequest_status': status}).eq('workrequest_id', workrequestId);
      await _fetchProposals(); // Refresh proposals
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  void _navigateToPayment(int index) {
    final proposal = proposals[index];

    // Safely convert price to double, defaulting to 0.0 if null or invalid
    final price = proposal['price'] is num
        ? proposal['price'].toDouble()
        : (double.tryParse(proposal['price'].toString()) ?? 0.0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayPage(
          workRequestId: proposal['workrequest_id'],
          amount: price,
          workName: proposal['work_name'],
          onPaymentSuccess: () async {
            // Update workrequest_status to 5 (Paid) after payment
            await _updateProposalStatus(proposal['workrequest_id'], 5);
            setState(() {
              selectedProposalIndex = index;
            });
            _downloadFile(index); // Trigger download after payment
          },
        ),
      ),
    );
  }

  void _navigateToChat(int index) {
    final proposal = proposals[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chat(
          freelancerId: proposal['freelancer_id'],
          clientId: Supabase.instance.client.auth.currentUser?.id ?? '',
        ),
      ),
    );
  }

  void _downloadFile(int index) {
    final fileUrl = proposals[index]['file_url'];
    if (fileUrl == null || fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file available for download")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloading file from: $fileUrl")),
      );
      // For demo, just show URL; use url_launcher for real downloads
      // launchUrl(Uri.parse(fileUrl)); // Uncomment if using url_launcher
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E6F40)))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProposals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E6F40),
                        ),
                        child: Text('Retry', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                )
              : proposals.isEmpty
                  ? Center(
                      child: Text(
                        'No work requests available.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: proposals.length,
                      itemBuilder: (context, index) {
                        final proposal = proposals[index];
                        final isWorkComplete =
                            proposal['status'] == 'Started' ||
                                proposal['status'] == 'Ended';
                        final showChat = proposal['status'] != 'Pending' &&
                            proposal['status'] != 'Rejected';
                        final showPaymentDownload = proposal['status'] ==
                            'Ended'; // Changed to status 4

                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              "${proposal['work_name']} - ${proposal['freelancer'] ?? 'Unknown'}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  proposal["proposal"] ?? "No details provided",
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "\$${proposal['price']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Status: ${proposal['status']}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: proposal['status'] == 'Accepted'
                                        ? Colors.green
                                        : proposal['status'] == 'Rejected'
                                            ? Colors.red
                                            : proposal['status'] == 'Started'
                                                ? Colors.orange
                                                : proposal['status'] == 'Ended'
                                                    ? Colors.blue
                                                    : proposal['status'] ==
                                                            'Paid'
                                                        ? Colors.green[700]
                                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline,
                                      color: Colors.teal),
                                  tooltip: "View Freelancer Profile",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FreelancerDetailsPage(
                                          freelancerId:
                                              proposal['freelancer_id'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (proposal['status'] == 'Pending') ...[
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () => _updateProposalStatus(
                                        proposal['workrequest_id'], 1),
                                    tooltip: "Accept Proposal",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () => _updateProposalStatus(
                                        proposal['workrequest_id'], 2),
                                    tooltip: "Reject Proposal",
                                  ),
                                ],
                                if (proposal['status'] == 'Accepted')
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow,
                                        color: Colors.orange),
                                    onPressed: () => _updateProposalStatus(
                                        proposal['workrequest_id'], 3),
                                    tooltip: "Start Work",
                                  ),
                                if (showChat)
                                  IconButton(
                                    icon: const Icon(Icons.chat,
                                        color: Colors.purple),
                                    onPressed: () => _navigateToChat(index),
                                    tooltip: "Chat",
                                  ),
                                if (showPaymentDownload)
                                  IconButton(
                                    icon: const Icon(Icons.payment,
                                        color: Colors.blue),
                                    onPressed: () => _navigateToPayment(index),
                                    tooltip: "Pay",
                                  ),
                                if (proposal['status'] == 'Paid')
                                  IconButton(
                                    icon: const Icon(Icons.download,
                                        color: Colors.green),
                                    onPressed: () => _downloadFile(index),
                                    tooltip: "Download File",
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
