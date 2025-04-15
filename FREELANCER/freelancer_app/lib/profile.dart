import 'package:flutter/material.dart';
import 'package:freelancer_app/disputeresolution.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ProfilePage
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String? _profileImageUrl;
  final picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();

  List<int> _selectedSkillIds = [];
  List<Map<String, dynamic>> _availableSkills = [];
  bool _isEditing = false;
  bool _isLoading = false;
  String? _freelancerId;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      setState(() => _isLoading = true);
      final user = _supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final freelancerResponse = await _supabase
          .from('tbl_freelancer')
          .select()
          .eq('freelancer_email', user.email!)
          .maybeSingle();

      if (freelancerResponse != null) {
        setState(() {
          _freelancerId = freelancerResponse['freelancer_id'];
          _nameController.text = freelancerResponse['freelancer_name'] ?? '';
          _contactController.text =
              freelancerResponse['freelancer_contact'] ?? '';
          _emailController.text = freelancerResponse['freelancer_email'] ?? '';
          _portfolioController.text = '';
          _profileImageUrl = freelancerResponse['freelancer_photo'];
        });
      }

      final userSkillsResponse = await _supabase
          .from('tbl_userskill')
          .select('technicalskill_id')
          .eq('freelancer_id', _freelancerId ?? '');

      setState(() {
        _selectedSkillIds = userSkillsResponse
            .map<int>((skill) => skill['technicalskill_id'] as int)
            .toList();
      });

      final technicalSkillsResponse =
          await _supabase.from('tbl_technicalskill').select();

      setState(() {
        _availableSkills = technicalSkillsResponse;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_profileImage == null || _freelancerId == null) return null;

    try {
      final fileName = 'userphoto_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('photo').upload(fileName, _profileImage!);
      final publicUrl = _supabase.storage.from('photo').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_freelancerId == null) return;

    try {
      setState(() => _isLoading = true);

      final newPhotoUrl = await _uploadImage();

      final updates = {
        'freelancer_name': _nameController.text.trim(),
        'freelancer_contact': _contactController.text.trim(),
        if (newPhotoUrl != null) 'freelancer_photo': newPhotoUrl,
      };

      await _supabase
          .from('tbl_freelancer')
          .update(updates)
          .eq('freelancer_id', _freelancerId!);

      await _supabase
          .from('tbl_userskill')
          .delete()
          .eq('freelancer_id', _freelancerId!);

      final newSkills = _selectedSkillIds
          .map((skillId) => {
                'freelancer_id': _freelancerId,
                'technicalskill_id': skillId,
                'created_at': DateTime.now().toIso8601String(),
              })
          .toList();

      if (newSkills.isNotEmpty) {
        await _supabase.from('tbl_userskill').insert(newSkills);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _profileImageUrl = newPhotoUrl ?? _profileImageUrl;
        _profileImage = null;
      });
      _toggleEditMode();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _navigateToDispute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DisputeResolutionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Freelancer Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const AssetImage(
                                          'assets/default_profile.png')
                                      as ImageProvider,
                          child: _isEditing && _profileImage == null
                              ? const Icon(Icons.camera_alt,
                                  size: 40, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                                'Name', _nameController.text, _isEditing),
                            _buildDetailRow(
                                'Contact', _contactController.text, _isEditing),
                            _buildDetailRow(
                                'Email', _emailController.text, false),
                            _buildDetailRow('Portfolio',
                                _portfolioController.text, _isEditing),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skills',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _isEditing
                                ? Wrap(
                                    spacing: 8.0,
                                    children: _availableSkills.map((skill) {
                                      final isSelected = _selectedSkillIds
                                          .contains(skill['technicalskill_id']);
                                      return ChoiceChip(
                                        label:
                                            Text(skill['technicalskill_name']),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedSkillIds.add(
                                                  skill['technicalskill_id']);
                                            } else {
                                              _selectedSkillIds.remove(
                                                  skill['technicalskill_id']);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  )
                                : Text(
                                    _selectedSkillIds.isEmpty
                                        ? 'No skills selected'
                                        : _availableSkills
                                            .where((skill) =>
                                                _selectedSkillIds.contains(
                                                    skill['technicalskill_id']))
                                            .map((skill) =>
                                                skill['technicalskill_name'])
                                            .join(', '),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _isEditing ? _saveProfile : _toggleEditMode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Save' : 'Edit Profile',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600]!,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Change Password',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _navigateToDispute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF68BA7F), // Medium Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Report a Dispute',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          isEditing && label != 'Email'
              ? SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _getController(label),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
              : SizedBox(
                  width: 200,
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
        ],
      ),
    );
  }

  TextEditingController _getController(String label) {
    switch (label) {
      case 'Name':
        return _nameController;
      case 'Contact':
        return _contactController;
      case 'Email':
        return _emailController;
      case 'Portfolio':
        return _portfolioController;
      default:
        return _nameController;
    }
  }
}

// ChangePasswordPage (unchanged)
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Re-authenticate with old password
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );

      // Update password
      await _supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );
      await _supabase
          .from("tbl_freelancer")
          .update({'freelancer_password': _newPasswordController.text});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to ProfilePage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
          'Change Password',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Password',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _oldPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Old Password',
                                  border: const OutlineInputBorder(),
                                  labelStyle: GoogleFonts.poppins(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your old password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  border: const OutlineInputBorder(),
                                  labelStyle: GoogleFonts.poppins(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a new password';
                                  }
                                  if (value.trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm New Password',
                                  border: const OutlineInputBorder(),
                                  labelStyle: GoogleFonts.poppins(),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your new password';
                                  }
                                  if (value.trim() !=
                                      _newPasswordController.text.trim()) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Update Password',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
