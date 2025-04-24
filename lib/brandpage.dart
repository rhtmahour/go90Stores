import 'package:flutter/material.dart';
import 'package:go90stores/productpage.dart';

class Brandpage extends StatelessWidget {
  const Brandpage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.purple[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Shop By Brands',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              brandCard(
                  'TATA Tea', 'assets/images/tata.png', screenWidth, context,
                  () {
                // Add your onTap functionality here
              }),
              brandCard(
                  'Dettol', 'assets/images/dettol.png', screenWidth, context,
                  () {
                // Add your onTap functionality here
              }),
              brandCard('Coca-Cola', 'assets/images/coca_cola.png', screenWidth,
                  context, () {
                // Add your onTap functionality here
              }),
              brandCard(
                  'LOreal', 'assets/images/loreal.png', screenWidth, context,
                  () {
                // Add your onTap functionality here
              }),
              brandCard('India Gate', 'assets/images/india_gate.png',
                  screenWidth, context, () {
                // Add your onTap functionality here
              }),
              brandCard(
                  'Catch', 'assets/images/catch.png', screenWidth, context, () {
                // Add your onTap functionality here
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget brandCard(String brandName, String imagePath, double screenWidth,
      BuildContext context, VoidCallback onTap) {
    final double cardWidth = screenWidth < 600 ? screenWidth / 2 - 20 : 180;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(storeId: ''),
          ),
        );
      },
      borderRadius:
          BorderRadius.circular(16), // Ensures ripple effect is clipped
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                brandName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 50,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
