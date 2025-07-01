import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { admin, wholeseller, retailer }
enum AccountStatus { pending, approved, rejected }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserType userType;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final List<ShopModel> shops;
  final DocumentModel documents;
  final String? profileImage;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    required this.shops,
    required this.documents,
    this.profileImage,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${data['userType']}',
        orElse: () => UserType.retailer,
      ),
      status: AccountStatus.values.firstWhere(
        (e) => e.toString() == 'AccountStatus.${data['status']}',
        orElse: () => AccountStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null 
          ? (data['approvedAt'] as Timestamp).toDate() 
          : null,
      approvedBy: data['approvedBy'],
      shops: (data['shops'] as List<dynamic>?)
          ?.map((shop) => ShopModel.fromMap(shop))
          .toList() ?? [],
      documents: DocumentModel.fromMap(data['documents'] ?? {}),
      profileImage: data['profileImage'],
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'shops': shops.map((shop) => shop.toMap()).toList(),
      'documents': documents.toMap(),
      'profileImage': profileImage,
      'fcmToken': fcmToken,
    };
  }
}

class ShopModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String shopImage;
  final String shopType; // single or franchise
  final bool isActive;

  ShopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.shopImage,
    required this.shopType,
    this.isActive = true,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      shopImage: map['shopImage'] ?? '',
      shopType: map['shopType'] ?? 'single',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'shopImage': shopImage,
      'shopType': shopType,
      'isActive': isActive,
    };
  }
}

class DocumentModel {
  final String aadharNumber;
  final String panNumber;
  final String gstNumber;
  final String aadharImage;
  final String panImage;
  final String gstImage;

  DocumentModel({
    required this.aadharNumber,
    required this.panNumber,
    required this.gstNumber,
    required this.aadharImage,
    required this.panImage,
    required this.gstImage,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      aadharNumber: map['aadharNumber'] ?? '',
      panNumber: map['panNumber'] ?? '',
      gstNumber: map['gstNumber'] ?? '',
      aadharImage: map['aadharImage'] ?? '',
      panImage: map['panImage'] ?? '',
      gstImage: map['gstImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'gstNumber': gstNumber,
      'aadharImage': aadharImage,
      'panImage': panImage,
      'gstImage': gstImage,
    };
  }
}