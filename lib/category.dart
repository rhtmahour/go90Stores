import 'package:flutter/material.dart';
import 'package:go90stores/productpage.dart';

class Category extends StatelessWidget {
  const Category({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    List<Map<String, String>> categories = [
      {"image": "assets/images/fruits2.png", "label": "Fruits"},
      {"image": "assets/images/vegetables.png", "label": "Vegetables"},
      {"image": "assets/images/meat1.png", "label": "Meat"},
      {"image": "assets/images/dairy_products.png", "label": "Dairy"},
      {"image": "assets/images/cold_drink1.png", "label": "Drinks"},
      {"image": "assets/images/bakery.png", "label": "Bakery"},
      {"image": "assets/images/coffee.png", "label": "Coffee"},
      {"image": "assets/images/instant-food.png", "label": "Maggi"},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.purple[50],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.start,
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
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = screenWidth > 800
                  ? 6
                  : screenWidth > 600
                      ? 5
                      : 4;
              double imageSize = screenWidth * 0.18;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(
                    context,
                    categories[index]["image"]!,
                    categories[index]["label"]!,
                    imageSize,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String imagePath, String label, double size) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(storeId: ''),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: size * 0.18, // Responsive font
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
