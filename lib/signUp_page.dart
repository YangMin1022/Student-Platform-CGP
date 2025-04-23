import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'events_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  // Determine user role based on email
  String _determineRole(String email) {
    if (email.toLowerCase() == "admin@peninsulamalaysia.edu.my") {
      return "admin";
    } else {
      return "student";
    }
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if the email ends with the required domain
    if (!emailController.text.toLowerCase().endsWith("@peninsulamalaysia.edu.my")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please use your Peninsula school email.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String role = _determineRole(emailController.text.trim());

      // Save additional user info in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text.trim(),
        "studentId": studentIdController.text.trim(),
        "phone": phoneController.text.trim(),
        "email": emailController.text.trim(),
        "role": role,
      });

      // bool isAdmin;
      String roles;
      if (role == "admin") {
        roles = "admin";
      } else {
        roles = "student";
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => EventsPage(role: roles)),
          (route) => false, // drop everything else in the stack
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up error: ${e.message}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInputField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    // bool obscureText = false,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500)),
          SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            keyboardType: keyboardType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter $title";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              // only show the eye icon on the password field:
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              color: Colors.blue[100],
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('SIGN UP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    // Logo
                    Image.asset('assets/images/ship_logo.jpg', width: 200, height: 200),
                    SizedBox(height: 5),
                    // App name
                    Text('Student Engagement App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 30),
                    // Input fields
                    _buildInputField(title: 'Student Name', hintText: 'e.g., John Doe', controller: nameController),
                    _buildInputField(title: 'Student ID', hintText: 'e.g., S12345678', controller: studentIdController),
                    _buildInputField(title: 'Student Phone Number', hintText: 'e.g., 012-3456789', controller: phoneController, keyboardType: TextInputType.phone),
                    _buildInputField(title: 'Student Email Address', hintText: 'e.g., john.doe@peninsulamalaysia.edu.my', controller: emailController, keyboardType: TextInputType.emailAddress),
                    _buildInputField(title: 'Password', hintText: '********', controller: passwordController, isPassword: true,),
                    SizedBox(height: 30),
                    // Sign Up button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('SIGN UP', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Bottom text: Already have an account?
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account?', style: TextStyle(fontSize: 18)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Sign In', style: TextStyle(fontSize: 18, decoration: TextDecoration.underline, color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
