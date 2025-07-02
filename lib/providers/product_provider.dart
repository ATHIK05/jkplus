import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _lowStockProducts = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;

  Future<void> loadProducts(String wholesellerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('wholesellerId', isEqualTo: wholesellerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      _lowStockProducts = _products.where((product) => product.isLowStock).toList();
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories(String wholesellerId) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('wholesellerId', isEqualTo: wholesellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toFirestore());
      await loadProducts(product.wholesellerId);
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toFirestore());
      await loadProducts(product.wholesellerId);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId, String wholesellerId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      await loadProducts(wholesellerId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').add(category.toFirestore());
      await loadCategories(category.wholesellerId);
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> toggleProductVisibility(String productId, String retailerId) async {
    try {
      final productDoc = await _firestore.collection('products').doc(productId).get();
      if (productDoc.exists) {
        final product = ProductModel.fromFirestore(productDoc);
        final hiddenList = List<String>.from(product.hiddenFromRetailers);
        
        if (hiddenList.contains(retailerId)) {
          hiddenList.remove(retailerId);
        } else {
          hiddenList.add(retailerId);
        }

        await _firestore.collection('products').doc(productId).update({
          'hiddenFromRetailers': hiddenList,
        });
        
        // Reload products to reflect changes
        await loadProducts(product.wholesellerId);
      }
    } catch (e) {
      print('Error toggling product visibility: $e');
      rethrow;
    }
  }

  Future<void> hideProductFromAllRetailers(String productId, String wholesellerId) async {
    try {
      // Get all approved retailers
      final retailersSnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'retailer')
          .where('status', isEqualTo: 'approved')
          .get();

      final retailerIds = retailersSnapshot.docs.map((doc) => doc.id).toList();

      await _firestore.collection('products').doc(productId).update({
        'hiddenFromRetailers': retailerIds,
      });
      
      await loadProducts(wholesellerId);
    } catch (e) {
      print('Error hiding product from all retailers: $e');
      rethrow;
    }
  }

  Future<void> showProductToAllRetailers(String productId, String wholesellerId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'hiddenFromRetailers': [],
      });
      
      await loadProducts(wholesellerId);
    } catch (e) {
      print('Error showing product to all retailers: $e');
      rethrow;
    }
  }

  Stream<List<ProductModel>> getProductsStream(String wholesellerId) {
    return _firestore
        .collection('products')
        .where('wholesellerId', isEqualTo: wholesellerId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<ProductModel>> getLowStockProductsStream(String wholesellerId) {
    return _firestore
        .collection('products')
        .where('wholesellerId', isEqualTo: wholesellerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .where((product) => product.isLowStock)
            .toList());
  }
}