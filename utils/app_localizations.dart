import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Common
  String get appName => _localizedValues[locale.languageCode]?['app_name'] ?? 'JK Plus';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'Add';

  // Auth
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Register';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get phone => _localizedValues[locale.languageCode]?['phone'] ?? 'Phone';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';

  // User Types
  String get admin => _localizedValues[locale.languageCode]?['admin'] ?? 'Admin';
  String get wholeseller => _localizedValues[locale.languageCode]?['wholeseller'] ?? 'Wholeseller';
  String get retailer => _localizedValues[locale.languageCode]?['retailer'] ?? 'Retailer';

  // Dashboard
  String get dashboard => _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';
  String get products => _localizedValues[locale.languageCode]?['products'] ?? 'Products';
  String get orders => _localizedValues[locale.languageCode]?['orders'] ?? 'Orders';
  String get sales => _localizedValues[locale.languageCode]?['sales'] ?? 'Sales';
  String get analytics => _localizedValues[locale.languageCode]?['analytics'] ?? 'Analytics';
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';

  // Products
  String get addProduct => _localizedValues[locale.languageCode]?['add_product'] ?? 'Add Product';
  String get productName => _localizedValues[locale.languageCode]?['product_name'] ?? 'Product Name';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  String get price => _localizedValues[locale.languageCode]?['price'] ?? 'Price';
  String get quantity => _localizedValues[locale.languageCode]?['quantity'] ?? 'Quantity';
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  String get lowStock => _localizedValues[locale.languageCode]?['low_stock'] ?? 'Low Stock';

  // Status
  String get pending => _localizedValues[locale.languageCode]?['pending'] ?? 'Pending';
  String get approved => _localizedValues[locale.languageCode]?['approved'] ?? 'Approved';
  String get rejected => _localizedValues[locale.languageCode]?['rejected'] ?? 'Rejected';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'JK Plus',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'phone': 'Phone',
      'logout': 'Logout',
      'admin': 'Admin',
      'wholeseller': 'Wholeseller',
      'retailer': 'Retailer',
      'dashboard': 'Dashboard',
      'products': 'Products',
      'orders': 'Orders',
      'sales': 'Sales',
      'analytics': 'Analytics',
      'notifications': 'Notifications',
      'settings': 'Settings',
      'add_product': 'Add Product',
      'product_name': 'Product Name',
      'description': 'Description',
      'price': 'Price',
      'quantity': 'Quantity',
      'category': 'Category',
      'low_stock': 'Low Stock',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
    },
    'hi': {
      'app_name': 'जेके प्लस',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'cancel': 'रद्द करें',
      'confirm': 'पुष्टि करें',
      'save': 'सेव करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'login': 'लॉगिन',
      'register': 'पंजीकरण',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'phone': 'फोन',
      'logout': 'लॉगआउट',
      'admin': 'एडमिन',
      'wholeseller': 'थोक विक्रेता',
      'retailer': 'खुदरा विक्रेता',
      'dashboard': 'डैशबोर्ड',
      'products': 'उत्पाद',
      'orders': 'ऑर्डर',
      'sales': 'बिक्री',
      'analytics': 'विश्लेषण',
      'notifications': 'सूचनाएं',
      'settings': 'सेटिंग्स',
      'add_product': 'उत्पाद जोड़ें',
      'product_name': 'उत्पाद का नाम',
      'description': 'विवरण',
      'price': 'मूल्य',
      'quantity': 'मात्रा',
      'category': 'श्रेणी',
      'low_stock': 'कम स्टॉक',
      'pending': 'लंबित',
      'approved': 'अनुमोदित',
      'rejected': 'अस्वीकृत',
    },
    'ta': {
      'app_name': 'ஜேகே பிளஸ்',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'cancel': 'ரத்து செய்',
      'confirm': 'உறுதிப்படுத்து',
      'save': 'சேமி',
      'delete': 'நீக்கு',
      'edit': 'திருத்து',
      'add': 'சேர்',
      'login': 'உள்நுழை',
      'register': 'பதிவு',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'name': 'பெயர்',
      'phone': 'தொலைபேசி',
      'logout': 'வெளியேறு',
      'admin': 'நிர்வாகி',
      'wholeseller': 'மொத்த விற்பனையாளர்',
      'retailer': 'சில்லறை விற்பனையாளர்',
      'dashboard': 'டாஷ்போர்டு',
      'products': 'தயாரிப்புகள்',
      'orders': 'ஆர்டர்கள்',
      'sales': 'விற்பனை',
      'analytics': 'பகுப்பாய்வு',
      'notifications': 'அறிவிப்புகள்',
      'settings': 'அமைப்புகள்',
      'add_product': 'தயாரிப்பு சேர்',
      'product_name': 'தயாரிப்பு பெயர்',
      'description': 'விளக்கம்',
      'price': 'விலை',
      'quantity': 'அளவு',
      'category': 'வகை',
      'low_stock': 'குறைந்த இருப்பு',
      'pending': 'நிலுவையில்',
      'approved': 'அங்கீகரிக்கப்பட்டது',
      'rejected': 'நிராகரிக்கப்பட்டது',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}