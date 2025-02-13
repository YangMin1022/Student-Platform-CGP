import 'package:flutter/material.dart';
import 'package:flutter_application_1/signUp_page.dart';
import 'events_page.dart'; // Import the Events page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Engagement App',
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

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
                'SIGN IN',
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
                  SizedBox(height: 20), // Adjusted top spacing
                  // Logo
                  Image.asset(
                    'assets/images/ship_logo.jpg', // Replace with actual path to your logo
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
                  SizedBox(height: 40), // Adjusted spacing
                  // Student Email Address title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Student Email Address',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Student Email Address input field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'xxxxxxxxxxx@peninsulamalaysia.edu.my',
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // Gray underline
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.blue), // Blue underline when focused
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Password input field with lock icon
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'eg: ********',
                        hintStyle: TextStyle(color: Colors.grey),
                        suffixIcon: Icon(Icons.lock, color: Colors.black),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey), // Gray underline
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  Colors.blue), // Blue underline when focused
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Sign In button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EventsPage()), // Navigate to EventsPage
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Text
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            signUp_page(), // Navigate to Sign Up Page
                      ),
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      decoration:
                          TextDecoration.underline, // Underline the text
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
