import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.userModel != null) {
      final user = authProvider.userModel!;
      
      if (user.status != AccountStatus.approved) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      
      switch (user.userType) {
        case UserType.admin:
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
          break;
        case UserType.wholeseller:
          Navigator.pushReplacementNamed(context, '/wholeseller-dashboard');
          break;
        case UserType.retailer:
          Navigator.pushReplacementNamed(context, '/retailer-dashboard');
          break;
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9C88FF),
              Color(0xFF03DAC6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store,
                  size: 60,
                  color: Color(0xFF6C63FF),
                ),
              ).animate().scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'JK Plus',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(
                duration: 800.ms,
                delay: 300.ms,
              ).slideY(
                begin: 0.3,
                duration: 800.ms,
                delay: 300.ms,
                curve: Curves.easeOut,
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              Text(
                'Your Business Partner',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ).animate().fadeIn(
                duration: 800.ms,
                delay: 600.ms,
              ).slideY(
                begin: 0.3,
                duration: 800.ms,
                delay: 600.ms,
                curve: Curves.easeOut,
              ),
              
              const SizedBox(height: 64),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ).animate().fadeIn(
                duration: 800.ms,
                delay: 900.ms,
              ),
            ],
          ),
        ),
      ),
    );
  }
}