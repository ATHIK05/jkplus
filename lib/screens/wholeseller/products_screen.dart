import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../utils/app_localizations.dart';
import 'add_product_screen.dart';
import 'dart:convert';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showLowStockOnly = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Consumer2<ProductProvider, AuthProvider>(
      builder: (context, productProvider, authProvider, child) {
        final products = _filterProducts(productProvider.products);
        
        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: localizations.searchProducts,
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
                  
                  const SizedBox(height: 12),
                  
                  // Filter Row
                  Row(
                    children: [
                      // Category Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 'All', child: Text(localizations.allCategories)),
                            ...productProvider.categories.map((category) =>
                              DropdownMenuItem(
                                value: category.name,
                                child: Text(category.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Low Stock Filter
                      FilterChip(
                        label: Text(localizations.lowStock),
                        selected: _showLowStockOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showLowStockOnly = selected;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.noProductsFound,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product, index, localizations);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var filtered = products;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    // Low stock filter
    if (_showLowStockOnly) {
      filtered = filtered.where((product) => product.isLowStock).toList();
    }

    return filtered;
  }

  Widget _buildProductCard(ProductModel product, int index, AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(product, localizations),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(product.images.first),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Visibility Toggle
                        PopupMenuButton<String>(
                          icon: Icon(
                            product.hiddenFromRetailers.isEmpty 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                            color: product.hiddenFromRetailers.isEmpty 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          onSelected: (value) => _handleVisibilityAction(value, product),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'show_all',
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text('Show to All Retailers'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'hide_all',
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_off, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text('Hide from All Retailers'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'manage_individual',
                              child: Row(
                                children: [
                                  const Icon(Icons.settings, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text('Manage Individual Access'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isLowStock 
                                ? Colors.red.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stock: ${product.quantity}',
                            style: TextStyle(
                              color: product.isLowStock ? Colors.red : Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.hiddenFromRetailers.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hidden: ${product.hiddenFromRetailers.length}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product, localizations),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
  }

  void _handleVisibilityAction(String action, ProductModel product) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      switch (action) {
        case 'show_all':
          await productProvider.showProductToAllRetailers(product.id, authProvider.userModel!.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} is now visible to all retailers'),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case 'hide_all':
          await productProvider.hideProductFromAllRetailers(product.id, authProvider.userModel!.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} is now hidden from all retailers'),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        case 'manage_individual':
          _showIndividualAccessManager(product);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating visibility: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showIndividualAccessManager(ProductModel product) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadRetailers();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Retailer Access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Control which retailers can see "${product.name}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.retailers.isEmpty) {
                      return const Center(child: Text('No retailers found'));
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: userProvider.retailers.length,
                      itemBuilder: (context, index) {
                        final retailer = userProvider.retailers[index];
                        final isHidden = product.hiddenFromRetailers.contains(retailer.id);
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6C63FF),
                              child: Text(
                                retailer.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(retailer.name),
                            subtitle: Text(retailer.email),
                            trailing: Switch(
                              value: !isHidden,
                              onChanged: (value) async {
                                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                                try {
                                  await productProvider.toggleProductVisibility(product.id, retailer.id);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error updating access: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              activeColor: const Color(0xFF6C63FF),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(ProductModel product, AppLocalizations localizations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Images
                if (product.images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: product.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              base64Decode(product.images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Product Name
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Price and Stock
                Row(
                  children: [
                    Chip(
                      label: Text('₹${product.price.toStringAsFixed(2)}'),
                      backgroundColor: Colors.green.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('Stock: ${product.quantity}'),
                      backgroundColor: product.isLowStock 
                          ? Colors.red.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(product.category),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  localizations.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.description),

                const SizedBox(height: 16),

                // Specifications
                if (product.specifications.isNotEmpty) ...[
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...product.specifications.entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('${entry.value}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Expiry Date
                if (product.expiryDate != null) ...[
                  Text(
                    'Expiry Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.expiryDate!.toString().split(' ')[0],
                    style: TextStyle(
                      color: product.isExpired ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Visibility Status
                Text(
                  'Visibility Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: product.hiddenFromRetailers.isEmpty 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: product.hiddenFromRetailers.isEmpty 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        product.hiddenFromRetailers.isEmpty 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                        color: product.hiddenFromRetailers.isEmpty 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.hiddenFromRetailers.isEmpty
                              ? 'Visible to all retailers'
                              : 'Hidden from ${product.hiddenFromRetailers.length} retailer(s)',
                          style: TextStyle(
                            color: product.hiddenFromRetailers.isEmpty 
                                ? Colors.green 
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editProduct(product);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(localizations.edit),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteProduct(product, localizations);
                        },
                        icon: const Icon(Icons.delete),
                        label: Text(localizations.delete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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

  void _editProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    );
  }

  void _deleteProduct(ProductModel product, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.delete + ' ' + localizations.products),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              
              try {
                await productProvider.deleteProduct(product.id, authProvider.userModel!.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}