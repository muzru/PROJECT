import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'changepassword.dart'; // Import Change Password Page
import 'privacypolicy.dart'; // Import Privacy Policy Page
import 'terms.dart'; // Import Terms & Conditions Page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool("notifications") ?? true;
      _darkModeEnabled = prefs.getBool("dark_mode") ?? false;
    });
  }

  // Save preferences
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Color(0xFF2E6F40), // Dark Green
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingsOption(
              "Notifications",
              Icons.notifications,
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: Color(0xFF68BA7F), // Medium Green
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSetting("notifications", value);
                },
              ),
            ),
            _buildSettingsOption(
              "Dark Mode",
              Icons.dark_mode,
              trailing: Switch(
                value: _darkModeEnabled,
                activeColor: Color(0xFF68BA7F), // Medium Green
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  _saveSetting("dark_mode", value);
                },
              ),
            ),
            _buildSettingsOption("Change Password", Icons.lock, onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordPage()));
            }),
            _buildSettingsOption("Privacy Policy", Icons.privacy_tip,
                onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
            }),
            _buildSettingsOption("Terms & Conditions", Icons.article,
                onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TermsPage()));
            }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ✅ Settings Option Card
  Widget _buildSettingsOption(String title, IconData icon,
      {Widget? trailing, VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      color: Color(0xFFCFFFD6), // Light Mint Green
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF2E6F40)), // Dark Green
        title: Text(title,
            style: TextStyle(color: Color(0xFF253D2C))), // Darkest Green
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF253D2C)),
        onTap: onTap,
      ),
    );
  }
}
