import 'package:flutter/material.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Customerdashboard extends StatefulWidget {
  const Customerdashboard({super.key});

  @override
  State<Customerdashboard> createState() => _CustomerdashboardState();
}

class _CustomerdashboardState extends State<Customerdashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _signOut(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminLogin()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Customer Dashborad"),
        actions: [
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: Text("Welcome to the Customer Dashboard"),
      ),
    );
  }
}
