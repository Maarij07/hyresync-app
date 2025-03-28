import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyresync/features/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

// Move the _storeUserDetails method inside the _SignInState class
class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Color mainColor = const Color(0xFF0057FF);
  bool _isGoogleHovered = false;
  bool _isAppleHovered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Google Sign-In method
  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      
      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        setState(() => _isLoading = false);
        return;
      }
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Store user details in Firestore if it's a new user
      if (userCredential.user != null) {
        await _storeUserDetails(userCredential.user!);
      }
      
      // Navigate to home screen on success
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // Handle errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  // Apple Sign-In method
  Future<void> _signInWithApple() async {
    try {
      setState(() => _isLoading = true);
      
      // Check if Apple Sign In is available (mainly for iOS)
      final isAvailable = await SignInWithApple.isAvailable();
      
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }
      
      // Request credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create OAuthCredential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      
      // Sign in with Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      
      // Store user details in Firestore if it's a new user
      if (userCredential.user != null) {
        await _storeUserDetails(userCredential.user!);
      }
      
      // Navigate to home screen on success
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // Handle errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          // Logo and welcome text with animation
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.scatter_plot_rounded,
                                    size: 60,
                                    color: mainColor,
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Welcome',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Sign in to continue',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          // Sign-in buttons with animation
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Google sign-in button
                                  GestureDetector(
                                    onTap: _isLoading ? null : _signInWithGoogle,
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => _isGoogleHovered = true),
                                      onExit: (_) => setState(() => _isGoogleHovered = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          boxShadow: _isGoogleHovered
                                              ? [
                                                  BoxShadow(
                                                    color: mainColor.withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.g_mobiledata,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Continue with Google',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Apple sign-in button
                                  GestureDetector(
                                    onTap: _isLoading ? null : _signInWithApple,
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => _isAppleHovered = true),
                                      onExit: (_) => setState(() => _isAppleHovered = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: _isAppleHovered
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.apple,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Continue with Apple',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          // Privacy policy text with animation
                          FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'By continuing, you agree to our Terms of Service and Privacy Policy',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Move the _storeUserDetails method inside the _SignInState class
Future<void> _storeUserDetails(User user) async {
  try {
    // Store in Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'displayName': user.displayName ?? 'User',
      'email': user.email,
      'photoURL': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    // Store in SharedPreferences for local access
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', user.uid);
    prefs.setString('displayName', user.displayName ?? 'User');
    if (user.email != null) prefs.setString('email', user.email!);
    if (user.photoURL != null) prefs.setString('photoURL', user.photoURL!);
  } catch (e) {
    print('Error storing user details: $e');
  }
}