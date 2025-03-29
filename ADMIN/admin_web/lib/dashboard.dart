import 'package:admin_web/dispute.dart';
import 'package:admin_web/payments.dart';
import 'package:admin_web/reports.dart';
import 'package:flutter/material.dart';
import 'manage_freelancers.dart';
import 'manage_clients.dart';
import 'manage_skills.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<Map<String, int>> fetchDashboardStats() async {
    await Future.delayed(Duration(seconds: 2));
    return {
      "Total Users": 120,
      "Pending Disputes": 5,
      "Total Earnings": 15000,
    };
  }

  String selectedUserType = "Freelancers";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Color(0xFF2E6F40),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: fetchDashboardStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var stats = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Overview",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2,
                    ),
                    itemCount: stats.length,
                    itemBuilder: (context, index) {
                      String key = stats.keys.elementAt(index);
                      int value = stats[key]!;
                      return Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(key,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(value.toString(),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.green)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
                  Icon(Icons.admin_panel_settings,
                      size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text('Admin Panel',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Manage Users",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: selectedUserType,
                icon: Icon(Icons.arrow_drop_down),
                isExpanded: true,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedUserType = newValue;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              selectedUserType == "Freelancers"
                                  ? ManageFreelancersPage()
                                  : ManageClientsPage(),
                        ),
                      );
                    });
                  }
                },
                items: ["Freelancers", "Clients"]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            _buildDrawerItem(
                Icons.build, "Manage Skills", context, ManageSkillsPage()),
            _buildDrawerItem(Icons.money, "Payments", context, PaymentsPage()),
            _buildDrawerItem(Icons.report, "Disputes", context, DisputesPage()),
            _buildDrawerItem(
                Icons.analytics, "Reports", context, ReportsPage()),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon, String title, BuildContext context, Widget? page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}
