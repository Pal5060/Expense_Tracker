import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Check if the user is logged in
  _checkUserLoginStatus() async {
    // Wait for 3 seconds to show splash screen
    Timer(Duration(seconds: 3), () async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // If user is logged in, navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        // If user is not logged in, navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26, // Customize splash background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display an image (App Logo)
            Image.asset(
              'assets/img_1.png', // Path to your image inside the assets folder
              width: 150, // Set width of image
              height: 150, // Set height of image
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Spendee',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.white, // Show loading spinner
            ),
          ],
        ),
      ),
    );
  }
}
