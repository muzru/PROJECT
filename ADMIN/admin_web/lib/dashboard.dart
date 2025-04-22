import 'package:flutter/material.dart';
import 'package:freelancer_app/dashboardcard.dart';
import 'package:freelancer_app/dispute.dart';
import 'package:freelancer_app/login.dart';
import 'package:freelancer_app/manage_clients.dart';
import 'package:freelancer_app/manage_freelancers.dart';
import 'package:freelancer_app/manage_skills.dart';
import 'package:freelancer_app/manageworktype.dart';
import 'package:freelancer_app/reports.dart';
import 'package:freelancer_app/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  String? _adminName;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
    _fetchAdminName();
  }

  void _initializePages() {
    _pages.clear();
    _pages.addAll([
      _buildDashboardContent(),
      const ManageFreelancersPage(),
      const ManageClientsPage(),
      const ManageSkillsPage(),
      const ManageWorkTypesPage(),
      const DisputesPage(),
      const ReportsPage(),
    ]);
  }

  Future<void> _fetchAdminName() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('tbl_admin')
            .select('admin_name')
            .eq('admin_id', user.id)
            .maybeSingle();
        if (response != null) {
          setState(() {
            _adminName = response['admin_name'] ?? 'Admin';
          });
        }
      }
    } catch (e) {
      print('Error fetching admin name: $e');
      setState(() {
        _adminName = 'Admin';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 7) {
      _logout();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isSidebarExpanded ? 250 : 70,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      color: const Color(0xFF2E6F40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.admin_panel_settings,
                                size: 40, color: Colors.white),
                            if (_isSidebarExpanded)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Admin Panel',
                                    style: TextStyle(color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          SidebarItem(
                              icon: Icons.dashboard,
                              title: 'Dashboard',
                              isSelected: _selectedIndex == 0,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(0)),
                          SidebarItem(
                              icon: Icons.people,
                              title: 'Freelancers',
                              isSelected: _selectedIndex == 1,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(1)),
                          SidebarItem(
                              icon: Icons.business,
                              title: 'Clients',
                              isSelected: _selectedIndex == 2,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(2)),
                          SidebarItem(
                              icon: Icons.build,
                              title: 'Skills',
                              isSelected: _selectedIndex == 3,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(3)),
                          SidebarItem(
                              icon: Icons.work,
                              title: 'Work Types',
                              isSelected: _selectedIndex == 4,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(4)),
                          SidebarItem(
                              icon: Icons.warning,
                              title: 'Disputes',
                              isSelected: _selectedIndex == 5,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(5),
                              badgeCount: 0),
                          SidebarItem(
                              icon: Icons.analytics,
                              title: 'Reports',
                              isSelected: _selectedIndex == 6,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(6)),
                          const Divider(height: 32),
                          SidebarItem(
                              icon: Icons.logout,
                              title: 'Logout',
                              isSelected: false,
                              isExpanded: _isSidebarExpanded,
                              onTap: () => _onItemTapped(7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1)),
                    ]),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              _isSidebarExpanded = !_isSidebarExpanded;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _getPageTitle(),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(
                                  () {}); // Trigger rebuild to refresh counts
                            }),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              _adminName ?? 'Loading...',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              backgroundColor: Color(0xFF2E6F40),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade50,
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard Overview';
      case 1:
        return 'Manage Freelancers';
      case 2:
        return 'Manage Clients';
      case 3:
        return 'Manage Skills';
      case 4:
        return 'Manage Work Types';
      case 5:
        return 'Disputes';
      case 6:
        return 'Reports';
      default:
        return 'Admin Dashboard';
    }
  }

  Future<Map<String, int>> _fetchStats() async {
    try {
      final freelancersCount = await supabase.from('tbl_freelancer').count();
      final clientsCount = await supabase.from('tbl_client').count();
      final worksCount = await supabase.from('tbl_work').count();

      return {
        "Total Freelancers": freelancersCount,
        "Total Clients": clientsCount,
        "Total Works": worksCount,
      };
    } catch (e) {
      print('Error fetching stats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching stats: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return {
        "Total Freelancers": 0,
        "Total Clients": 0,
        "Total Works": 0,
      };
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Map<String, int>>(
            future: _fetchStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading stats'));
              }
              final stats = snapshot.data ??
                  {
                    "Total Freelancers": 0,
                    "Total Clients": 0,
                    "Total Works": 0,
                  };
              return GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.5,
                children: [
                  DashboardStatsCard(
                    key: ValueKey(stats['Total Freelancers']),
                    title: 'Total Freelancers',
                    value: stats['Total Freelancers']!,
                    icon: Icons.people,
                    color: Colors.blue,
                    showTrend: true,
                    isIncreasing: true,
                    trendValue: '+12%',
                  ),
                  DashboardStatsCard(
                    key: ValueKey(stats['Total Clients']),
                    title: 'Total Clients',
                    value: stats['Total Clients']!,
                    icon: Icons.business,
                    color: Colors.green,
                    showTrend: true,
                    isIncreasing: true,
                    trendValue: '+8%',
                  ),
                  DashboardStatsCard(
                    key: ValueKey(stats['Total Works']),
                    title: 'Total Works',
                    value: stats['Total Works']!,
                    icon: Icons.work,
                    color: Colors.orange,
                    showTrend: false,
                    isIncreasing: false,
                    trendValue: '-3%',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text('Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _onItemTapped(4),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_circle,
                                color: Colors.purple, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('Add Work Type',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Create new work categories',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _onItemTapped(3),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.build,
                                color: Colors.blue, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('Manage Skills',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Add or update freelancer skills',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _onItemTapped(6),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.analytics,
                                color: Colors.orange, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('View Reports',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Access system-wide reports',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
