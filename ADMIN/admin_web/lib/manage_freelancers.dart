import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManageFreelancersPage extends StatefulWidget {
  const ManageFreelancersPage({super.key});

  @override
  State<ManageFreelancersPage> createState() => _ManageFreelancersPageState();
}

class _ManageFreelancersPageState extends State<ManageFreelancersPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _freelancers = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFreelancers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFreelancers() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('tbl_freelancer')
          .select(
              'freelancer_id, freelancer_name, freelancer_email, freelancer_contact, freelancer_photo, freelancer_status')
          .order('freelancer_name');

      if (mounted) {
        setState(() {
          _freelancers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching freelancers: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateFreelancerStatus(String freelancerId, int status) async {
    try {
      await supabase.from('tbl_freelancer').update(
          {'freelancer_status': status}).eq('freelancer_id', freelancerId);

      if (mounted) {
        _fetchFreelancers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 1
                  ? 'Freelancer approved successfully'
                  : status == 0
                      ? 'Freelancer rejected successfully'
                      : 'Freelancer status updated to pending',
            ),
            backgroundColor: status == 1
                ? Colors.green
                : status == 0
                    ? Colors.red
                    : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating freelancer status: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredFreelancers {
    if (_searchQuery.isEmpty) {
      return _freelancers;
    }
    return _freelancers.where((freelancer) {
      final name = freelancer['freelancer_name'].toString().toLowerCase();
      final email = freelancer['freelancer_email'].toString().toLowerCase();
      final contact = freelancer['freelancer_contact'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          contact.contains(query);
    }).toList();
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Freelancers',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or contact...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchFreelancers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6F40),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300, width: 1)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 80), // For photo
                          Expanded(
                              flex: 2,
                              child: Text('Name',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700))),
                          Expanded(
                              flex: 2,
                              child: Text('Email',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700))),
                          Expanded(
                              flex: 2,
                              child: Text('Contact',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700))),
                          Expanded(
                              flex: 1,
                              child: Text('Status',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700))),
                          const SizedBox(width: 120), // For actions
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF2E7D32)))
                          : _filteredFreelancers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off,
                                          size: 64,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text('No freelancers found',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              color: Colors.grey.shade600)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredFreelancers.length,
                                  itemBuilder: (context, index) {
                                    final freelancer =
                                        _filteredFreelancers[index];
                                    final status =
                                        freelancer['freelancer_status']
                                                as int? ??
                                            0;
                                    final photoUrl =
                                        freelancer['freelancer_photo']
                                            as String?;

                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 1)),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: photoUrl != null
                                              ? CachedNetworkImageProvider(
                                                  photoUrl)
                                              : const AssetImage(
                                                      'assets/default_profile.png')
                                                  as ImageProvider,
                                          backgroundColor: Colors.grey.shade200,
                                          child: photoUrl == null
                                              ? Text(
                                                  freelancer['freelancer_name']
                                                      .toString()
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2E6F40)))
                                              : null,
                                        ),
                                        title: Text(
                                            freelancer['freelancer_name'] ??
                                                'Unknown',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                freelancer[
                                                        'freelancer_email'] ??
                                                    'No email',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade600)),
                                            Text(
                                                'Contact: ${freelancer['freelancer_contact'] ?? 'Not provided'}',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade600)),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: status == 1
                                                    ? Colors.green
                                                        .withOpacity(0.1)
                                                    : Colors.orange
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                getStatusText(status),
                                                style: GoogleFonts.poppins(
                                                    color:
                                                        getStatusColor(status),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            if (status == 0)
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    _updateFreelancerStatus(
                                                        freelancer[
                                                                'freelancer_id']
                                                            .toString(),
                                                        1),
                                                tooltip: 'Approve',
                                              ),
                                            if (status == 1)
                                              IconButton(
                                                icon: const Icon(Icons.cancel,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _updateFreelancerStatus(
                                                        freelancer[
                                                                'freelancer_id']
                                                            .toString(),
                                                        0),
                                                tooltip: 'Reject',
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
          ],
        ),
      ),
    );
  }
}
