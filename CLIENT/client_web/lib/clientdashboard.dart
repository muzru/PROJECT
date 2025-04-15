import 'package:client_web/dispute.dart';
import 'package:client_web/login.dart';
import 'package:client_web/notifications.dart';
import 'package:client_web/profile.dart';
import 'package:client_web/proposal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _isMobile = screenWidth < 768;

    // Fetch logged-in client details
    final user = Supabase.instance.client.auth.currentUser;
    final clientName =
        user?.userMetadata?['name'] ?? user?.email?.split('@')[0] ?? 'Unknown';
    final clientEmail = user?.email ?? 'No email';

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
              const Text(
                'FreelanceHub',
                style: TextStyle(
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
              _buildNotificationBadge(),
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
            child: Builder(
              builder: (context) {
                return Container(
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
                );
              },
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
                : const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white70),
                  ),
            onTap: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  )); // Close the drawer
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    clientEmail,
                    style: TextStyle(
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
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Supabase.instance.client.auth.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    )); // Close the drawer
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
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                style: TextStyle(
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
          }, // Navigate to Notifications page
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
              "3",
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
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              clientEmail,
              style: TextStyle(
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

class DashboardHomePage extends StatelessWidget {
  const DashboardHomePage({super.key});

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
                const Text(
                  'Welcome back, John!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your projects today.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                isDesktop || isTablet
                    ? Row(
                        children: [
                          _buildStatCard(
                            '12',
                            'Active Jobs',
                            Icons.work,
                            Colors.white,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            '28',
                            'New Proposals',
                            Icons.description,
                            Colors.white,
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            '5',
                            'Messages',
                            Icons.message,
                            Colors.white,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildStatCard(
                            '12',
                            'Active Jobs',
                            Icons.work,
                            Colors.white,
                            isFullWidth: true,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            '28',
                            'New Proposals',
                            Icons.description,
                            Colors.white,
                            isFullWidth: true,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            '5',
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
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildRecentActivity(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildQuickActions(context),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
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
                    const Text(
                      'Your Recent Jobs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context
                          .findAncestorStateOfType<_ClientDashboardState>()
                          ?._onItemTapped(1),
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Color(0xFF2E6F40)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final jobs = [
                      {
                        'title': 'Website Redesign',
                        'proposals': '8 proposals',
                        'budget': '\$1,500',
                        'status': 'Active',
                        'statusColor': Colors.green,
                      },
                      {
                        'title': 'Mobile App Development',
                        'proposals': '12 proposals',
                        'budget': '\$3,000',
                        'status': 'Active',
                        'statusColor': Colors.green,
                      },
                      {
                        'title': 'Logo Design',
                        'proposals': '5 proposals',
                        'budget': '\$500',
                        'status': 'Completed',
                        'statusColor': Colors.blue,
                      },
                    ];
                    return null;
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
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

  Widget _buildRecentActivity() {
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
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'John Doe submitted a proposal for "Website Redesign"',
            '2 hours ago',
            Icons.description,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Payment of \$500 was processed for "Logo Design"',
            '1 day ago',
            Icons.payment,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'You posted a new job: "Mobile App Development"',
            '2 days ago',
            Icons.work,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Sarah Johnson completed "Content Writing" task',
            '3 days ago',
            Icons.check_circle,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title, String time, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'Post a New Job',
            'Create a job posting to find freelancers',
            Icons.add_circle,
            const Color(0xFF2E6F40),
            () => context
                .findAncestorStateOfType<_ClientDashboardState>()
                ?._onItemTapped(1),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'Browse Freelancers',
            'Find top talent for your projects',
            Icons.search,
            Colors.blue,
            () {},
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'View Messages',
            'Check your conversations with freelancers',
            Icons.message,
            Colors.orange,
            () => context
                .findAncestorStateOfType<_ClientDashboardState>()
                ?._onItemTapped(3),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'Manage Payments',
            'Review and process payments',
            Icons.payment,
            Colors.purple,
            () => context
                .findAncestorStateOfType<_ClientDashboardState>()
                ?._onItemTapped(7),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
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
      final response = await supabase.from('tbl_work').select();
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
          _postedJobs.add(newJob);
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
        title: const Text('Delete Job'),
        content:
            const Text('Are you sure you want to delete this job posting?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);
    try {
      await supabase.from('tbl_work').delete().eq('id', jobId);
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
                        const Text(
                          'Post a New Job',
                          style: TextStyle(
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
                                ),
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
                                ),
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
                                      ),
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
                                      ),
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
                                ),
                                items: _workTypes.map((type) {
                                  return DropdownMenuItem<int>(
                                    value: type['worktype_id'] as int,
                                    child:
                                        Text(type['worktype_name'] as String),
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
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            )
                                          : const Text('No file selected'),
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
                                      label: const Text('Upload File'),
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
                          child: const Text('Cancel'),
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
                              : const Text('Post Job'),
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
              style: TextStyle(
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
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E6F40),
                        ),
                      ),
                      if (isDesktop || isTablet)
                        ElevatedButton.icon(
                          onPressed: _showPostJobDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Post a Job'),
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
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'active',
                                label: Text('Active'),
                                icon: Icon(Icons.work),
                              ),
                              ButtonSegment(
                                value: 'completed',
                                label: Text('Completed'),
                                icon: Icon(Icons.check_circle),
                              ),
                              ButtonSegment(
                                value: 'all',
                                label: Text('All'),
                                icon: Icon(Icons.list),
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
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start by posting your first job',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (!isDesktop && !isTablet)
                                      ElevatedButton.icon(
                                        onPressed: _showPostJobDialog,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Post a Job'),
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
                                                      job['work_name'],
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      job['work_details'],
                                                      style: TextStyle(
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
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
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
                                                                  style:
                                                                      const TextStyle(
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
                                                    '\$${job['work_amount']}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2E6F40),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Posted 2 days ago',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
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
                                                    // Open file (e.g., launch URL)
                                                  },
                                                  icon: const Icon(
                                                      Icons.attach_file),
                                                  label: const Text(
                                                      'View Attachment'),
                                                )
                                              else
                                                const SizedBox(),
                                              Row(
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () {
                                                      // Edit job (TODO: implement)
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    label: const Text('Edit'),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.blue,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  OutlinedButton.icon(
                                                    onPressed: () => _deleteJob(
                                                        job['id'], index),
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    label: const Text('Delete'),
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
                label: const Text('Post a Job'),
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
