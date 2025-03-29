import 'package:client_web/dispute.dart';
import 'package:client_web/jobpostings.dart';
import 'package:client_web/notifications.dart';
import 'package:client_web/profile.dart';
import 'package:client_web/proposal.dart';
import 'package:client_web/payments.dart';
import 'package:flutter/material.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});
  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    JobPostingPage(),
    ProposalsPage(
      onProposalAccepted: () {
        // Do something when a proposal is accepted
        print("A proposal has been accepted!");
      },
    ),
    Center(child: Text('Messages', style: TextStyle(fontSize: 24))),
    ClientProfilePage(),
    ClientNotificationsPage(),
    DisputeResolutionPage(),
    PaymentPage(),
  ];

  final List<String> _pageTitles = [
    "Home",
    "Job Posting",
    "Proposals",
    "Messages",
    "Profile",
    "Notifications",
    "Dispute Resolution",
    "Payments",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              _onItemTapped(5);
            },
          ),
          IconButton(
            icon: Icon(Icons.gavel),
            onPressed: () {
              _onItemTapped(6);
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
                  Icon(Icons.business, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Client Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Job Postings'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Proposals'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                _onItemTapped(5);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.gavel),
              title: Text('Dispute Resolution'),
              onTap: () {
                _onItemTapped(6);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payments'),
              onTap: () {
                _onItemTapped(7);
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
      backgroundColor: Color(0xFFCFFFD6),
    );
  }
}
