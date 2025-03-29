import 'package:flutter/material.dart';
import 'package:freelancer_app/addskills.dart';
import 'package:freelancer_app/helpandsupport.dart';
import 'package:freelancer_app/homepage.dart';
import 'package:freelancer_app/joblisting.dart';
import 'package:freelancer_app/profile.dart';
import 'package:freelancer_app/projectsubmission.dart';
import 'package:freelancer_app/proposals.dart';
import 'package:freelancer_app/earningsandtransaction.dart';
import 'package:freelancer_app/reviews.dart';
import 'package:freelancer_app/settings.dart';
import 'package:freelancer_app/notifications.dart';
import 'package:freelancer_app/disputeresolution.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    JobListingPage(),
    ProposalsPage(),
    Center(child: Text('Messages', style: TextStyle(fontSize: 24))),
    ProfilePage(),
    AddSkillsPage(),
    ProjectSubmissionPage(),
    EarningsPage(),
    ReviewsPage(),
    SettingsPage(),
    HelpSupportPage(),
    NotificationsPage(),
    DisputeResolutionPage(),
  ];

  final List<String> _pageTitles = [
    "Home",
    "Job Listings",
    "Proposals",
    "Messages",
    "Profile",
    "Add Skills",
    "Project Submission",
    "Earnings & Transactions",
    "Reviews & Ratings",
    "Settings",
    "Help and Support",
    "Notifications",
    "Dispute Resolution",
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Color(0xFF2E6F40),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _onItemTapped(11);
            },
          ),
          IconButton(
            icon: Icon(Icons.gavel),
            onPressed: () {
              _onItemTapped(12);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2E6F40),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/newlogo.png",
                    height: 80,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Freelancer Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                _onItemTapped(11);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.gavel),
              title: Text('Dispute Resolution'),
              onTap: () {
                _onItemTapped(12);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.stacked_line_chart_outlined),
              title: Text('Add Skills'),
              onTap: () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Submit Project'),
              onTap: () {
                _onItemTapped(6);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Earnings & Transactions'),
              onTap: () {
                _onItemTapped(7);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Reviews & Ratings'),
              onTap: () {
                _onItemTapped(8);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                _onItemTapped(9);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                _onItemTapped(10);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projects'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Proposals'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex >= 5 ? 0 : _selectedIndex,
        selectedItemColor: Color(0xFF68BA7F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index < 5) {
            _onItemTapped(index);
          }
        },
      ),
      backgroundColor: Color(0xFFCFFFD6),
    );
  }
}
