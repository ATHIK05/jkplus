import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
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
                      hintText: 'Search products...',
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
                            const DropdownMenuItem(value: 'All', child: Text('All Categories')),
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
                        label: const Text('Low Stock'),
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
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
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
                        return _buildProductCard(product, index);
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

  Widget _buildProductCard(ProductModel product, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
  }

  void _showProductDetails(ProductModel product) {
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
                  'Description',
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
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteProduct(product);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
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

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}