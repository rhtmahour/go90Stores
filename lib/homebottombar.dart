import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

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
            onTap: () {},
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
            onTap: () {},
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
            onTap: () {},
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
            onTap: () {},
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
