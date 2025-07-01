import 'package:cloud_firestore/cloud_firestore.dart';

enum BillType { wholesale, retail }
enum BillStatus { draft, sent, paid, cancelled }

class BillModel {
  final String id;
  final String billNumber;
  final BillType type;
  final BillStatus status;
  final String fromUserId;
  final String toUserId;
  final List<BillItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? notes;
  final String? ocrData;

  BillModel({
    required this.id,
    required this.billNumber,
    required this.type,
    required this.status,
    required this.fromUserId,
    required this.toUserId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.notes,
    this.ocrData,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      billNumber: data['billNumber'] ?? '',
      type: BillType.values.firstWhere(
        (e) => e.toString() == 'BillType.${data['type']}',
        orElse: () => BillType.retail,
      ),
      status: BillStatus.values.firstWhere(
        (e) => e.toString() == 'BillStatus.${data['status']}',
        orElse: () => BillStatus.draft,
      ),
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => BillItem.fromMap(item))
          .toList() ?? [],
      subtotal: data['subtotal']?.toDouble() ?? 0.0,
      tax: data['tax']?.toDouble() ?? 0.0,
      discount: data['discount']?.toDouble() ?? 0.0,
      total: data['total']?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      paidAt: data['paidAt'] != null 
          ? (data['paidAt'] as Timestamp).toDate() 
          : null,
      notes: data['notes'],
      ocrData: data['ocrData'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'billNumber': billNumber,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'notes': notes,
      'ocrData': ocrData,
    };
  }
}

class BillItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  BillItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}