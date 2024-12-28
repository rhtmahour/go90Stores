import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go90stores/adminlogin.dart';

class MyStore extends StatelessWidget {
  const MyStore({super.key});

  Future<void> _signOut(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Show confirmation dialog
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User selects "No"
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User selects "Yes"
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    // If user confirms logout, perform sign out
    if (confirmLogout == true) {
      await auth.signOut(); // Sign out from Firebase Auth
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminLogin()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Store',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to My Store!!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
