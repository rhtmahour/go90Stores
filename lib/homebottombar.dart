import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go90stores/cartpage.dart';
import 'package:go90stores/categories.dart';
import 'package:go90stores/customerdashboard.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback onAccountTap;
  const HomeBottomBar({super.key, required this.onAccountTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Customerdashboard()),
              );
            },
            child: const Column(
              children: [
                Icon(
                  Icons.home,
                  color: Colors.purple,
                  size: 30,
                ),
                Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Categories()),
              );
            },
            child: const Column(
              children: [
                Icon(
                  Icons.category,
                  color: Colors.purple,
                  size: 30,
                ),
                Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
            child: const Column(
              children: [
                Icon(
                  CupertinoIcons.cart,
                  color: Colors.purple,
                  size: 30,
                ),
                Text(
                  "My Cart",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          InkWell(
            onTap: onAccountTap,
            child: const Column(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.purple,
                  size: 30,
                ),
                Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
