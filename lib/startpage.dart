import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go90stores/adminlogin.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Handle Web Compatibility)
          kIsWeb
              ? Image.network(
                  "https://st5.depositphotos.com/1258191/62472/i/450/depositphotos_624724952-stock-illustration-online-grocery-app-smartphone-full.jpg", // Use an online fallback for Web
                  fit: BoxFit.cover,
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of the screen width
                  height: MediaQuery.of(context).size.height *
                      0.3, // Adjust height as needed
                  child: Image.network(
                    "https://st5.depositphotos.com/1258191/62472/i/450/depositphotos_624724952-stock-illustration-online-grocery-app-smartphone-full.jpg",
                    fit:
                        BoxFit.cover, // Ensures the image covers the entire box
                  ),
                ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              // App Logo
              Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 80,
              ),
              SizedBox(height: 20),
              // Welcome Text
              Text(
                "Welcome to Go90 Stores",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Shop your favorite items at the best prices!",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Start Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (kIsWeb) {
                    // Use Named Routes for better Web Navigation
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AdminLogin()), // Works for Android/iOS
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AdminLogin()), // Works for Android/iOS
                    );
                  }
                },
                child: Text(
                  "Start Shopping",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 53, 121, 156),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
