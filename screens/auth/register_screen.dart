import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

import '../../providers/auth_provider.dart';
import '../../utils/app_localizations.dart';
import '../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Basic Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.retailer;

  // Documents
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _gstController = TextEditingController();
  String? _aadharImage;
  String? _panImage;
  String? _gstImage;

  // Shop Info
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  String _shopType = 'single';
  String? _shopImage;
  double? _latitude;
  double? _longitude;

  final List<ShopModel> _shops = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _gstController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<String> _compressAndEncodeImage(File imageFile) async {
    final originalBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(originalBytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }
    // Resize image to max width 800px (optional, adjust as needed)
    image = img.copyResize(image, width: 800);
    // Compress to JPEG with quality 50 (adjust as needed)
    final compressedBytes = img.encodeJpg(image, quality: 50);
    return base64Encode(compressedBytes);
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedBase64 = await _compressAndEncodeImage(File(pickedFile.path));
      setState(() {
        switch (type) {
          case 'aadhar':
            _aadharImage = compressedBase64;
            break;
          case 'pan':
            _panImage = compressedBase64;
            break;
          case 'gst':
            _gstImage = compressedBase64;
            break;
          case 'shop':
            _shopImage = compressedBase64;
            break;
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission permanently denied. Please enable it in app settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _shopAddressController.text = 
              '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _addShop() {
    if (_shopNameController.text.isEmpty || 
        _shopAddressController.text.isEmpty ||
        _shopImage == null ||
        _latitude == null ||
        _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all shop details')),
      );
      return;
    }

    final shop = ShopModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _shopNameController.text,
      address: _shopAddressController.text,
      latitude: _latitude!,
      longitude: _longitude!,
      shopImage: _shopImage!,
      shopType: _shopType,
    );

    setState(() {
      _shops.add(shop);
      _shopNameController.clear();
      _shopAddressController.clear();
      _shopImage = null;
      _latitude = null;
      _longitude = null;
      _shopType = 'single';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shop added successfully')),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Auto-add shop if fields are filled but not yet added
    if (_shops.isEmpty &&
        _shopNameController.text.isNotEmpty &&
        _shopAddressController.text.isNotEmpty &&
        _shopImage != null &&
        _latitude != null &&
        _longitude != null) {
      final shop = ShopModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _shopNameController.text,
        address: _shopAddressController.text,
        latitude: _latitude!,
        longitude: _longitude!,
        shopImage: _shopImage!,
        shopType: _shopType,
      );
      setState(() {
        _shops.add(shop);
        _shopNameController.clear();
        _shopAddressController.clear();
        _shopImage = null;
        _latitude = null;
        _longitude = null;
        _shopType = 'single';
      });
    }

    if (_shops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one shop')),
      );
      return;
    }

    final documents = DocumentModel(
      aadharNumber: _aadharController.text,
      panNumber: _panController.text,
      gstNumber: _gstController.text,
      aadharImage: _aadharImage ?? '',
      panImage: _panImage ?? '',
      gstImage: _gstImage ?? '',
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final error = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      userType: _selectedUserType,
      shops: _shops,
      documents: documents,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message and navigate back
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: const Text(
          'Your account has been created and is pending approval. '
          'You will receive a notification once your account is approved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.register),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                            ? const Color(0xFF6C63FF) 
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Form Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildDocumentsStep(),
                  _buildShopInfoStep(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return ElevatedButton(
                          onPressed: authProvider.isLoading 
                              ? null 
                              : (_currentStep == 2 ? _register : _nextStep),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(_currentStep == 2 ? 'Register' : 'Next'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: localizations.name,
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: localizations.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: localizations.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: localizations.password,
              prefixIcon: const Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Account Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: RadioListTile<UserType>(
                  title: Text(localizations.wholeseller),
                  value: UserType.wholeseller,
                  groupValue: _selectedUserType,
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<UserType>(
                  title: Text(localizations.retailer),
                  value: UserType.retailer,
                  groupValue: _selectedUserType,
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),

          // Aadhar
          TextFormField(
            controller: _aadharController,
            decoration: const InputDecoration(
              labelText: 'Aadhar Number',
              prefixIcon: Icon(Icons.credit_card),
            ),
          ),
          const SizedBox(height: 8),
          _buildImagePicker('Aadhar Image', 'aadhar', _aadharImage),

          const SizedBox(height: 16),

          // PAN
          TextFormField(
            controller: _panController,
            decoration: const InputDecoration(
              labelText: 'PAN Number',
              prefixIcon: Icon(Icons.credit_card),
            ),
          ),
          const SizedBox(height: 8),
          _buildImagePicker('PAN Image', 'pan', _panImage),

          const SizedBox(height: 16),

          // GST
          TextFormField(
            controller: _gstController,
            decoration: const InputDecoration(
              labelText: 'GST Number',
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 8),
          _buildImagePicker('GST Image', 'gst', _gstImage),
        ],
      ),
    );
  }

  Widget _buildShopInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn().slideX(),
          
          const SizedBox(height: 24),

          TextFormField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              labelText: 'Shop Name',
              prefixIcon: Icon(Icons.store),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _shopAddressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Shop Address',
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _getCurrentLocation,
              ),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _shopType,
            decoration: const InputDecoration(
              labelText: 'Shop Type',
              prefixIcon: Icon(Icons.business),
            ),
            items: const [
              DropdownMenuItem(value: 'single', child: Text('Single')),
              DropdownMenuItem(value: 'franchise', child: Text('Franchise')),
            ],
            onChanged: (value) {
              setState(() {
                _shopType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          _buildImagePicker('Shop Image', 'shop', _shopImage),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addShop,
              icon: const Icon(Icons.add),
              label: const Text('Add Shop'),
            ),
          ),

          if (_shops.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Added Shops (${_shops.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _shops.length,
              itemBuilder: (context, index) {
                final shop = _shops[index];
                return Card(
                  child: ListTile(
                    title: Text(shop.name),
                    subtitle: Text(shop.address),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _shops.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, String type, String? image) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _pickImage(type),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(image),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}