import 'package:flutter/material.dart';
import 'package:freelancer_app/activityitem.dart';
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
  Map<String, int> _stats = {};

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
    _initializePages();
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

  Future<void> _fetchDashboardStats() async {
    try {
      final freelancersResponse =
          await supabase.from('tbl_freelancer').select('freelancer_id');
      final clientsResponse =
          await supabase.from('tbl_client').select('client_id');
      final worksResponse = await supabase.from('tbl_work').select('work_id');
      final notificationsResponse =
          await supabase.from('tbl_complaint').select('id');

      if (mounted) {
        setState(() {
          _stats = {
            "Total Freelancers": freelancersResponse.length,
            "Total Clients": clientsResponse.length,
            "Total Works": worksResponse.length,
            "Active Notifications": notificationsResponse.length,
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching stats: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            // Sidebar
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
                              badgeCount: _stats["Active Notifications"]),
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
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // App bar
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
                            onPressed: _fetchDashboardStats),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Badge(
                            label:
                                Text(_stats['Active Notifications'].toString()),
                            isLabelVisible: _stats['Active Notifications']! > 0,
                            child: const Icon(Icons.notifications),
                          ),
                          onPressed: () => _onItemTapped(5),
                        ),
                        const SizedBox(width: 16),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF2E6F40),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Content
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

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              DashboardStatsCard(
                title: 'Total Freelancers',
                value: _stats['Total Freelancers'] ?? 0,
                icon: Icons.people,
                color: Colors.blue,
                showTrend: true,
                isIncreasing: true,
                trendValue: '+12%',
              ),
              DashboardStatsCard(
                title: 'Total Clients',
                value: _stats['Total Clients'] ?? 0,
                icon: Icons.business,
                color: Colors.green,
                showTrend: true,
                isIncreasing: true,
                trendValue: '+8%',
              ),
              DashboardStatsCard(
                title: 'Total Works',
                value: _stats['Total Works'] ?? 0,
                icon: Icons.work,
                color: Colors.orange,
                showTrend: false,
                isIncreasing: false,
                trendValue: '-3%',
              ),
              DashboardStatsCard(
                title: 'Active Notifications',
                value: _stats['Active Notifications'] ?? 0,
                icon: Icons.notifications,
                color: Colors.red,
                showTrend: false,
              ),
            ],
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
