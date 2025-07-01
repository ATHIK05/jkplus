import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await Future.wait([
      userProvider.loadApprovedUsers(),
      userProvider.loadWholesellers(),
      userProvider.loadRetailers(),
    ]);
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
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

        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Wholesellers'),
            Tab(text: 'Retailers'),
          ],
        ),

        // Tab Views
        Expanded(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(_filterUsers(userProvider.approvedUsers)),
                  _buildUserList(_filterUsers(userProvider.wholesellers)),
                  _buildUserList(_filterUsers(userProvider.retailers)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
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
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getUserTypeColor(user.userType),
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
                        backgroundColor: _getUserTypeColor(user.userType).withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          user.status.toString().split('.').last,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(user.status).withOpacity(0.2),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Phone', user.phone),
                      _buildInfoRow('Registration Date', 
                          user.createdAt.toString().split(' ')[0]),
                      if (user.approvedAt != null)
                        _buildInfoRow('Approved Date', 
                            user.approvedAt!.toString().split(' ')[0]),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Shops (${user.shops.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ...user.shops.map((shop) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.store),
                          title: Text(shop.name),
                          subtitle: Text(shop.address),
                          trailing: Chip(
                            label: Text(shop.shopType),
                            backgroundColor: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Color _getUserTypeColor(UserType userType) {
    switch (userType) {
      case UserType.admin:
        return Colors.red;
      case UserType.wholeseller:
        return Colors.blue;
      case UserType.retailer:
        return Colors.green;
    }
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.pending:
        return Colors.orange;
      case AccountStatus.approved:
        return Colors.green;
      case AccountStatus.rejected:
        return Colors.red;
    }
  }
}