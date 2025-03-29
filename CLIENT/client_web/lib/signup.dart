import 'dart:ui';
import 'package:client_web/login.dart';
import 'package:client_web/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ClientSignup extends StatefulWidget {
  const ClientSignup({super.key});

  @override
  State<ClientSignup> createState() => _ClientSignupState();
}

class _ClientSignupState extends State<ClientSignup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Uint8List? _profileImageBytes;
  String? _fileName;
  bool isLoading = false;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Ensures bytes are included (required for web)
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _profileImageBytes = result.files.first.bytes;
          _fileName = result.files.first.name;
          print(
              "Image selected: $_fileName, bytes length: ${_profileImageBytes?.length ?? 0}");
        });

        // Verify the image data
        if (_profileImageBytes == null || _profileImageBytes!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selected image data is empty")),
          );
        }
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_profileImageBytes == null || _fileName == null) return null;

    try {
      final filePath =
          'profile_pics/$uid/${DateTime.now().millisecondsSinceEpoch}_$_fileName';
      await supabase.storage.from('photo').uploadBinary(
            filePath,
            _profileImageBytes!,
          );

      final String publicUrl =
          supabase.storage.from('photo').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final auth = await supabase.auth.signUp(
        password: _passwordController.text,
        email: _emailController.text,
      );
      String uid = auth.user!.id;
      await submit(uid);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submit(String uid) async {
    try {
      String? imageUrl = await _uploadImage(uid);

      await supabase.from('tbl_client').insert({
        'client_id': uid,
        'client_name': _nameController.text,
        'client_email': _emailController.text,
        'client_contact': _contactController.text,
        'client_password': _passwordController.text,
        if (imageUrl != null) 'client_photo': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Color.fromARGB(255, 86, 1, 1),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/signupbg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Color(0xFF0D3B1D).withOpacity(0.6),
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Color(0xFFA6C39F).withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/newlogo.png", height: 60),
                    SizedBox(height: 10),
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageBytes != null
                            ? MemoryImage(_profileImageBytes!)
                            : null,
                        child: _profileImageBytes == null
                            ? const Icon(Icons.camera_alt, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              labelText: "Name",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFDFFFD6))),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFDFFFD6))),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextField(
                          controller: _contactController,
                          decoration: InputDecoration(
                              labelText: "Contact",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFDFFFD6))),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFDFFFD6))),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "Confirm Password",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFFDFFFD6))),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Text('Already have an account')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
