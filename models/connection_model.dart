import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus { pending, accepted, rejected }

class ConnectionModel {
  final String id;
  final String retailerId;
  final String wholesellerId;
  final ConnectionStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? message;

  ConnectionModel({
    required this.id,
    required this.retailerId,
    required this.wholesellerId,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
    this.message,
  });

  factory ConnectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConnectionModel(
      id: doc.id,
      retailerId: data['retailerId'] ?? '',
      wholesellerId: data['wholesellerId'] ?? '',
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${data['status']}',
        orElse: () => ConnectionStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
      message: data['message'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'retailerId': retailerId,
      'wholesellerId': wholesellerId,
      'status': status.toString().split('.').last,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'message': message,
    };
  }
}