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
  String get view => _localizedValues[locale.languageCode]?['view'] ?? 'View';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';
  String get yes => _localizedValues[locale.languageCode]?['yes'] ?? 'Yes';
  String get no => _localizedValues[locale.languageCode]?['no'] ?? 'No';

  // Auth
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Register';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';
  String get phone => _localizedValues[locale.languageCode]?['phone'] ?? 'Phone';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get welcomeBack => _localizedValues[locale.languageCode]?['welcome_back'] ?? 'Welcome Back!';
  String get signInToContinue => _localizedValues[locale.languageCode]?['sign_in_to_continue'] ?? 'Sign in to continue';
  String get dontHaveAccount => _localizedValues[locale.languageCode]?['dont_have_account'] ?? "Don't have an account? ";
  String get pleaseEnterEmail => _localizedValues[locale.languageCode]?['please_enter_email'] ?? 'Please enter your email';
  String get pleaseEnterValidEmail => _localizedValues[locale.languageCode]?['please_enter_valid_email'] ?? 'Please enter a valid email';
  String get pleaseEnterPassword => _localizedValues[locale.languageCode]?['please_enter_password'] ?? 'Please enter your password';
  String get passwordMinLength => _localizedValues[locale.languageCode]?['password_min_length'] ?? 'Password must be at least 6 characters';

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
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get quickActions => _localizedValues[locale.languageCode]?['quick_actions'] ?? 'Quick Actions';
  String get recentActivity => _localizedValues[locale.languageCode]?['recent_activity'] ?? 'Recent Activity';
  String get noRecentActivity => _localizedValues[locale.languageCode]?['no_recent_activity'] ?? 'No recent activity';

  // Products
  String get addProduct => _localizedValues[locale.languageCode]?['add_product'] ?? 'Add Product';
  String get productName => _localizedValues[locale.languageCode]?['product_name'] ?? 'Product Name';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  String get price => _localizedValues[locale.languageCode]?['price'] ?? 'Price';
  String get quantity => _localizedValues[locale.languageCode]?['quantity'] ?? 'Quantity';
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  String get lowStock => _localizedValues[locale.languageCode]?['low_stock'] ?? 'Low Stock';
  String get totalProducts => _localizedValues[locale.languageCode]?['total_products'] ?? 'Total Products';
  String get activeProducts => _localizedValues[locale.languageCode]?['active_products'] ?? 'Active Products';
  String get categories => _localizedValues[locale.languageCode]?['categories'] ?? 'Categories';
  String get allCategories => _localizedValues[locale.languageCode]?['all_categories'] ?? 'All Categories';
  String get searchProducts => _localizedValues[locale.languageCode]?['search_products'] ?? 'Search products...';
  String get noProductsFound => _localizedValues[locale.languageCode]?['no_products_found'] ?? 'No products found';

  // Status
  String get pending => _localizedValues[locale.languageCode]?['pending'] ?? 'Pending';
  String get approved => _localizedValues[locale.languageCode]?['approved'] ?? 'Approved';
  String get rejected => _localizedValues[locale.languageCode]?['rejected'] ?? 'Rejected';

  // Wholesellers
  String get wholesellers => _localizedValues[locale.languageCode]?['wholesellers'] ?? 'Wholesellers';
  String get findWholesellers => _localizedValues[locale.languageCode]?['find_wholesellers'] ?? 'Find Wholesellers';
  String get browseWholesellers => _localizedValues[locale.languageCode]?['browse_wholesellers'] ?? 'Browse and connect with wholesellers';
  String get noWholesellersFound => _localizedValues[locale.languageCode]?['no_wholesellers_found'] ?? 'No wholesellers found';
  String get searchWholesellers => _localizedValues[locale.languageCode]?['search_wholesellers'] ?? 'Search wholesellers...';
  String get connect => _localizedValues[locale.languageCode]?['connect'] ?? 'Connect';
  String get connected => _localizedValues[locale.languageCode]?['connected'] ?? 'Connected';
  String get viewProducts => _localizedValues[locale.languageCode]?['view_products'] ?? 'View Products';

  // Bills
  String get bills => _localizedValues[locale.languageCode]?['bills'] ?? 'Bills';
  String get createBill => _localizedValues[locale.languageCode]?['create_bill'] ?? 'Create Bill';
  String get ocrScanner => _localizedValues[locale.languageCode]?['ocr_scanner'] ?? 'OCR Scanner';
  String get manageCustomerBills => _localizedValues[locale.languageCode]?['manage_customer_bills'] ?? 'Create and manage customer bills';

  // Profile
  String get personalInformation => _localizedValues[locale.languageCode]?['personal_information'] ?? 'Personal Information';
  String get businessInformation => _localizedValues[locale.languageCode]?['business_information'] ?? 'Business Information';
  String get accountType => _localizedValues[locale.languageCode]?['account_type'] ?? 'Account Type';
  String get accountStatus => _localizedValues[locale.languageCode]?['account_status'] ?? 'Account Status';
  String get registrationDate => _localizedValues[locale.languageCode]?['registration_date'] ?? 'Registration Date';
  String get updateProfile => _localizedValues[locale.languageCode]?['update_profile'] ?? 'Update Profile';
  String get changeProfilePicture => _localizedValues[locale.languageCode]?['change_profile_picture'] ?? 'Change Profile Picture';
  String get shops => _localizedValues[locale.languageCode]?['shops'] ?? 'Shops';
  String get documents => _localizedValues[locale.languageCode]?['documents'] ?? 'Documents';

  // Users Management
  String get users => _localizedValues[locale.languageCode]?['users'] ?? 'Users';
  String get allUsers => _localizedValues[locale.languageCode]?['all_users'] ?? 'All Users';
  String get pendingApprovals => _localizedValues[locale.languageCode]?['pending_approvals'] ?? 'Pending Approvals';
  String get approvals => _localizedValues[locale.languageCode]?['approvals'] ?? 'Approvals';
  String get totalUsers => _localizedValues[locale.languageCode]?['total_users'] ?? 'Total Users';
  String get searchUsers => _localizedValues[locale.languageCode]?['search_users'] ?? 'Search users...';
  String get noUsersFound => _localizedValues[locale.languageCode]?['no_users_found'] ?? 'No users found';
  String get noPendingApprovals => _localizedValues[locale.languageCode]?['no_pending_approvals'] ?? 'No pending approvals';
  String get approve => _localizedValues[locale.languageCode]?['approve'] ?? 'Approve';
  String get reject => _localizedValues[locale.languageCode]?['reject'] ?? 'Reject';

  // Welcome Messages
  String get welcomeAdmin => _localizedValues[locale.languageCode]?['welcome_admin'] ?? 'Welcome Admin!';
  String get welcomeWholeseller => _localizedValues[locale.languageCode]?['welcome_wholeseller'] ?? 'Welcome';
  String get welcomeRetailer => _localizedValues[locale.languageCode]?['welcome_retailer'] ?? 'Welcome';
  String get manageBusinessEcosystem => _localizedValues[locale.languageCode]?['manage_business_ecosystem'] ?? 'Manage your business ecosystem';
  String get manageWholesaleBusiness => _localizedValues[locale.languageCode]?['manage_wholesale_business'] ?? 'Manage your wholesale business';
  String get manageRetailBusiness => _localizedValues[locale.languageCode]?['manage_retail_business'] ?? 'Manage your retail business';

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
      'view': 'View',
      'close': 'Close',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'phone': 'Phone',
      'logout': 'Logout',
      'welcome_back': 'Welcome Back!',
      'sign_in_to_continue': 'Sign in to continue',
      'dont_have_account': "Don't have an account? ",
      'please_enter_email': 'Please enter your email',
      'please_enter_valid_email': 'Please enter a valid email',
      'please_enter_password': 'Please enter your password',
      'password_min_length': 'Password must be at least 6 characters',
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
      'profile': 'Profile',
      'quick_actions': 'Quick Actions',
      'recent_activity': 'Recent Activity',
      'no_recent_activity': 'No recent activity',
      'add_product': 'Add Product',
      'product_name': 'Product Name',
      'description': 'Description',
      'price': 'Price',
      'quantity': 'Quantity',
      'category': 'Category',
      'low_stock': 'Low Stock',
      'total_products': 'Total Products',
      'active_products': 'Active Products',
      'categories': 'Categories',
      'all_categories': 'All Categories',
      'search_products': 'Search products...',
      'no_products_found': 'No products found',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'wholesellers': 'Wholesellers',
      'find_wholesellers': 'Find Wholesellers',
      'browse_wholesellers': 'Browse and connect with wholesellers',
      'no_wholesellers_found': 'No wholesellers found',
      'search_wholesellers': 'Search wholesellers...',
      'connect': 'Connect',
      'connected': 'Connected',
      'view_products': 'View Products',
      'bills': 'Bills',
      'create_bill': 'Create Bill',
      'ocr_scanner': 'OCR Scanner',
      'manage_customer_bills': 'Create and manage customer bills',
      'personal_information': 'Personal Information',
      'business_information': 'Business Information',
      'account_type': 'Account Type',
      'account_status': 'Account Status',
      'registration_date': 'Registration Date',
      'update_profile': 'Update Profile',
      'change_profile_picture': 'Change Profile Picture',
      'shops': 'Shops',
      'documents': 'Documents',
      'users': 'Users',
      'all_users': 'All Users',
      'pending_approvals': 'Pending Approvals',
      'approvals': 'Approvals',
      'total_users': 'Total Users',
      'search_users': 'Search users...',
      'no_users_found': 'No users found',
      'no_pending_approvals': 'No pending approvals',
      'approve': 'Approve',
      'reject': 'Reject',
      'welcome_admin': 'Welcome Admin!',
      'welcome_wholeseller': 'Welcome',
      'welcome_retailer': 'Welcome',
      'manage_business_ecosystem': 'Manage your business ecosystem',
      'manage_wholesale_business': 'Manage your wholesale business',
      'manage_retail_business': 'Manage your retail business',
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
      'view': 'देखें',
      'close': 'बंद करें',
      'ok': 'ठीक है',
      'yes': 'हाँ',
      'no': 'नहीं',
      'login': 'लॉगिन',
      'register': 'पंजीकरण',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'phone': 'फोन',
      'logout': 'लॉगआउट',
      'welcome_back': 'वापस स्वागत है!',
      'sign_in_to_continue': 'जारी रखने के लिए साइन इन करें',
      'dont_have_account': 'खाता नहीं है? ',
      'please_enter_email': 'कृपया अपना ईमेल दर्ज करें',
      'please_enter_valid_email': 'कृपया एक वैध ईमेल दर्ज करें',
      'please_enter_password': 'कृपया अपना पासवर्ड दर्ज करें',
      'password_min_length': 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए',
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
      'profile': 'प्रोफ़ाइल',
      'quick_actions': 'त्वरित कार्य',
      'recent_activity': 'हाल की गतिविधि',
      'no_recent_activity': 'कोई हाल की गतिविधि नहीं',
      'add_product': 'उत्पाद जोड़ें',
      'product_name': 'उत्पाद का नाम',
      'description': 'विवरण',
      'price': 'मूल्य',
      'quantity': 'मात्रा',
      'category': 'श्रेणी',
      'low_stock': 'कम स्टॉक',
      'total_products': 'कुल उत्पाद',
      'active_products': 'सक्रिय उत्पाद',
      'categories': 'श्रेणियां',
      'all_categories': 'सभी श्रेणियां',
      'search_products': 'उत्पाद खोजें...',
      'no_products_found': 'कोई उत्पाद नहीं मिला',
      'pending': 'लंबित',
      'approved': 'अनुमोदित',
      'rejected': 'अस्वीकृत',
      'wholesellers': 'थोक विक्रेता',
      'find_wholesellers': 'थोक विक्रेता खोजें',
      'browse_wholesellers': 'थोक विक्रेताओं को ब्राउज़ करें और जुड़ें',
      'no_wholesellers_found': 'कोई थोक विक्रेता नहीं मिला',
      'search_wholesellers': 'थोक विक्रेता खोजें...',
      'connect': 'जुड़ें',
      'connected': 'जुड़ा हुआ',
      'view_products': 'उत्पाद देखें',
      'bills': 'बिल',
      'create_bill': 'बिल बनाएं',
      'ocr_scanner': 'ओसीआर स्कैनर',
      'manage_customer_bills': 'ग्राहक बिल बनाएं और प्रबंधित करें',
      'personal_information': 'व्यक्तिगत जानकारी',
      'business_information': 'व्यापारिक जानकारी',
      'account_type': 'खाता प्रकार',
      'account_status': 'खाता स्थिति',
      'registration_date': 'पंजीकरण तिथि',
      'update_profile': 'प्रोफ़ाइल अपडेट करें',
      'change_profile_picture': 'प्रोफ़ाइल चित्र बदलें',
      'shops': 'दुकानें',
      'documents': 'दस्तावेज़',
      'users': 'उपयोगकर्ता',
      'all_users': 'सभी उपयोगकर्ता',
      'pending_approvals': 'लंबित अनुमोदन',
      'approvals': 'अनुमोदन',
      'total_users': 'कुल उपयोगकर्ता',
      'search_users': 'उपयोगकर्ता खोजें...',
      'no_users_found': 'कोई उपयोगकर्ता नहीं मिला',
      'no_pending_approvals': 'कोई लंबित अनुमोदन नहीं',
      'approve': 'अनुमोदित करें',
      'reject': 'अस्वीकार करें',
      'welcome_admin': 'स्वागत एडमिन!',
      'welcome_wholeseller': 'स्वागत',
      'welcome_retailer': 'स्वागत',
      'manage_business_ecosystem': 'अपने व्यापारिक पारिस्थितिकी तंत्र का प्रबंधन करें',
      'manage_wholesale_business': 'अपने थोक व्यापार का प्रबंधन करें',
      'manage_retail_business': 'अपने खुदरा व्यापार का प्रबंधन करें',
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
      'view': 'பார்',
      'close': 'மூடு',
      'ok': 'சரி',
      'yes': 'ஆம்',
      'no': 'இல்லை',
      'login': 'உள்நுழை',
      'register': 'பதிவு',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'name': 'பெயர்',
      'phone': 'தொலைபேசி',
      'logout': 'வெளியேறு',
      'welcome_back': 'மீண்டும் வரவேற்கிறோம்!',
      'sign_in_to_continue': 'தொடர உள்நுழையவும்',
      'dont_have_account': 'கணக்கு இல்லையா? ',
      'please_enter_email': 'தயவுசெய்து உங்கள் மின்னஞ்சலை உள்ளிடவும்',
      'please_enter_valid_email': 'தயவுசெய்து சரியான மின்னஞ்சலை உள்ளிடவும்',
      'please_enter_password': 'தயவுசெய்து உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
      'password_min_length': 'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்',
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
      'profile': 'சுயவிவரம்',
      'quick_actions': 'விரைவு செயல்கள்',
      'recent_activity': 'சமீபத்திய செயல்பாடு',
      'no_recent_activity': 'சமீபத்திய செயல்பாடு இல்லை',
      'add_product': 'தயாரிப்பு சேர்',
      'product_name': 'தயாரிப்பு பெயர்',
      'description': 'விளக்கம்',
      'price': 'விலை',
      'quantity': 'அளவு',
      'category': 'வகை',
      'low_stock': 'குறைந்த இருப்பு',
      'total_products': 'மொத்த தயாரிப்புகள்',
      'active_products': 'செயலில் உள்ள தயாரிப்புகள்',
      'categories': 'வகைகள்',
      'all_categories': 'அனைத்து வகைகள்',
      'search_products': 'தயாரிப்புகளைத் தேடு...',
      'no_products_found': 'தயாரிப்புகள் எதுவும் கிடைக்கவில்லை',
      'pending': 'நிலுவையில்',
      'approved': 'அங்கீகரிக்கப்பட்டது',
      'rejected': 'நிராகரிக்கப்பட்டது',
      'wholesellers': 'மொத்த விற்பனையாளர்கள்',
      'find_wholesellers': 'மொத்த விற்பனையாளர்களைக் கண்டறியவும்',
      'browse_wholesellers': 'மொத்த விற்பனையாளர்களை உலாவி இணைக்கவும்',
      'no_wholesellers_found': 'மொத்த விற்பனையாளர்கள் எதுவும் கிடைக்கவில்லை',
      'search_wholesellers': 'மொத்த விற்பனையாளர்களைத் தேடு...',
      'connect': 'இணை',
      'connected': 'இணைக்கப்பட்டது',
      'view_products': 'தயாரிப்புகளைப் பார்',
      'bills': 'பில்கள்',
      'create_bill': 'பில் உருவாக்கு',
      'ocr_scanner': 'ஓசிஆர் ஸ்கேனர்',
      'manage_customer_bills': 'வாடிக்கையாளர் பில்களை உருவாக்கி நிர்வகிக்கவும்',
      'personal_information': 'தனிப்பட்ட தகவல்',
      'business_information': 'வணிக தகவல்',
      'account_type': 'கணக்கு வகை',
      'account_status': 'கணக்கு நிலை',
      'registration_date': 'பதிவு தேதி',
      'update_profile': 'சுயவிவரத்தைப் புதுப்பிக்கவும்',
      'change_profile_picture': 'சுயவிவர படத்தை மாற்றவும்',
      'shops': 'கடைகள்',
      'documents': 'ஆவணங்கள்',
      'users': 'பயனர்கள்',
      'all_users': 'அனைத்து பயனர்கள்',
      'pending_approvals': 'நிலுவையில் உள்ள அனுமதிகள்',
      'approvals': 'அனுமதிகள்',
      'total_users': 'மொத்த பயனர்கள்',
      'search_users': 'பயனர்களைத் தேடு...',
      'no_users_found': 'பயனர்கள் எதுவும் கிடைக்கவில்லை',
      'no_pending_approvals': 'நிலுவையில் உள்ள அனுமதிகள் இல்லை',
      'approve': 'அனுமதி',
      'reject': 'நிராகரி',
      'welcome_admin': 'வரவேற்கிறோம் நிர்வாகி!',
      'welcome_wholeseller': 'வரவேற்கிறோம்',
      'welcome_retailer': 'வரவேற்கிறோம்',
      'manage_business_ecosystem': 'உங்கள் வணிக சுற்றுச்சூழல் அமைப்பை நிர்வகிக்கவும்',
      'manage_wholesale_business': 'உங்கள் மொத்த வணிகத்தை நிர்வகிக்கவும்',
      'manage_retail_business': 'உங்கள் சில்லறை வணிகத்தை நிர்வகிக்கவும்',
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