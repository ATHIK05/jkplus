import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _pendingUsers = [];
  List<UserModel> _approvedUsers = [];
  List<UserModel> _wholesellers = [];
  List<UserModel> _retailers = [];
  bool _isLoading = false;

  List<UserModel> get pendingUsers => _pendingUsers;
  List<UserModel> get approvedUsers => _approvedUsers;
  List<UserModel> get wholesellers => _wholesellers;
  List<UserModel> get retailers => _retailers;
  bool get isLoading => _isLoading;

  Future<void> loadPendingUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      _pendingUsers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading pending users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApprovedUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .get();

      _approvedUsers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading approved users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWholesellers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'wholeseller')
          .where('status', isEqualTo: 'approved')
          .get();

      _wholesellers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading wholesellers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRetailers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'retailer')
          .where('status', isEqualTo: 'approved')
          .get();

      _retailers = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading retailers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<UserModel>> getPendingUsersStream() {
    return _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
  }
}