import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:linkedin_login/linkedin_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './widget/upload_cv.dart';
import './widget/linkedIn_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Color mainColor = const Color(0xFF0057FF);
  bool _isLoading = false;
  User? currentUser;
  String? userName;
  String? userEmail;
  String? userPhotoUrl;
  String? uploadedCvUrl;
  String? uploadedCvName;
  bool _hasLinkedInProfile = false;
  Map<String, dynamic>? _linkedInProfileData;
  
  // Backend API URL
  final String _apiUrl = 'https://hyresync-backend.vercel.app/upload_cv';

  // LinkedIn configuration
  static const String redirectUrl = 'http://localhost:3000/linkedin-callback';
  static const String clientId =
      '78mzl0i0122xm8'; // Replace with your LinkedIn Client ID
  static const String clientSecret =
      'WPL_AP1.OWUCtGgt0JAf3DBz.eCkJlw=='; // Replace with your LinkedIn Client Secret

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // Get current Firebase user
      currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Set basic user info
        userName = currentUser!.displayName ?? 'User';
        userEmail = currentUser!.email;
        userPhotoUrl = currentUser!.photoURL;

        // Check if we already have CV data in Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('cvUrl')) {
            setState(() {
              uploadedCvUrl = userData['cvUrl'];
              uploadedCvName = userData['cvName'];
            });
          }

          if (userData != null && userData.containsKey('linkedInProfile')) {
            setState(() {
              _hasLinkedInProfile = true;
              _linkedInProfileData = userData['linkedInProfile'];
            });
          }
        }

        // Store user details in local cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', userName!);
        prefs.setString('userEmail', userEmail ?? '');
        if (userPhotoUrl != null) {
          prefs.setString('userPhotoUrl', userPhotoUrl!);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading user data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // New method to extract text from CV file
  Future<String?> _extractTextFromFile(File file) async {
    try {
      // This is a placeholder. In a real implementation, you would use
      // packages like syncfusion_flutter_pdf for PDFs or other packages for docx
      // For now, we'll just return a placeholder message
      return "CV text extraction would happen here in a real implementation";
    } catch (e) {
      print('Error extracting text from file: $e');
      return null;
    }
  }

  // New method to send CV data to backend API
  Future<void> _sendCvToBackend({
    required String username,
    required String uid,
    String? cvText,
    String? cvFileName,
    Map<String, dynamic>? linkedInData,
  }) async {
    try {
      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'username': username,
        'uid': uid,
      };

      // Add optional parameters if available
      if (cvText != null) {
        requestBody['cv_text'] = cvText;
      }
      
      if (cvFileName != null) {
        requestBody['cv_file_name'] = cvFileName;
      }
      
      if (linkedInData != null) {
        requestBody['linkedin_data'] = {
          'profile_url': linkedInData['id'] != null ? 'https://www.linkedin.com/in/${linkedInData['id']}' : null,
          'summary': null, // LinkedIn API doesn't provide this directly
          'experience': null, // LinkedIn API doesn't provide this directly
          'education': null, // LinkedIn API doesn't provide this directly
          'skills': null, // LinkedIn API doesn't provide this directly
          'certifications': null, // LinkedIn API doesn't provide this directly
          'name': linkedInData['name'],
          'email': linkedInData['email'],
        };
      }

      // Send request to backend
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('CV processed successfully with backend');
        final responseData = jsonDecode(response.body);
        print('Backend response: $responseData');
      } else {
        print('Failed to process CV with backend: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error processing CV with backend: $e');
    }
  }

  Future<void> _uploadCV() async {
    try {
      setState(() => _isLoading = true);

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      PlatformFile file = result.files.first;

      if (file.path == null) {
        _showErrorSnackBar('File path is invalid');
        setState(() => _isLoading = false);
        return;
      }

      // Get file reference
      File cvFile = File(file.path!);
      String fileName = '${currentUser!.uid}_${path.basename(file.path!)}';

      // Extract text from CV file (placeholder implementation)
      String? cvText = await _extractTextFromFile(cvFile);

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('cvs/$fileName');
      await storageRef.putFile(cvFile);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Save URL to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({
            'cvUrl': downloadUrl,
            'cvName': file.name,
            'uploadDate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Update state
      setState(() {
        uploadedCvUrl = downloadUrl;
        uploadedCvName = file.name;
      });

      // Send CV data to backend API
      await _sendCvToBackend(
        username: userName ?? 'User',
        uid: currentUser!.uid,
        cvText: cvText,
        cvFileName: file.name,
        linkedInData: _linkedInProfileData,
      );

      _showSuccessSnackBar('CV uploaded successfully!');
    } catch (e) {
      _showErrorSnackBar('Error uploading CV: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Modified method to save LinkedIn profile and send to backend
  Future<void> _saveLinkedInProfile(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({'linkedInProfile': profileData}, SetOptions(merge: true));

      setState(() {
        _hasLinkedInProfile = true;
        _linkedInProfileData = profileData;
      });

      // Send LinkedIn data to backend if CV is already uploaded
      if (uploadedCvUrl != null && uploadedCvName != null) {
        await _sendCvToBackend(
          username: userName ?? 'User',
          uid: currentUser!.uid,
          cvFileName: uploadedCvName,
          linkedInData: profileData,
        );
      }

      // Close the LinkedIn login page
      Navigator.pop(context);
      _showSuccessSnackBar('LinkedIn profile imported successfully!');
    } catch (e) {
      _showErrorSnackBar('Error saving LinkedIn profile: ${e.toString()}');
    }
  }

  Future<void> _importFromLinkedIn() async {
    try {
      setState(() => _isLoading = true);

      // Navigate to LinkedIn login page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (BuildContext context) => LinkedInUserWidget(
                redirectUrl: redirectUrl,
                clientId: clientId,
                clientSecret: clientSecret,
                onGetUserProfile: (UserSucceededAction userAction) {
                  // Extract profile information using the current LinkedIn API structure
                  final profileData = {
                    'id': _safeGetValue(() => userAction.user.sub),
                    'name': _safeGetValue(
                      () =>
                          "${userAction.user.givenName} ${userAction.user.familyName}",
                    ),
                    'firstName': _safeGetValue(() => userAction.user.givenName),
                    'lastName': _safeGetValue(() => userAction.user.familyName),
                    'email': _safeGetValue(() => userAction.user.email),
                    'picture': _safeGetValue(() => userAction.user.picture),
                    'importDate': FieldValue.serverTimestamp(),
                  };

                  // Save LinkedIn profile data to Firestore
                  _saveLinkedInProfile(profileData);
                },
                onError: (UserFailedAction e) {
                  _showErrorSnackBar('LinkedIn import failed: ${e.toString()}');
                },
              ),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error importing from LinkedIn: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Utility method to safely get values
  T? _safeGetValue<T>(T? Function() getter) {
    try {
      return getter();
    } catch (e) {
      return null;
    }
  }

  // Save LinkedIn profile to Firestore
  Future<void> _saveLinkedInProfileData(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({'linkedInProfile': profileData}, SetOptions(merge: true));

      setState(() {
        _hasLinkedInProfile = true;
        _linkedInProfileData = profileData;
      });

      // Close the LinkedIn login page
      Navigator.pop(context);
      _showSuccessSnackBar('LinkedIn profile imported successfully!');
    } catch (e) {
      _showErrorSnackBar('Error saving LinkedIn profile: ${e.toString()}');
    }
  }

  Future<void> _viewCV() async {
    if (uploadedCvUrl == null) return;

    try {
      final uri = Uri.parse(uploadedCvUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open CV file');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening CV: ${e.toString()}');
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.signOut();

      // Clear local cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      _showErrorSnackBar('Error signing out: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'HyreSync',
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.0,
                                0.3,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.0,
                                  0.3,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: _buildProfileSection(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // CV Upload Section
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.2,
                                0.5,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.2,
                                  0.5,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: _buildUploadSection(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // LinkedIn Import Section
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.3,
                                0.6,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(
                                  0.3,
                                  0.6,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: _buildLinkedInSection(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: mainColor.withOpacity(0.1),
            backgroundImage:
                userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
            child:
                userPhotoUrl == null
                    ? Icon(Icons.person, size: 40, color: mainColor)
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            userName ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail ?? '',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return UploadCVWidget(
      mainColor: mainColor,
      uploadedCvUrl: uploadedCvUrl,
      uploadedCvName: uploadedCvName,
      onUploadSuccess: () {
        // Optionally reload user data or update state
        _loadUserData();
      },
    );
  }

  Widget _buildLinkedInSection() {
    return LinkedInProfileWidget(
      currentUser: currentUser,
      mainColor: mainColor,
      onProfileImported: (profileData) {
        setState(() {
          _hasLinkedInProfile = true;
          _linkedInProfileData = profileData;
        });
        _showSuccessSnackBar('LinkedIn profile imported successfully!');
      },
      onErrorCallback: (errorMessage) {
        _showErrorSnackBar(errorMessage);
      },
    );
  }
}
