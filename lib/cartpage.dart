import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:lottie/lottie.dart';

import 'cart_provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Your Cart",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
            child: Center(
              child: badges.Badge(
                badgeContent: Text(
                  cartProvider.getCounter().toString(),
                  style: TextStyle(color: Colors.white),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.red, Colors.green],
            ),
          ),
        ),
      ),
      body: cartProvider.cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartList(context, cartProvider),
      bottomNavigationBar: _buildBottomNavBar(context, cartProvider),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            child: Lottie.asset(
              'assets/images/Animation - 1726912166683.json',
              // Fallback if loading fails
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty 😌',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          SizedBox(height: 20),
          Text(
            'Explore products and shop your\nfavourite items',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartProvider cartProvider) {
    return ListView.builder(
      itemCount: cartProvider.cartItems.length,
      itemBuilder: (context, index) {
        final product = cartProvider.cartItems[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[300]!, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Image.network(
                      product['images'][0]['src'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Price and Quantity Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            'Rs.${product['price']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),

                          // Quantity Controls
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (product['quantity'] > 1) {
                                      cartProvider.decreaseQuantity(index);
                                    }
                                  },
                                  child: Icon(Icons.remove, size: 18),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  product['quantity'].toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    cartProvider.increaseQuantity(index);
                                  },
                                  child: Icon(Icons.add, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () {
                    cartProvider.removeItemFromCart(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 20,
              thickness: 2,
              color: Colors.grey[300],
            ),
            Text(
              'Total: Rs.${cartProvider.getTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Divider(
              height: 20,
              thickness: 2,
              color: Colors.grey[300],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              onPressed: cartProvider.cartItems.isEmpty
                  ? null
                  : () {
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderPage()),
                      );*/
                    },
              child: Text(
                "Pay Now",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
