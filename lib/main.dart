import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signIn_page.dart';
import 'admin_page.dart';
import 'signup_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Engagement App',
      debugShowCheckedModeBanner: false,
      home: SignInPage(),
      routes: {
        '/signin': (context) => const SignInPage(),
        '/admin': (context) => AdminPage(),   
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
