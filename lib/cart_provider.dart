import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  int _counter = 0;

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addItemToCart(Map<String, dynamic> product) {
    // Check if the product already exists in the cart
    bool productExists = false;
    for (var item in _cartItems) {
      if (item['id'] == product['id']) {
        // If the product exists, just increase the quantity
        item['quantity'] += 1;
        productExists = true;
        break;
      }
    }

    // If the product doesn't exist, add it with quantity 1
    if (!productExists) {
      product['quantity'] = 1;
      _cartItems.add(product);
    }

    _counter++;
    notifyListeners();
  }

  void removeItemFromCart(int index) {
    _counter -= _cartItems[index]['quantity'] as int; // Cast quantity to int
    _cartItems.removeAt(index);
    notifyListeners();
  }

  // Method to increase the quantity of an item
  void increaseQuantity(int index) {
    _cartItems[index]['quantity']++;
    _counter++;
    notifyListeners();
  }

  // Method to decrease the quantity of an item
  void decreaseQuantity(int index) {
    if (_cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity']--;
      _counter--;
      notifyListeners();
    }
  }

  int getCounter() => _counter;

  double getTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      // Cast the result of multiplication to double explicitly
      total += double.parse(item['price']) * item['quantity'] as double;
    }
    return total;
  }
}
