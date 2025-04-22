import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freelancer_app/joblisting.dart';
import 'package:freelancer_app/login.dart';
import 'package:freelancer_app/myrequest.dart';
import 'package:freelancer_app/profile.dart';
import 'package:freelancer_app/workdetails.dart';
import 'package:freelancer_app/notifications.dart'; // New import
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  String? _userName;
  String? _profileImageUrl;
  List<String> _userSkills = [];
  List<Map<String, dynamic>> _availableSkills = [];
  final List<Map<String, dynamic>> _selectedSkills = [];
  List<Map<String, dynamic>> _featuredJobs = [];
  List<Map<String, dynamic>> _recentJobs = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _freelancerStatus;
  final String _dailyTip = "Boost your profile by adding new skills today!";
  Timer? _autoReloadTimer; // Timer for auto-reload

  // Configurable status codes
  static const int statusAccepted = 1; // Work request accepted
  static const int statusRejected = 2; // Work request rejected
  static const int statusPaymentReceived = 5; // Payment received

  @override
  void initState() {
    super.initState();
    _loadData();
    // Start auto-reload every 30 seconds (adjust as needed)
    _autoReloadTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _autoReloadTimer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchUserData(),
        _fetchAvailableSkills(),
        _fetchJobs(),
        _fetchNotifications(),
      ]);
    } catch (e) {
      setState(() => _errorMessage = "Failed to load data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _userName = 'Guest');
        return;
      }

      final profileResponse = await supabase
          .from('tbl_freelancer')
          .select('freelancer_name, freelancer_photo, freelancer_status')
          .eq('freelancer_id', user.id)
          .single();

      final skillsResponse = await supabase
          .from('tbl_userskill')
          .select('technicalskill_id, tbl_technicalskill(technicalskill_name)')
          .eq('freelancer_id', user.id);

      setState(() {
        final fullName = profileResponse['freelancer_name'] as String?;
        _userName = fullName?.trim().isNotEmpty == true
            ? fullName!.trim().split(RegExp(r'\s+')).first
            : 'Freelancer';
        _profileImageUrl = profileResponse['freelancer_photo'] as String?;
        _freelancerStatus = profileResponse['freelancer_status'] as int? ?? 0;
        _userSkills = (skillsResponse as List)
            .map(
                (e) => e['tbl_technicalskill']['technicalskill_name'] as String)
            .toList();
      });
    } catch (e) {
      setState(() {
        _userName = 'Freelancer';
        _freelancerStatus = 0;
      });
      print("Error fetching user data: $e");
    }
  }

  Future<void> _fetchAvailableSkills() async {
    try {
      final response = await supabase
          .from('tbl_technicalskill')
          .select('technicalskill_id, technicalskill_name');
      setState(() {
        _availableSkills = (response as List)
            .map((e) => {
                  'id': e['technicalskill_id'] as int,
                  'name': e['technicalskill_name'] as String,
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching skills: $e");
    }
  }

  Future<void> _fetchJobs() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final featuredResponse = await supabase
          .from('tbl_work')
          .select('work_id, work_name, work_amount')
          .order('created_at', ascending: false)
          .limit(5);

      final recentResponse = await supabase
          .from('tbl_workrequest')
          .select('''
            work_id,
            tbl_work (work_name, work_amount)
          ''')
          .eq('freelancer_id', user.id)
          .order('created_at', ascending: false)
          .limit(4);

      setState(() {
        _featuredJobs = featuredResponse
            .map((job) => {
                  'work_id': job['work_id'],
                  'work_title': job['work_name'],
                  'work_amount': job['work_amount'],
                  'image_url': 'https://via.placeholder.com/300',
                })
            .toList();
        _recentJobs = recentResponse
            .map((request) => {
                  'work_id': request['work_id'],
                  'work_title': request['tbl_work']['work_name'],
                  'work_amount': request['tbl_work']['work_amount'],
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final user = supabase.auth.currentUser!.id;
      if (user == null) {
        print("No user logged in, skipping notification fetch.");
        setState(() => _notifications = []);
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
      print("Response type: ${workRequestResponse.runtimeType}");

      if (workRequestResponse.isEmpty) {
        print("No matching work requests found.");
        setState(() => _notifications = []);
        return;
      }

      setState(() {
        _notifications =
            List<Map<String, dynamic>>.from(workRequestResponse).map((req) {
          print("Processing request: $req");

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

        print("Processed notifications: $_notifications");
      });
    } catch (e, stackTrace) {
      print("Error fetching notifications: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        _errorMessage = "Failed to fetch notifications: $e";
        _notifications = [];
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

  Future<void> _addSelectedSkills() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null || _selectedSkills.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No skills selected or user not logged in"),
          ),
        );
        return;
      }

      final skillsToAdd = _selectedSkills
          .where((skill) => !_userSkills.contains(skill['name']))
          .toList();

      if (skillsToAdd.isNotEmpty) {
        await supabase.from('tbl_userskill').insert(
              skillsToAdd
                  .map((skill) => {
                        'freelancer_id': user.id,
                        'technicalskill_id': skill['id'],
                      })
                  .toList(),
            );

        await supabase
            .from('tbl_freelancer')
            .update({'freelancer_status': 1}).eq('freelancer_id', user.id);

        await _fetchUserData();
        setState(() => _selectedSkills.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Skills added successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No new skills selected")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding skills: $e")),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
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
          'Skill Connect',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : const AssetImage('assets/newlogo.png') as ImageProvider,
                backgroundColor: const Color(0xFF2E7D32).withOpacity(0.2),
              ),
            ),
          ),
          _buildNotificationBadge(),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2E7D32)),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Retry', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadData(); // Manual reload via pull-to-refresh
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildWelcomeBanner(),
                        const SizedBox(height: 16),
                        _buildQuickActions(context),
                        const SizedBox(height: 16),
                        _buildFeaturedCarousel(context),
                        const SizedBox(height: 16),
                        _buildDailyTipBanner(),
                        const SizedBox(height: 16),
                        if (_freelancerStatus == 0) ...[
                          _buildSkillsSection(),
                          const SizedBox(height: 16),
                        ],
                        _buildRecentJobsList(context),
                        const SizedBox(height: 16),
                        _buildAllJobsLink(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNotificationBadge() {
    final unreadCount = _notifications.length;
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xFF2E7D32)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FreelancerNotificationsPage(),
              ),
            );
          },
          tooltip: 'Notifications',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                unreadCount.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${_userName ?? 'Freelancer'}!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your next project today.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            context,
            'My Requests',
            Icons.list_alt,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRequestsPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Jobs',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _featuredJobs.isEmpty
              ? Center(
                  child: Text(
                    'No featured jobs available.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.25,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 9,
                  ),
                  items: _featuredJobs.map((job) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                job['image_url'] ??
                                    'https://via.placeholder.com/300',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/newlogo.png',
                                  fit: BoxFit.cover,
                                  color: Colors.grey.shade200,
                                  colorBlendMode: BlendMode.dstATop,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  job['work_title'] ?? 'Untitled Job',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${double.tryParse(job['work_amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkDetailsPage(
                                            workId: job['work_id']),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                    ),
                                    child: Text(
                                      'Apply Now',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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

  Widget _buildDailyTipBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _dailyTip,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Skills',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _availableSkills.isEmpty
                ? Center(
                    child: Text(
                      'No skills available.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSkills.map((skill) {
                      final isSelected =
                          _selectedSkills.any((s) => s['id'] == skill['id']);
                      return ChoiceChip(
                        label: Text(skill['name']),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2E7D32),
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills
                                  .removeWhere((s) => s['id'] == skill['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedSkills.isNotEmpty ? _addSelectedSkills : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add Selected Skills',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Works',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: _recentJobs.isEmpty
                ? Center(
                    child: Text(
                      'No recent works available.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recentJobs.length,
                    itemBuilder: (context, index) {
                      final job = _recentJobs[index];
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              job['work_title'] ?? 'Untitled Job',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${double.tryParse(job['work_amount']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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

  Widget _buildAllJobsLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllJobsPage()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore All Jobs',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
