import 'package:client_web/dispute.dart';
import 'package:client_web/login.dart';
import 'package:client_web/notifications.dart';
import 'package:client_web/profile.dart';
import 'package:client_web/proposal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  bool _isMobile = false;
  bool _isSidebarOpen = false;

  final List<Widget> _pages = [
    const DashboardHomePage(),
    const JobPostingPage(),
    ProposalsPage(),
    const ClientProfilePage(),
    const DisputeResolutionPage(),
  ];

  final List<String> _pageTitles = [
    "Dashboard",
    "Post a Job",
    "Proposals",
    "Profile",
    "Disputes",
  ];

  final List<IconData> _pageIcons = [
    Icons.dashboard,
    Icons.work,
    Icons.assignment,
    Icons.person,
    Icons.gavel,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_isMobile) {
        _isSidebarOpen = false;
        Navigator.of(context).pop();
      }
    });
  }

  // Fetch client details
  Future<void> fetchclientDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('tbl_client')
          .select()
          .eq('client_id', user.id)
          .single();
      if (mounted) {
        setState(() {
          clientName = response['client_name'] ?? 'Unknown';
          clientEmail = response['client_email'] ?? 'No email';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          clientName = 'Unknown';
          clientEmail = 'No email';
        });
        print('Error fetching client details: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchclientDetails(); // Fetch client details on init
  }

  String clientName = "Loading..."; // Initial value
  String clientEmail = "Loading..."; // Initial value

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _isMobile = screenWidth < 768;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          title: Row(
            children: [
              if (_isMobile)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSidebarOpen = !_isSidebarOpen;
                    });
                    if (_isSidebarOpen) {
                      Scaffold.of(context).openDrawer();
                    }
                  },
                ),
              const Icon(Icons.business, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Text(
                'Client Dashboard',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E6F40),
          elevation: 0,
          actions: [
            if (!_isMobile) ...[
              // _buildNotificationBadge(),
              const SizedBox(width: 16),
              _buildUserProfile(clientName, clientEmail),
              const SizedBox(width: 24),
            ] else ...[
              _buildNotificationBadge(),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
      drawer: _isMobile ? _buildMobileSidebar(clientName, clientEmail) : null,
      body: Row(
        children: [
          if (!_isMobile) _buildDesktopSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarCollapsed ? 80 : 250,
      color: const Color(0xFF2E6F40),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Align(
            alignment:
                _isSidebarCollapsed ? Alignment.center : Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: List.generate(
                _pageTitles.length,
                (index) => _buildSidebarItem(
                  _pageIcons[index],
                  _pageTitles[index],
                  index,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: _isSidebarCollapsed
                ? null
                : Text(
                    "Logout",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
            onTap: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: _isSidebarCollapsed ? 0 : 16,
              vertical: 8,
            ),
            horizontalTitleGap: 0,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMobileSidebar(String clientName, String clientEmail) {
    return Drawer(
      child: Container(
        color: const Color(0xFF2E6F40),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E5F30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF2E6F40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    clientName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    clientEmail,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: List.generate(
                  _pageTitles.length,
                  (index) => _buildSidebarItem(
                    _pageIcons[index],
                    _pageTitles[index],
                    index,
                    isMobile: true,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              onTap: () {
                Supabase.instance.client.auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index,
      {bool isMobile = false}) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: _isSidebarCollapsed && !isMobile
            ? null
            : Text(
                title,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
        onTap: () => _onItemTapped(index),
        contentPadding: EdgeInsets.symmetric(
          horizontal: _isSidebarCollapsed && !isMobile ? 0 : 16,
          vertical: 4,
        ),
        horizontalTitleGap: 0,
        minLeadingWidth: _isSidebarCollapsed && !isMobile ? 80 : 40,
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClientNotificationsPage(),
              ),
            );
          },
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Text(
              "3", // TODO: Replace with dynamic notification count
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile(String clientName, String clientEmail) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            color: Color(0xFF2E6F40),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clientName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              clientEmail,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  final supabase = Supabase.instance.client;
  int _activeJobsCount = 0;
  int _newProposalsCount = 0;
  int _messagesCount = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentApplications = [];
  List<Map<String, dynamic>> _postedJobs = [];
  String clientName = "Loading..."; // Initial value
  String clientEmail = "Loading..."; // Initial value

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchJobs();
    fetchclientDetails();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      // Fetch active jobs count
      final jobsResponse = await supabase
          .from('tbl_work')
          .select('work_id')
          .eq('client_id', userId); // Adjust if status field differs
      _activeJobsCount = jobsResponse.length;

      // Fetch new proposals count
      final workIdsResponse = await supabase
          .from('tbl_work')
          .select('work_id')
          .eq('client_id', userId);
      final workIds = workIdsResponse.map((w) => w['work_id']).toList();
      final proposalsResponse = workIds.isNotEmpty
          ? await supabase
              .from('tbl_workrequest')
              .select('workrequest_id')
              .inFilter('work_id', workIds)
              .eq('workrequest_status', 0) // Pending proposals
          : [];
      _newProposalsCount = proposalsResponse.length;

      // Fetch unread messages count (assumed tbl_messages)
      // final messagesResponse = await supabase
      //     .from('tbl_messages')
      //     .select('message_id')
      //     .eq('receiver_id', userId)
      //     .eq('is_read', false);
      // _messagesCount = messagesResponse.length;

      // Fetch recent applications
      final applicationsResponse = workIds.isNotEmpty
          ? await supabase
              .from('tbl_workrequest')
              .select('''
                workrequest_id,
                workrequest_message,
                created_at,
                freelancer_id,
                work_id,
                tbl_freelancer(freelancer_name),
                tbl_work(work_name)
              ''')
              .inFilter('work_id', workIds)
              .order('created_at', ascending: false)
              .limit(5)
          : [];
      _recentApplications = applicationsResponse.map((req) {
        final freelancerData =
            req['tbl_freelancer'] as Map<String, dynamic>? ?? {};
        final workData = req['tbl_work'] as Map<String, dynamic>? ?? {};
        return {
          'freelancer_name': freelancerData['freelancer_name'] ?? 'Unknown',
          'work_name': workData['work_name'] ?? 'Unnamed Job',
          'message': req['workrequest_message'] ?? 'No message provided',
          'created_at': req['created_at'],
        };
      }).toList();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await supabase
          .from('tbl_work')
          .select()
          .eq('client_id', supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);
      setState(() {
        _postedJobs.clear();
        _postedJobs.addAll(
            (response as List).map((e) => e as Map<String, dynamic>).toList());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching jobs: $e')));
      }
    }
  }

  String _getTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Unknown';
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

  Future<void> fetchclientDetails() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('tbl_client')
          .select()
          .eq('client_id', user.id)
          .single();
      if (mounted) {
        setState(() {
          clientName = response['client_name'] ?? 'Unknown';
          clientEmail = response['client_email'] ?? 'No email';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          clientName = 'Unknown';
          clientEmail = 'No email';
        });
        print('Error fetching client details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E6F40), Color(0xFF68BA7F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $clientName!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your projects today.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isDesktop || isTablet
                        ? Row(
                            children: [
                              _buildStatCard(
                                '$_activeJobsCount',
                                'Active Jobs',
                                Icons.work,
                                Colors.white,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                '$_newProposalsCount',
                                'New Proposals',
                                Icons.description,
                                Colors.white,
                              ),
                              const SizedBox(width: 16),
                              // _buildStatCard(
                              //   '$_messagesCount',
                              //   'Messages',
                              //   Icons.message,
                              //   Colors.white,
                              // ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildStatCard(
                                '$_activeJobsCount',
                                'Active Jobs',
                                Icons.work,
                                Colors.white,
                                isFullWidth: true,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                '$_newProposalsCount',
                                'New Proposals',
                                Icons.description,
                                Colors.white,
                                isFullWidth: true,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                '$_messagesCount',
                                'Messages',
                                Icons.message,
                                Colors.white,
                                isFullWidth: true,
                              ),
                            ],
                          ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildRecentApplications(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Recent Jobs',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context
                          .findAncestorStateOfType<_ClientDashboardState>()
                          ?._onItemTapped(1),
                      child: Text(
                        'View All',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2E6F40),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _postedJobs.isEmpty
                        ? Center(
                            child: Text(
                              'No jobs posted yet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                _postedJobs.length > 3 ? 3 : _postedJobs.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final job = _postedJobs[index];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.work,
                                    color: Color(0xFF2E6F40),
                                  ),
                                ),
                                title: Text(
                                  job['work_name'] ?? 'Unnamed Job',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job['work_details'] ?? 'No details',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Budget: \$${job['work_amount'] ?? 0}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  job['status'] ?? 'Unknown',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: job['status'] == 'active'
                                        ? Colors.green
                                        : job['status'] == 'completed'
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color,
      {bool isFullWidth = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplications() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Applications',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _recentApplications.isEmpty
                  ? Center(
                      child: Text(
                        'No recent applications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : Column(
                      children: _recentApplications.map((app) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${app['freelancer_name']} applied to "${app['work_name']}"',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      app['message'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTimeAgo(app['created_at']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({super.key});

  @override
  State<JobPostingPage> createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  final List<Map<String, dynamic>> _postedJobs = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  bool _isLoading = false;
  int? _selectedWorkType;
  PlatformFile? _pickedFile;
  String? _fileName;
  String _selectedView = 'active';

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _workTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _fetchWorkTypes();
  }

  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_work')
          .select()
          .eq('client_id', userId)
          .order('created_at', ascending: false);
      setState(() {
        _postedJobs.clear();
        _postedJobs.addAll(
            (response as List).map((e) => e as Map<String, dynamic>).toList());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching jobs: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchWorkTypes() async {
    try {
      final response = await supabase
          .from('tbl_worktype')
          .select('worktype_id, worktype_name');
      setState(() {
        _workTypes =
            (response as List).map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching work types: $e')));
      }
    }
  }

  Future<String?> _uploadFile() async {
    if (_pickedFile == null) return null;
    try {
      final bucketName = 'workfiles';
      String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());
      final filePath = "$formattedDate-${_pickedFile!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            _pickedFile!.bytes!,
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      }
      return null;
    }
  }

  Future<void> _postJob() async {
    if (_formKey.currentState!.validate() && _selectedWorkType != null) {
      setState(() => _isLoading = true);
      try {
        final fileUrl = await _uploadFile();
        final jobData = {
          'work_name': _titleController.text,
          'work_details': _descriptionController.text,
          'work_amount': double.parse(_budgetController.text),
          'worktype_id': _selectedWorkType,
          'work_file': fileUrl,
          'client_id': supabase.auth.currentUser!.id,
          'deadline': _deadlineController.text.isNotEmpty
              ? _deadlineController.text
              : null,
        };

        final response =
            await supabase.from('tbl_work').insert(jobData).select();
        final newJob = response[0];

        setState(() {
          _postedJobs.insert(0, newJob);
          _pickedFile = null;
          _fileName = null;
        });

        _titleController.clear();
        _descriptionController.clear();
        _budgetController.clear();
        _deadlineController.clear();
        _selectedWorkType = null;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error posting job: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_selectedWorkType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a work type')));
    }
  }

  Future<void> _deleteJob(String jobId, int index) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete this job posting?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);
    try {
      await supabase
          .from('tbl_work')
          .update({'status': 'deleted'}).eq('work_id', jobId);
      setState(() {
        _postedJobs.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPostJobDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Post a New Job',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Job Title',
                                  hintText: 'Enter a clear title for your job',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.work),
                                  labelStyle: GoogleFonts.poppins(),
                                  hintStyle: GoogleFonts.poppins(),
                                ),
                                style: GoogleFonts.poppins(),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a job title'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  hintText:
                                      'Describe the job requirements in detail',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.description),
                                  alignLabelWithHint: true,
                                  labelStyle: GoogleFonts.poppins(),
                                  hintStyle: GoogleFonts.poppins(),
                                ),
                                style: GoogleFonts.poppins(),
                                maxLines: 5,
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter a description'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _budgetController,
                                      decoration: InputDecoration(
                                        labelText: 'Budget (\$)',
                                        hintText: 'Enter your budget',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.attach_money),
                                        labelStyle: GoogleFonts.poppins(),
                                        hintStyle: GoogleFonts.poppins(),
                                      ),
                                      style: GoogleFonts.poppins(),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a budget';
                                        }
                                        if (double.tryParse(value) == null ||
                                            double.parse(value) <= 0) {
                                          return 'Please enter a valid budget';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _deadlineController,
                                      decoration: InputDecoration(
                                        labelText: 'Deadline (Optional)',
                                        hintText: 'MM/DD/YYYY',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                        labelStyle: GoogleFonts.poppins(),
                                        hintStyle: GoogleFonts.poppins(),
                                      ),
                                      style: GoogleFonts.poppins(),
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now()
                                              .add(const Duration(days: 7)),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 365)),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _deadlineController.text =
                                                DateFormat('MM/dd/yyyy')
                                                    .format(date);
                                          });
                                        }
                                      },
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _selectedWorkType,
                                decoration: InputDecoration(
                                  labelText: 'Work Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                                  labelStyle: GoogleFonts.poppins(),
                                  hintStyle: GoogleFonts.poppins(),
                                ),
                                items: _workTypes.map((type) {
                                  return DropdownMenuItem<int>(
                                    value: type['worktype_id'] as int,
                                    child: Text(
                                      type['worktype_name'] as String,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWorkType = value;
                                  });
                                },
                                validator: (value) => value == null
                                    ? 'Please select a work type'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _fileName != null
                                          ? Text(
                                              _fileName!,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : Text(
                                              'No file selected',
                                              style: GoogleFonts.poppins(),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final result =
                                            await FilePicker.platform.pickFiles(
                                          allowMultiple: false,
                                        );
                                        if (result != null) {
                                          setState(() {
                                            _pickedFile = result.files.first;
                                            _fileName = result.files.first.name;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.upload_file),
                                      label: Text(
                                        'Upload File',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2E6F40),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: GoogleFonts.poppins()),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _postJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6F40),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                              : Text(
                                  'Post Job',
                                  style: GoogleFonts.poppins(),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Container(
      color: const Color(0xFFF5F7F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            color: Colors.white,
            child: Text(
              "Job Postings",
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Your Job Postings',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E6F40),
                        ),
                      ),
                      if (isDesktop || isTablet)
                        ElevatedButton.icon(
                          onPressed: _showPostJobDialog,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Post a Job',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E6F40),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search jobs...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                hintStyle: GoogleFonts.poppins(),
                              ),
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'active',
                                label: Text(
                                  'Active',
                                  style: GoogleFonts.poppins(),
                                ),
                                icon: const Icon(Icons.work),
                              ),
                              ButtonSegment(
                                value: 'completed',
                                label: Text(
                                  'Completed',
                                  style: GoogleFonts.poppins(),
                                ),
                                icon: const Icon(Icons.check_circle),
                              ),
                              ButtonSegment(
                                value: 'all',
                                label: Text(
                                  'All',
                                  style: GoogleFonts.poppins(),
                                ),
                                icon: const Icon(Icons.list),
                              ),
                            ],
                            selected: {_selectedView},
                            onSelectionChanged: (Set<String> selection) {
                              setState(() {
                                _selectedView = selection.first;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _postedJobs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.work_off,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No jobs posted yet',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start by posting your first job',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (!isDesktop && !isTablet)
                                      ElevatedButton.icon(
                                        onPressed: _showPostJobDialog,
                                        icon: const Icon(Icons.add),
                                        label: Text(
                                          'Post a Job',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF2E6F40),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _postedJobs.length,
                                itemBuilder: (context, index) {
                                  final job = _postedJobs[index];
                                  return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE8F5E9),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.work,
                                                  color: Color(0xFF2E6F40),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      job['work_name'] ??
                                                          'Unnamed Job',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      job['work_details'] ??
                                                          'No details',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFE8F5E9),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            _workTypes
                                                                    .firstWhere(
                                                              (type) =>
                                                                  type[
                                                                      'worktype_id'] ==
                                                                  job['worktype_id'],
                                                              orElse: () => {
                                                                'worktype_name':
                                                                    'Unknown'
                                                              },
                                                            )['worktype_name']
                                                                as String,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 12,
                                                              color: const Color(
                                                                  0xFF2E6F40),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        if (job['deadline'] !=
                                                            null) ...[
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[50],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  size: 12,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  job['deadline'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '\$${job['work_amount'] ?? 0}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                          0xFF2E6F40),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Text(
                                                  //   _getTimeAgo(
                                                  //       job['created_at']),
                                                  //   style: GoogleFonts.poppins(
                                                  //     fontSize: 12,
                                                  //     color: Colors.grey[600],
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (job['work_file'] != null)
                                                TextButton.icon(
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Opening file: ${job['work_file']}')));
                                                    // TODO: Implement file download (e.g., url_launcher)
                                                  },
                                                  icon: const Icon(
                                                      Icons.attach_file),
                                                  label: Text(
                                                    'View Attachment',
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                )
                                              else
                                                const SizedBox(),
                                              Row(
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      // TODO: Implement edit job
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Edit job not implemented')));
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    label: Text(
                                                      'Edit',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.blue,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  OutlinedButton.icon(
                                                    onPressed: () => _deleteJob(
                                                        job['work_id'], index),
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    label: Text(
                                                      'Delete',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
          if (!isDesktop && !isTablet && _postedJobs.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: _showPostJobDialog,
                backgroundColor: const Color(0xFF2E6F40),
                icon: const Icon(Icons.add),
                label: Text(
                  'Post a Job',
                  style: GoogleFonts.poppins(),
                ),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }
}
