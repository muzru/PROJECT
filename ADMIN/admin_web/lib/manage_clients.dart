import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent styling
import 'package:cached_network_image/cached_network_image.dart'; // For image caching

class ManageClientsPage extends StatefulWidget {
  const ManageClientsPage({super.key});

  @override
  State<ManageClientsPage> createState() => _ManageClientsPageState();
}

class _ManageClientsPageState extends State<ManageClientsPage> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _clients = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('tbl_client')
          .select(
              'client_id, created_at, client_name, client_email, client_contact, client_photo, client_password, client_status')
          .order('client_name');

      if (mounted) {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching clients: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateClientStatus(String clientId, int status) async {
    try {
      await supabase
          .from('tbl_client')
          .update({'client_status': status}).eq('client_id', clientId);

      if (mounted) {
        _fetchClients(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 1
                  ? 'Client approved successfully'
                  : status == 2
                      ? 'Client rejected successfully'
                      : 'Client status updated to pending',
            ),
            backgroundColor: status == 1
                ? Colors.green
                : status == 2
                    ? Colors.red
                    : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating client status: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredClients {
    if (_searchQuery.isEmpty) {
      return _clients;
    }
    return _clients.where((client) {
      final name = client['client_name'].toString().toLowerCase();
      final email = client['client_email'].toString().toLowerCase();
      final contact = client['client_contact'].toString().toLowerCase();
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
      case 2:
        return 'Rejected';
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
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Manage Clients',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ),
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
                      onPressed: _fetchClients,
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
                          : _filteredClients.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off,
                                          size: 64,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text('No clients found',
                                          style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              color: Colors.grey.shade600)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredClients.length,
                                  itemBuilder: (context, index) {
                                    final client = _filteredClients[index];
                                    final status =
                                        client['client_status'] as int? ?? 0;
                                    final photoUrl =
                                        client['client_photo'] as String?;

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
                                                  client['client_name']
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
                                            client['client_name'] ?? 'Unknown',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                client['client_email'] ??
                                                    'No email',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.grey.shade600)),
                                            Text(
                                                'Contact: ${client['client_contact'] ?? 'Not provided'}',
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
                                                    : status == 2
                                                        ? Colors.red
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
                                                    _updateClientStatus(
                                                        client['client_id']
                                                            .toString(),
                                                        1),
                                                tooltip: 'Approve',
                                              ),
                                            if (status == 0)
                                              IconButton(
                                                icon: const Icon(Icons.block,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _updateClientStatus(
                                                        client['client_id']
                                                            .toString(),
                                                        2),
                                                tooltip: 'Reject',
                                              ),
                                            if (status == 1)
                                              IconButton(
                                                icon: const Icon(Icons.block,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _updateClientStatus(
                                                        client['client_id']
                                                            .toString(),
                                                        2),
                                                tooltip: 'Reject',
                                              ),
                                            if (status == 2)
                                              IconButton(
                                                icon: const Icon(Icons.undo,
                                                    color: Colors.orange),
                                                onPressed: () =>
                                                    _updateClientStatus(
                                                        client['client_id']
                                                            .toString(),
                                                        0),
                                                tooltip: 'Revert to Pending',
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(
                                                  client['client_name'] ??
                                                      'Client Details',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (photoUrl != null)
                                                      Center(
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: photoUrl,
                                                          height: 150,
                                                          width: 150,
                                                          fit: BoxFit.cover,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const CircularProgressIndicator(),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                        ),
                                                      ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                        'ID: ${client['client_id']}',
                                                        style: GoogleFonts
                                                            .poppins()),
                                                    Text(
                                                        'Name: ${client['client_name'] ?? 'Unknown'}',
                                                        style: GoogleFonts
                                                            .poppins()),
                                                    Text(
                                                        'Email: ${client['client_email'] ?? 'No email'}',
                                                        style: GoogleFonts
                                                            .poppins()),
                                                    Text(
                                                        'Contact: ${client['client_contact'] ?? 'Not provided'}',
                                                        style: GoogleFonts
                                                            .poppins()),
                                                    Text(
                                                        'Status: ${getStatusText(status)}',
                                                        style: GoogleFonts.poppins(
                                                            color:
                                                                getStatusColor(
                                                                    status))),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
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
