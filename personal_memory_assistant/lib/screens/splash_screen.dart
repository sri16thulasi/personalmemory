import 'package:flutter/material.dart';
import 'package:personal_memory_assistant/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to AuthWrapper after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean background
      body: Center(
        child: Image.asset(
          'assets/images/nexmind_logo_with_text.png',
          width: 200,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            // Display a fallback icon or text if the image fails to load
            print('Error loading image: $error'); // Log error for debugging
            return const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red,
            );
          },
        ),
      ),
    );
  }
}