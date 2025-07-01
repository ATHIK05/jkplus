import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RapidApiOCRService {
  static final RapidApiOCRService _instance = RapidApiOCRService._internal();
  factory RapidApiOCRService() => _instance;
  RapidApiOCRService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  List<String> _apiKeys = [];
  int _currentKeyIndex = 0;
  
  static const String _rapidApiHost = 'pen-to-print-handwriting-ocr.p.rapidapi.com';
  static const String _rapidApiUrl = 'https://pen-to-print-handwriting-ocr.p.rapidapi.com/recognize/';

  /// Load API keys from Firebase
  Future<void> _loadApiKeys() async {
    try {
      final doc = await _firestore
          .collection('ocr')
          .doc('v6Hkmcc8hNDvKP4rIrwu')
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        _apiKeys = List<String>.from(data?['ocr_keys'] ?? []);
        print('Loaded ${_apiKeys.length} API keys');
      }
    } catch (e) {
      print('Error loading API keys: $e');
    }
  }

  /// Get next available API key
  String _getNextApiKey() {
    if (_apiKeys.isEmpty) return '';
    
    final key = _apiKeys[_currentKeyIndex];
    _currentKeyIndex = (_currentKeyIndex + 1) % _apiKeys.length;
    return key;
  }

  /// Validate image format before OCR
  bool _validateImageFormat(File imageFile) {
    try {
      // Check file size (should be reasonable for OCR)
      final fileSizeInBytes = imageFile.lengthSync();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > 10) {
        print('Image too large: ${fileSizeInMB.toStringAsFixed(2)}MB');
        return false;
      }

      // Check file extension
      final extension = imageFile.path.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png', 'bmp'].contains(extension)) {
        print('Unsupported image format: $extension');
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  /// Check if image contains bill-like content using basic validation
  bool _validateBillFormat(String extractedText) {
    final text = extractedText.toLowerCase();
    
    // Check for common bill indicators
    final billIndicators = [
      'bill', 'invoice', 'receipt', 'total', 'amount', 'tax', 'gst',
      'subtotal', 'discount', 'qty', 'quantity', 'price', '₹', 'rs'
    ];
    
    int indicatorCount = 0;
    for (final indicator in billIndicators) {
      if (text.contains(indicator)) {
        indicatorCount++;
      }
    }
    
    // Should have at least 3 bill indicators
    if (indicatorCount < 3) {
      print('Image does not appear to be a bill format. Indicators found: $indicatorCount');
      return false;
    }
    
    // Check for price patterns
    final pricePattern = RegExp(r'₹?\s*\d+(?:\.\d{2})?');
    final priceMatches = pricePattern.allMatches(text);
    
    if (priceMatches.length < 2) {
      print('Insufficient price information found');
      return false;
    }
    
    return true;
  }

  /// Perform OCR using RapidAPI
  Future<Map<String, dynamic>> performOCR(File imageFile) async {
    if (_apiKeys.isEmpty) {
      await _loadApiKeys();
    }
    
    if (_apiKeys.isEmpty) {
      return {
        'success': false,
        'error': 'No API keys available',
        'text': '',
      };
    }

    // Validate image format first
    if (!_validateImageFormat(imageFile)) {
      return {
        'success': false,
        'error': 'Invalid image format. Please use a clear, well-lit image of a bill.',
        'text': '',
      };
    }

    // Try each API key until one works
    for (int attempt = 0; attempt < _apiKeys.length; attempt++) {
      final apiKey = _getNextApiKey();
      
      try {
        // Convert image to base64
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        // Prepare request
        final request = http.MultipartRequest('POST', Uri.parse(_rapidApiUrl));
        request.headers.addAll({
          'X-Rapidapi-Key': apiKey,
          'X-Rapidapi-Host': _rapidApiHost,
        });
        
        // Add image data
        request.fields['srcImg'] = 'data:image/jpeg;base64,$base64Image';
        request.fields['Session'] = 'string';
        
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          
          if (responseData['result'] == "1" && responseData['subScans'] != null) {
            final extractedText = responseData['subScans']['value'] ?? '';
            
            // Validate if the extracted text looks like a bill
            if (!_validateBillFormat(extractedText)) {
              return {
                'success': false,
                'error': 'The image does not appear to be in the correct bill format. Please ensure:\n'
                        '• The image contains a clear bill/invoice\n'
                        '• Text is readable and well-lit\n'
                        '• Bill contains items, prices, and totals\n'
                        '• Image is not blurry or tilted',
                'text': extractedText,
              };
            }
            
            return {
              'success': true,
              'text': extractedText,
              'apiKeyUsed': apiKey,
            };
          } else {
            return {
              'success': false,
              'error': 'OCR processing failed. Please try with a clearer image.',
              'text': '',
            };
          }
        } else if (response.statusCode == 429) {
          // Rate limit exceeded, try next key
          print('Rate limit exceeded for key ${attempt + 1}, trying next key...');
          continue;
        } else if (response.statusCode == 403) {
          // API key expired or invalid, try next key
          print('API key ${attempt + 1} expired or invalid, trying next key...');
          continue;
        } else {
          print('API Error ${response.statusCode}: ${response.body}');
          continue;
        }
      } catch (e) {
        print('Error with API key ${attempt + 1}: $e');
        continue;
      }
    }
    
    return {
      'success': false,
      'error': 'All API keys exhausted or failed. Please try again later.',
      'text': '',
    };
  }

  /// Extract text from camera
  Future<Map<String, dynamic>> extractTextFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        return await performOCR(imageFile);
      }
      
      return {
        'success': false,
        'error': 'No image captured',
        'text': '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error capturing image: $e',
        'text': '',
      };
    }
  }

  /// Extract text from gallery
  Future<Map<String, dynamic>> extractTextFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        return await performOCR(imageFile);
      }
      
      return {
        'success': false,
        'error': 'No image selected',
        'text': '',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error selecting image: $e',
        'text': '',
      };
    }
  }

  /// Parse bill text to extract structured data
  Map<String, dynamic> parseBillText(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final Map<String, dynamic> billData = {
      'items': <Map<String, dynamic>>[],
      'total': 0.0,
      'tax': 0.0,
      'discount': 0.0,
      'subtotal': 0.0,
      'billNumber': '',
      'date': '',
      'shopName': '',
      'customerName': '',
    };

    // Enhanced regex patterns
    final RegExp priceRegex = RegExp(r'₹?\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final RegExp billNumberRegex = RegExp(r'(?:bill|invoice|receipt|no)[\s#:]*([A-Z0-9]+)', caseSensitive: false);
    final RegExp dateRegex = RegExp(r'(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})');
    final RegExp totalRegex = RegExp(r'(?:total|grand\s*total|amount|net\s*amount)[\s:]*₹?\s*(\d+(?:\.\d{2})?)', caseSensitive: false);
    final RegExp taxRegex = RegExp(r'(?:tax|gst|vat|cgst|sgst|igst)[\s:]*₹?\s*(\d+(?:\.\d{2})?)', caseSensitive: false);
    final RegExp discountRegex = RegExp(r'(?:discount|off)[\s:]*₹?\s*(\d+(?:\.\d{2})?)', caseSensitive: false);
    final RegExp customerRegex = RegExp(r'(?:customer|name|to)[\s:]*([A-Za-z\s]+)', caseSensitive: false);
    final RegExp qtyRegex = RegExp(r'(?:qty|quantity)[\s:]*(\d+)', caseSensitive: false);

    // Extract basic information
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Extract bill number
      final billNumberMatch = billNumberRegex.firstMatch(line);
      if (billNumberMatch != null && billData['billNumber'].isEmpty) {
        billData['billNumber'] = billNumberMatch.group(1)?.trim() ?? '';
      }

      // Extract date
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null && billData['date'].isEmpty) {
        billData['date'] = dateMatch.group(1)?.trim() ?? '';
      }

      // Extract customer name
      final customerMatch = customerRegex.firstMatch(line);
      if (customerMatch != null && billData['customerName'].isEmpty) {
        final name = customerMatch.group(1)?.trim() ?? '';
        if (name.length > 2 && name.length < 50) {
          billData['customerName'] = name;
        }
      }

      // Extract total
      final totalMatch = totalRegex.firstMatch(line);
      if (totalMatch != null) {
        billData['total'] = double.tryParse(totalMatch.group(1) ?? '0') ?? 0.0;
      }

      // Extract tax
      final taxMatch = taxRegex.firstMatch(line);
      if (taxMatch != null) {
        billData['tax'] += double.tryParse(taxMatch.group(1) ?? '0') ?? 0.0;
      }

      // Extract discount
      final discountMatch = discountRegex.firstMatch(line);
      if (discountMatch != null) {
        billData['discount'] += double.tryParse(discountMatch.group(1) ?? '0') ?? 0.0;
      }

      // Extract shop name (usually in first 3 lines)
      if (i < 3 && billData['shopName'].isEmpty && line.length > 3) {
        if (!line.contains(RegExp(r'\d{10}')) && 
            !line.toLowerCase().contains('address') &&
            !line.toLowerCase().contains('phone') &&
            !dateRegex.hasMatch(line)) {
          billData['shopName'] = line;
        }
      }
    }

    // Extract items (more sophisticated parsing)
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Skip header lines and total lines
      if (totalRegex.hasMatch(line) || taxRegex.hasMatch(line) || 
          discountRegex.hasMatch(line) || line.toLowerCase().contains('subtotal')) {
        continue;
      }

      final priceMatches = priceRegex.allMatches(line);
      if (priceMatches.isNotEmpty) {
        final prices = priceMatches.map((match) => 
          double.tryParse(match.group(1) ?? '0') ?? 0.0).toList();
        
        // Extract quantity if present
        final qtyMatch = qtyRegex.firstMatch(line);
        int quantity = 1;
        if (qtyMatch != null) {
          quantity = int.tryParse(qtyMatch.group(1) ?? '1') ?? 1;
        }

        // Clean item name
        String itemName = line;
        for (final match in priceMatches) {
          itemName = itemName.replaceAll(match.group(0) ?? '', '');
        }
        if (qtyMatch != null) {
          itemName = itemName.replaceAll(qtyMatch.group(0) ?? '', '');
        }
        
        itemName = itemName
            .replaceAll(RegExp(r'[₹\s]+'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        
        // Validate item
        if (itemName.isNotEmpty && 
            itemName.length > 2 && 
            itemName.length < 100 &&
            prices.isNotEmpty &&
            !itemName.toLowerCase().contains('total') &&
            !itemName.toLowerCase().contains('tax')) {
          
          final unitPrice = prices.length > 1 ? prices[0] : prices.last;
          final totalPrice = prices.last;
          
          billData['items'].add({
            'name': itemName,
            'quantity': quantity,
            'unitPrice': unitPrice,
            'totalPrice': totalPrice,
          });
        }
      }
    }

    // Calculate subtotal if not found
    if (billData['subtotal'] == 0.0) {
      billData['subtotal'] = billData['total'] - billData['tax'] + billData['discount'];
    }

    return billData;
  }

  /// Get API usage statistics
  Future<Map<String, dynamic>> getApiUsageStats() async {
    return {
      'totalKeys': _apiKeys.length,
      'currentKeyIndex': _currentKeyIndex,
      'estimatedRequestsRemaining': (_apiKeys.length - _currentKeyIndex) * 100,
    };
  }
}