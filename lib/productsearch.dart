import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go90stores/cart_provider.dart';
import 'package:go90stores/productdetailpage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductSearchPage extends StatefulWidget {
  final String searchQuery;

  ProductSearchPage({required this.searchQuery});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  String consumerKey = 'ck_80f6659ac9df1f58a9b8a550a384bd36c8a36951';
  String consumerSecret = 'cs_2d6d405f0ab2924000ae7c8bdc7160440a8a71bb';
  String baseUrl = 'https://go90mart.com/wp-json/wc/v3/products';
  List products = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchProducts(widget.searchQuery);
  }

  Future<void> fetchProducts(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      String url =
          '$baseUrl?consumer_key=$consumerKey&consumer_secret=$consumerSecret&per_page=20&search=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Colors.blue, Colors.purpleAccent],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : products.isNotEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    // Use different grid layout based on screen width
                    int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                            itemCount: products.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailPage(product: product),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  shadowColor: Colors.black.withOpacity(0.2),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15.0)),
                                        child: Image.network(
                                          product['images'][0]['src'],
                                          height:
                                              120, // reduced from 150 to give space
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        // Allows the text and button to use remaining space
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'RS ${product['price']}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }));
                  },
                )
              : Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
    );
  }
}
