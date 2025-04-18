// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // For the circle animation

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
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    _circleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    _zoomController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _circleController.forward().whenComplete(() {
          Navigator.pushReplacementNamed(context, '/signin');
        });
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _circleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_animationStarted) {
      setState(() {
        _animationStarted = true;
      });
      _zoomController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red, Colors.blue],
                ),
              ),
            ),
          ),
          // Logo Zoom
          Center(
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    child: Opacity(
                      opacity: _animationStarted
                          ? 1.0 - _circleAnimation.value
                          : 1.0,
                      child: Container(
                        width: 400, // Adjust initial logo size
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(
                              (0.8 * 255).toInt()), // Corrected opacity
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/the_shipcampus_logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Circular Reveal
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              double radius = MediaQuery.of(context).size.width *
                  _circleAnimation.value *
                  1.2; // Expand to cover the screen
              return Center(
                child: ClipPath(
                  clipper: CircleClipper(radius),
                  child: Container(
                    color: Colors
                        .white, // The color of your sign-in page background
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: _circleAnimation.value,
                      child: const SignInPage(), // Your sign-in page
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double radius;
  CircleClipper(this.radius);

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // Reclip on every animation frame
  }
}
