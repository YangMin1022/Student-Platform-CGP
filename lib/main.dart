// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signIn_page.dart';
import 'signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Engagement App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // SplashScreen is now the initial page
      routes: {
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0), // Swipe the whole page up
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().whenComplete(() {
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Splash Screen Content
        GestureDetector(
          onTap: _handleTap,
          child: Scaffold(
            backgroundColor:
                Colors.white, // Or any color you prefer for the splash screen
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/the_shipcampus_logo.jpg',
                    height: 500, // Increased the height of the logo
                  ),
                ],
              ),
            ),
          ),
        ),
        // The Sign In Page (initially positioned below)
        SlideTransition(
          position: _offsetAnimation,
          child: FractionalTranslation(
            translation: const Offset(0.0, 1.0), // Start below the screen
            child: const SignInPage(),
          ),
        ),
      ],
    );
  }
}
