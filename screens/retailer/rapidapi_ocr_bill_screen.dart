import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../services/rapidapi_ocr_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/bill_model.dart';

class RapidApiOCRBillScreen extends StatefulWidget {
  const RapidApiOCRBillScreen({Key? key}) : super(key: key);

  @override
  State<RapidApiOCRBillScreen> createState() => _RapidApiOCRBillScreenState();
}

class _RapidApiOCRBillScreenState extends State<RapidApiOCRBillScreen> {
  final RapidApiOCRService _ocrService = RapidApiOCRService();
  bool _isProcessing = false;
  String _extractedText = '';
  Map<String, dynamic>? _parsedBillData;
  String? _errorMessage;

  Future<void> _scanFromCamera() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _ocrService.extractTextFromCamera();
      
      if (result['success']) {
        setState(() {
          _extractedText = result['text'];
          _parsedBillData = _ocrService.parseBillText(result['text']);
        });
        _showSnackBar('Bill scanned successfully!', Colors.green);
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
        _showSnackBar(result['error'], Colors.red);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error scanning image: $e';
      });
      _showSnackBar('Error scanning image: $e', Colors.red);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _ocrService.extractTextFromGallery();
      
      if (result['success']) {
        setState(() {
          _extractedText = result['text'];
          _parsedBillData = _ocrService.parseBillText(result['text']);
        });
        _showSnackBar('Bill processed successfully!', Colors.green);
      } else {
        setState(() {
          _errorMessage = result['error'];
        });
        _showSnackBar(result['error'], Colors.red);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing image: $e';
      });
      _showSnackBar('Error processing image: $e', Colors.red);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _createBillFromOCR() {
    if (_parsedBillData == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Create bill items from parsed data
    final items = (_parsedBillData!['items'] as List<Map<String, dynamic>>)
        .map((item) => BillItem(
              productId: '', // Empty for OCR bills
              productName: item['name'],
              quantity: item['quantity'],
              unitPrice: item['unitPrice'],
              total: item['totalPrice'],
            ))
        .toList();

    final bill = BillModel(
      id: '',
      billNumber: _parsedBillData!['billNumber'].isNotEmpty 
          ? _parsedBillData!['billNumber'] 
          : 'OCR-${DateTime.now().millisecondsSinceEpoch}',
      type: BillType.retail,
      status: BillStatus.draft,
      fromUserId: authProvider.userModel?.id ?? '',
      toUserId: '', // Customer bill
      items: items,
      subtotal: _parsedBillData!['subtotal'],
      tax: _parsedBillData!['tax'],
      discount: _parsedBillData!['discount'],
      total: _parsedBillData!['total'],
      createdAt: DateTime.now(),
      notes: 'Customer: ${_parsedBillData!['customerName']}',
      ocrData: _extractedText,
    );

    // Navigate back with bill data
    Navigator.pop(context, bill);
  }

  void _clearData() {
    setState(() {
      _extractedText = '';
      _parsedBillData = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bill Scanner'),
        actions: [
          if (_parsedBillData != null)
            TextButton.icon(
              onPressed: _createBillFromOCR,
              icon: const Icon(Icons.receipt_long),
              label: const Text('Create Bill'),
            ),
          if (_extractedText.isNotEmpty)
            IconButton(
              onPressed: _clearData,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Smart Bill Scanner',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan bills and invoices to automatically extract data',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(),

            const SizedBox(height: 24),

            // Scan Options
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _scanFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan with Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _scanFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03DAC6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Processing indicator
            if (_isProcessing) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing your bill...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This may take a few seconds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Processing Failed',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage!),
                  ],
                ),
              ).animate().fadeIn().shake(),
            ],

            // Parsed bill data
            if (_parsedBillData != null) ...[
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Bill Data Extracted',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Basic info
                    if (_parsedBillData!['shopName'].isNotEmpty)
                      _buildInfoCard('Shop Name', _parsedBillData!['shopName'], Icons.store),
                    
                    if (_parsedBillData!['billNumber'].isNotEmpty)
                      _buildInfoCard('Bill Number', _parsedBillData!['billNumber'], Icons.receipt),
                    
                    if (_parsedBillData!['customerName'].isNotEmpty)
                      _buildInfoCard('Customer', _parsedBillData!['customerName'], Icons.person),
                    
                    if (_parsedBillData!['date'].isNotEmpty)
                      _buildInfoCard('Date', _parsedBillData!['date'], Icons.calendar_today),
                    
                    // Financial summary
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildAmountRow('Subtotal', _parsedBillData!['subtotal']),
                          if (_parsedBillData!['tax'] > 0)
                            _buildAmountRow('Tax', _parsedBillData!['tax']),
                          if (_parsedBillData!['discount'] > 0)
                            _buildAmountRow('Discount', -_parsedBillData!['discount']),
                          const Divider(),
                          _buildAmountRow('Total', _parsedBillData!['total'], isTotal: true),
                        ],
                      ),
                    ),
                    
                    // Items
                    const SizedBox(height: 16),
                    Text(
                      'Items (${(_parsedBillData!['items'] as List).length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ...(_parsedBillData!['items'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Qty: ${item['quantity']} × ₹${item['unitPrice'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item['totalPrice'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
                    }),
                  ],
                ),
              ).animate().fadeIn().slideY(),
            ],

            const SizedBox(height: 32),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Best Results',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text('✓ Ensure the bill is well-lit and clearly visible'),
                    const Text('✓ Keep the bill flat without folds or wrinkles'),
                    const Text('✓ Make sure all text is readable'),
                    const Text('✓ Include the entire bill in the frame'),
                    const Text('✓ Avoid shadows and reflections'),
                    const Text('✓ Use bills with clear item names and prices'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF6C63FF) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}