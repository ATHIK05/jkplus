import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserModel();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error loading user model: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserType userType,
    required List<ShopModel> shops,
    required DocumentModel documents,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final fcmToken = await _notificationService.getToken();
        
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          userType: userType,
          status: AccountStatus.pending,
          createdAt: DateTime.now(),
          shops: shops,
          documents: documents,
          profileImage: profileImage,
          fcmToken: fcmToken,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        // Send notification to admin
        await _notificationService.sendNotificationToAdmin(
          title: 'New Account Registration',
          body: '$name has registered as ${userType.toString().split('.').last}',
          data: {
            'type': 'new_registration',
            'userId': credential.user!.uid,
          },
        );

        _userModel = userModel;
        return null; // Success
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.message}');
      return e.message;
    } catch (e) {
      print('Registration error: ${e.toString()}');
      return 'An error occurred during registration: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return 'Registration failed';
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Wait for user model to load
        await _loadUserModel();
        return null; // Success
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred during login';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return 'Login failed';
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserStatus({
    required String userId,
    required AccountStatus status,
    String? approvedBy,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status.toString().split('.').last,
        'approvedAt': status == AccountStatus.approved 
            ? Timestamp.fromDate(DateTime.now()) 
            : null,
        'approvedBy': approvedBy,
      });

      // Send notification to user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final fcmToken = userData['fcmToken'];
        
        if (fcmToken != null) {
          await _notificationService.sendNotification(
            token: fcmToken,
            title: 'Account Status Update',
            body: 'Your account has been ${status.toString().split('.').last}',
            data: {
              'type': 'account_status',
              'status': status.toString().split('.').last,
            },
          );
        }
      }
    } catch (e) {
      print('Error updating user status: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    if (_userModel == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _firestore.collection('users').doc(_userModel!.id).update(updates);
      
      // Reload user model
      await _loadUserModel();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}