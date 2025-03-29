import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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
                color: Color(0xFF0D3B1D).withOpacity(0.6), // Dark Green tint
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Color(0xFFA6C39F).withOpacity(0.95), // Greenish Beige
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
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Icon(Icons.camera_alt, color: Colors.white)
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
                              fillColor: Color(0xFFDFFFD6))), // Light Green
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
                              fillColor: Color(0xFFDFFFD6))), // Light Green
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
                              fillColor: Color(0xFFDFFFD6))), // Light Green
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
                              fillColor: Color(0xFFDFFFD6))), // Light Green
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
                              fillColor: Color(0xFFDFFFD6))), // Light Green
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          print(
                              "Signup with: ${_nameController.text}, ${_emailController.text}, ${_contactController.text}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32), // Forest Green
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
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
