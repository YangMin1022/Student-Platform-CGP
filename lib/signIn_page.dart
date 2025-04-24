import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signUp_page.dart';
import 'events_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for the required email domain
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
      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Retrieve user role from Firestore
      String uid = userCredential.user!.uid;
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(uid).get();

      if (!userDoc.exists) {
        throw Exception("User record not found");
      }
      String role = userDoc.get('role') as String;

      // Navigate to EventsPage, passing the isAdmin flag
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => EventsPage(role: role)),
          (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in error: ${e.message}")),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500)),
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
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
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
                child: Text('SIGN IN', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset('assets/images/ship_logo.jpg', width: 200, height: 200),
                    SizedBox(height: 5),
                    Text('Student Engagement App', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 40),
                    //Email
                    _buildInputField(
                      title: 'Student Email Address',
                      hintText: 'Peninsula school email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    //Password
                    _buildInputField(
                      title: 'Password',
                      hintText: 'eg: ********',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('SIGN IN',style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // at the bottom of your Column in build():
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?", style: TextStyle(fontSize: 18)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => SignUpPage()),
                                  );
                                },
                                child: Text('Sign Up', style: TextStyle(fontSize: 18, decoration: TextDecoration.underline, color: Colors.blue)),
                              ),
                            ],
                          ),
                          // ←–– New guest link below
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventsPage(role: 'guest')),
                                  (route) => false,
                              );
                            },
                            child: Text('Continue as Guest', style: TextStyle(fontSize: 16, decoration: TextDecoration.underline, color: Colors.grey[700]),
                            ),
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
