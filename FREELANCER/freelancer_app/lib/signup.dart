import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:freelancer_app/login.dart';
import 'package:freelancer_app/main.dart';
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

  Future<void> register() async {
    try {
      final auth = await supabase.auth.signUp(
          password: _passwordController.text, email: _emailController.text);
      String uid = auth.user!.id;
      submit(uid);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> submit(String uid) async {
    setState(() {
      //isLoading = true;
    });
    try {
      await supabase.from('tbl_freelancer').insert({
        'freelancer_id': uid,
        'freelancer_name': _nameController.text,
        'freelancer_email': _emailController.text,
        'freelancer_contact': _contactController.text,
        'freelancer_password': _passwordController.text,
        'freelancer_photo': 'photoUrl',
      });

      String? photoUrl = await _uploadImage(uid);
      if (photoUrl != null) {
        update(photoUrl, uid);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Color.fromARGB(255, 86, 1, 1),
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        //isLoading = false;
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    try {
      if (_image == null) return null;
      final fileName = 'userphoto_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('photo').upload(fileName, _image!);

      final imageUrl = supabase.storage.from('photo').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> update(String image, String uid) async {
    try {
      await supabase.from('tbl_freelancer').update({
        'freelancer_photo': image,
      }).eq('freelancer_id', uid);
    } catch (e) {
      print("Error: $e");
    }
  }

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
                          register();
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
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: const Text("Have an account? Login"),
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
