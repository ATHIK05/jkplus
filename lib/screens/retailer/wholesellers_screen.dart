import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';
import '../../models/user_model.dart';
import 'wholeseller_products_screen.dart';

class WholesellersScreen extends StatefulWidget {
  const WholesellersScreen({Key? key}) : super(key: key);

  @override
  State<WholesellersScreen> createState() => _WholesellersScreenState();
}

class _WholesellersScreenState extends State<WholesellersScreen> {
  String _searchQuery = '';
  List<UserModel> _wholesellers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWholesellers();
  }

  Future<void> _loadWholesellers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<UserModel> _filterWholesellers() {
    if (_searchQuery.isEmpty) return _wholesellers;
    
    return _wholesellers.where((wholeseller) {
      return wholeseller.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             wholeseller.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             wholeseller.shops.any((shop) => 
               shop.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               shop.address.toLowerCase().contains(_searchQuery.toLowerCase())
             );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final filteredWholesellers = _filterWholesellers();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.wholesellers),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: localizations.searchWholesellers,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Wholesellers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredWholesellers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.noWholesellersFound,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWholesellers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredWholesellers.length,
                          itemBuilder: (context, index) {
                            final wholeseller = filteredWholesellers[index];
                            return _buildWholeseller Card(wholeseller, index, localizations);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWholeseller Card(UserModel wholeseller, int index, AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WholesellersProductsScreen(wholeseller: wholeseller),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile and basic info
              Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: wholeseller.profileImage != null && wholeseller.profileImage!.isNotEmpty
                        ? ClipOval(
                            child: Image.memory(
                              base64Decode(wholeseller.profileImage!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              wholeseller.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wholeseller.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wholeseller.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          wholeseller.phone,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      localizations.approved,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Shops Information
              if (wholeseller.shops.isNotEmpty) ...[
                Text(
                  '${localizations.shops} (${wholeseller.shops.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 8),
                ...wholeseller.shops.take(2).map((shop) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              shop.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          shop.shopType,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                if (wholeseller.shops.length > 2)
                  Text(
                    '... and ${wholeseller.shops.length - 2} more shops',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WholesellersProductsScreen(wholeseller: wholeseller),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: Text(localizations.viewProducts),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement connect functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Connected to ${wholeseller.name}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.link),
                    label: Text(localizations.connect),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03DAC6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
  }
}