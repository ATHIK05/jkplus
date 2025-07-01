import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/wholeseller/wholeseller_dashboard.dart';
import 'screens/retailer/retailer_dashboard.dart';
import 'utils/app_theme.dart';
import 'utils/app_localizations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final prefs = await SharedPreferences.getInstance();
  runApp(JKPlusApp(prefs: prefs));
}

class JKPlusApp extends StatelessWidget {
  final SharedPreferences prefs;

  const JKPlusApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer3<ThemeProvider, LanguageProvider, AuthProvider>(
        builder: (context, themeProvider, languageProvider, authProvider, child) {
          return MaterialApp(
            title: 'JK Plus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
              Locale('ta', ''),
            ],
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/admin-dashboard': (context) => const AdminDashboard(),
              '/wholeseller-dashboard': (context) => const WholesellerDashboard(),
              '/retailer-dashboard': (context) => const RetailerDashboard(),
            },
          );
        },
      ),
    );
  }
}