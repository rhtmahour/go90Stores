import 'package:flutter/material.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key, required String searchQuery});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Search Products"),
      ),
    );
  }
}
