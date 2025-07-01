import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductType { expirable, shoes, stationary, electronics, clothing, other }

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int minStockLevel;
  final ProductType type;
  final String category;
  final List<String> images; // Base64 encoded images
  final String wholesellerId;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> hiddenFromRetailers;
  final Map<String, dynamic> specifications;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.minStockLevel,
    required this.type,
    required this.category,
    required this.images,
    required this.wholesellerId,
    required this.createdAt,
    this.expiryDate,
    this.isActive = true,
    this.hiddenFromRetailers = const [],
    this.specifications = const {},
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 0,
      minStockLevel: data['minStockLevel'] ?? 5,
      type: ProductType.values.firstWhere(
        (e) => e.toString() == 'ProductType.${data['type']}',
        orElse: () => ProductType.other,
      ),
      category: data['category'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      wholesellerId: data['wholesellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiryDate: data['expiryDate'] != null 
          ? (data['expiryDate'] as Timestamp).toDate() 
          : null,
      isActive: data['isActive'] ?? true,
      hiddenFromRetailers: List<String>.from(data['hiddenFromRetailers'] ?? []),
      specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'minStockLevel': minStockLevel,
      'type': type.toString().split('.').last,
      'category': category,
      'images': images,
      'wholesellerId': wholesellerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'hiddenFromRetailers': hiddenFromRetailers,
      'specifications': specifications,
    };
  }

  bool get isLowStock => quantity <= minStockLevel;
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
}

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String wholesellerId;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.wholesellerId,
    required this.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
      wholesellerId: data['wholesellerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'wholesellerId': wholesellerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}