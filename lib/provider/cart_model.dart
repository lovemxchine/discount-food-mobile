import 'dart:ffi';

import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  String? _detail;

  List<Map<String, dynamic>> get items => _items;

  String? get detail => _detail; // <-- Getter

  set detail(String? value) {
    // <-- Setter
    _detail = value;
    notifyListeners();
  }

  void add(
    Map<String, dynamic> product,
    int quantity,
  ) {
    final productId = product['productId'];
    final index = _items.indexWhere((item) => item['productId'] == productId);
    if (index != -1) {
      _items[index]['quantity'] += quantity;
    } else {
      final newProduct = Map<String, dynamic>.from(product);
      newProduct['quantity'] = quantity;
      newProduct['productId'] =
          productId ?? product['productId']; // Ensure productId is set
      _items.add(newProduct);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item['productId'] == productId);
    notifyListeners();
  }

  void decrement(String productId) {
    final index = _items.indexWhere((item) => item['productId'] == productId);
    if (index != -1) {
      if (_items[index]['quantity'] > 1) {
        _items[index]['quantity'] -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  Map<String, dynamic>? getByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item['productId'] == productId);
    } catch (e) {
      return null;
    }
  }

  int get count =>
      _items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  double get total => _items.fold(
      0.0, (sum, item) => sum + (item['salePrice'] * item['quantity']));
}
