import 'package:flutter/material.dart';

class Customerdashboard extends StatefulWidget {
  const Customerdashboard({super.key});

  @override
  State<Customerdashboard> createState() => _CustomerdashboardState();
}

class _CustomerdashboardState extends State<Customerdashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Customer Dashborad"),
      ),
      body: Center(
        child: Text("Welcome to the Customer Dashboard"),
      ),
    );
  }
}
