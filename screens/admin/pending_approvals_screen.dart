import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'dart:convert';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingUsers();
    });
  }

  Future<void> _loadPendingUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadPendingUsers();
  }

  Future<void> _approveUser(UserModel user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.updateUserStatus(
        userId: user.id,
        status: AccountStatus.approved,
        approvedBy: 'meathik@gmail.com',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadPendingUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectUser(UserModel user) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.updateUserStatus(
        userId: user.id,
        status: AccountStatus.rejected,
        approvedBy: 'meathik@gmail.com',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} rejected'),
          backgroundColor: Colors.orange,
        ),
      );
      
      await _loadPendingUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            user.userType.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Basic Info
                _buildInfoSection('Basic Information', [
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Phone', user.phone),
                  _buildInfoRow('Registration Date', 
                      user.createdAt.toString().split(' ')[0]),
                ]),

                const SizedBox(height: 16),

                // Documents
                _buildInfoSection('Documents', [
                  _buildInfoRow('Aadhar', user.documents.aadharNumber),
                  _buildInfoRow('PAN', user.documents.panNumber),
                  _buildInfoRow('GST', user.documents.gstNumber),
                ]),

                const SizedBox(height: 16),

                // Document Images
                if (user.documents.aadharImage.isNotEmpty ||
                    user.documents.panImage.isNotEmpty ||
                    user.documents.gstImage.isNotEmpty)
                  _buildDocumentImages(user.documents),

                const SizedBox(height: 16),

                // Shops
                _buildInfoSection('Shops (${user.shops.length})', 
                  user.shops.map((shop) => _buildShopCard(shop)).toList()),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectUser(user);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveUser(user);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentImages(DocumentModel documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Images',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (documents.aadharImage.isNotEmpty)
              Expanded(child: _buildDocumentImage('Aadhar', documents.aadharImage)),
            if (documents.panImage.isNotEmpty)
              Expanded(child: _buildDocumentImage('PAN', documents.panImage)),
            if (documents.gstImage.isNotEmpty)
              Expanded(child: _buildDocumentImage('GST', documents.gstImage)),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentImage(String title, String base64Image) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(ShopModel shop) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shop.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(shop.shopType),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(shop.address),
            if (shop.shopImage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(shop.shopImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userProvider.pendingUsers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No pending approvals',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadPendingUsers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userProvider.pendingUsers.length,
            itemBuilder: (context, index) {
              final user = userProvider.pendingUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6C63FF),
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              user.userType.toString().split('.').last,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${user.shops.length} shop(s)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      // Action buttons below user details
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () => _showUserDetails(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectUser(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveUser(user),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
            },
          ),
        );
      },
    );
  }
}