import 'package:flutter/material.dart';
import 'package:go90stores/productpage.dart';

class Category extends StatelessWidget {
  const Category({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 600;
    double imageSize = isSmallScreen ? 70 : 90; // Adjust for screen size

    List<Map<String, String>> categories = [
      {"image": "assets/images/fruits2.png", "label": "Fruits"},
      {"image": "assets/images/vegetables.png", "label": "Vegetables"},
      {"image": "assets/images/meat1.png", "label": "Meat"},
      {"image": "assets/images/dairy_products.png", "label": "Dairy"},
      {"image": "assets/images/cold_drink1.png", "label": "Drinks"},
      {"image": "assets/images/bakery.png", "label": "Bakery"},
      {"image": "assets/images/coffee.png", "label": "Coffee"},
      {"image": "assets/images/instant-food.png", "label": "Instant Food"},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min, // Prevent unnecessary stretching
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            'Shop By Category',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: screenHeight * 0.30, // Increased height to prevent overflow
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 items per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85, // Adjust height-to-width ratio
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(context, categories[index]["image"]!,
                    categories[index]["label"]!, imageSize);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String imagePath, String label, double size) {
    return InkWell(
      onTap: () {
        // Add navigation logic here
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductPage(
                    storeId: '',
                  )),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Proper alignment
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(width: 0.5, color: Colors.black),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              ],
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 3), // Reduced spacing
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2, // Prevents text overflow
              overflow: TextOverflow.ellipsis, // Handles long text
            ),
          ),
        ],
      ),
    );
  }
}
