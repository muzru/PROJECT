import 'package:flutter/material.dart';
import 'package:freelancer_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isLoaded = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, String>> jobs = [];
  String? _userName;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoaded = true;
      });
      _loadJobListings();
    });
  }

  Future<void> _fetchUserData() async {
    try {
      // Get the current authenticated user
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      // Fetch user data from tbl_client
      final response = await supabase
          .from('tbl_freelancer')
          .select('freelancer_name, freelancer_photo')
          .eq('freelancer_id', user.id)
          .single();
      print("User data: $response");

      setState(() {
        _userName = (response['freelancer_name'] as String?)
            ?.trim() // Remove leading/trailing spaces
            .split(RegExp(r'\s+')) // Split on any whitespace
            .first;

        _profileImageUrl = response['freelancer_photo'];
        print("Profile Image URL: $_profileImageUrl");
        print(_userName);
      });
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  void _loadJobListings() {
    List<Map<String, String>> newJobs = [
      {"title": "Flutter Developer Needed", "price": "\$500"},
      {"title": "Logo Design for Startup", "price": "\$150"},
      {"title": "SEO Content Writer", "price": "\$200"},
    ];

    Future.forEach(newJobs, (job) async {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        jobs.add(job);
        _listKey.currentState?.insertItem(jobs.length - 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: _isLoaded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: _buildWelcomeBanner(),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, _isLoaded ? 0 : 50, 0),
              child: _buildCategoryGrid(),
            ),
            const SizedBox(height: 20),
            _buildRecommendedJobs(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  /// Welcome Banner with Dynamic User Data
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E6F40),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : const AssetImage("assets/newlogo.png") as ImageProvider,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back, ${_userName ?? 'User'}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Explore new projects & earn more!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Categories Grid
  Widget _buildCategoryGrid() {
    List<Map<String, dynamic>> categories = [
      {"title": "Web Dev", "icon": Icons.web},
      {"title": "Graphic Design", "icon": Icons.brush},
      {"title": "Writing", "icon": Icons.edit},
      {"title": "Marketing", "icon": Icons.campaign},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 100)),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isLoaded ? 0 : 30, 0),
          child: Card(
            color: const Color(0xFF68BA7F),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categories[index]["icon"], color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    categories[index]["title"],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Recommended Jobs
  Widget _buildRecommendedJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended Jobs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: jobs.length,
          itemBuilder: (context, index, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: const Offset(0, 0),
              ).animate(animation),
              child: Card(
                elevation: 2,
                child: ListTile(
                  title: Text(jobs[index]["title"]!),
                  trailing: Text(
                    jobs[index]["price"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E6F40),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Quick Actions
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send),
          label: const Text("Submit Proposal"),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6F40)),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.wallet),
          label: const Text("View Earnings"),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E6F40)),
        ),
      ],
    );
  }
}
