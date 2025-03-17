import 'package:flutter/material.dart';
import 'package:go90stores/productpage.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1, // Adjusted aspect ratio
                    ),
                    itemCount: categoryData.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(
                        context,
                        categoryData[index]['image']!,
                        categoryData[index]['name']!,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, String imagePath, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductPage(
                    storeId: '',
                  )),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy category data
final List<Map<String, String>> categoryData = [
  {'image': 'assets/images/fruits2.png', 'name': 'Fruits'},
  {'image': 'assets/images/vegetables.png', 'name': 'Vegetables'},
  {'image': 'assets/images/meat1.png', 'name': 'Meat'},
  {'image': 'assets/images/dairy_products.png', 'name': 'Dairy'},
  {'image': 'assets/images/cold_drink1.png', 'name': 'Cold Drinks'},
  {'image': 'assets/images/bakery.png', 'name': 'Bakery'},
  {'image': 'assets/images/coffee.png', 'name': 'Coffee'},
  {'image': 'assets/images/instant-food.png', 'name': 'Instant Food'},
];
