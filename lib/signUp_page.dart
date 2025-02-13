import 'package:flutter/material.dart';

class signUp_page extends StatelessWidget {
  const signUp_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Light Blue Header with Title
          Container(
            width: double.infinity,
            color: Colors.blue[100],
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'SIGN UP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Logo
                  Image.asset(
                    'assets/images/ship_logo.jpg', // Replace with your logo path
                    width: 200,
                    height: 200,
                  ),
                  SizedBox(height: 5),
                  // App name
                  Text(
                    'Student Engagement App',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Input Fields
                  _buildInputField(
                    title: 'Student Name',
                    hintText: 'e.g., John Doe',
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    title: 'Student ID',
                    hintText: 'e.g., S12345678',
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    title: 'Student Phone Number',
                    hintText: 'e.g., 012-3456789',
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    title: 'Student Email Address',
                    hintText: 'e.g., john.doe@email.com',
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    title: 'Password',
                    hintText: '********',
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  // Sign Up Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to main.dart
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Bottom Text: Already have an account?
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // Navigate back to main.dart
                          },
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
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
    );
  }

  // Helper Widget for Input Fields
  Widget _buildInputField({
    required String title,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey), // Gray underline
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue), // Blue underline
              ),
            ),
          ),
        ],
      ),
    );
  }
}
