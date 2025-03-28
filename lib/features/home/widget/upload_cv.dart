import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class UploadCVWidget extends StatefulWidget {
  final Color mainColor;
  final VoidCallback onUploadSuccess;
  final String? uploadedCvUrl;
  final String? uploadedCvName;

  const UploadCVWidget({
    Key? key,
    required this.mainColor,
    required this.onUploadSuccess,
    this.uploadedCvUrl,
    this.uploadedCvName,
  }) : super(key: key);

  @override
  _UploadCVWidgetState createState() => _UploadCVWidgetState();
}

class _UploadCVWidgetState extends State<UploadCVWidget> {
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _uploadCV() async {
    try {
      setState(() => _isLoading = true);
      
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar('User not authenticated');
        setState(() => _isLoading = false);
        return;
      }
      
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
      
      // Read file as bytes and convert to base64
      List<int> fileBytes = await cvFile.readAsBytes();
      String base64File = base64Encode(fileBytes);
      
      // Print file info for debugging
      print('File name: ${file.name}, Size: ${fileBytes.length} bytes');
      
      // Send to backend API with more detailed error handling
      try {
        final response = await http.post(
          Uri.parse('https://hyresync-backend.vercel.app/upload_cv'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': currentUser.displayName ?? 'User',
            'uid': currentUser.uid,
            'cv_file_content': base64File,
            'cv_file_name': file.name,
          }),
        );
        
        print('Backend response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          // Save reference in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'cvName': file.name,
            'uploadDate': FieldValue.serverTimestamp(),
            'processedByBackend': true,
          }, SetOptions(merge: true));
          
          // Update state via callback
          widget.onUploadSuccess();
          
          _showSuccessSnackBar('CV uploaded and processed successfully!');
        } else {
          // Parse error response if possible
          Map<String, dynamic>? errorData;
          try {
            errorData = jsonDecode(response.body);
          } catch (e) {
            // If not valid JSON
            errorData = null;
          }
          
          String errorMessage = errorData != null && errorData.containsKey('message') 
              ? errorData['message'] 
              : 'Server error occurred';
              
          _showErrorSnackBar('Error processing CV: $errorMessage');
          print('Backend error details: ${response.body}');
        }
      } catch (networkError) {
        print('Network error: $networkError');
        _showErrorSnackBar('Network error: ${networkError.toString()}');
      }
    } catch (e) {
      print('Error uploading CV: ${e.toString()}');
      _showErrorSnackBar('Error uploading CV: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewCV() async {
    if (widget.uploadedCvUrl == null) return;
    
    try {
      final uri = Uri.parse(widget.uploadedCvUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open CV file');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening CV: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insert_drive_file_outlined, color: widget.mainColor),
                  const SizedBox(width: 12),
                  const Text(
                    'Resume / CV',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.uploadedCvUrl != null && widget.uploadedCvName != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.mainColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.mainColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: widget.mainColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.uploadedCvName!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Click to view',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.black54),
                        onPressed: _viewCV,
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No CV uploaded yet',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadCV,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.upload_file),
                    SizedBox(width: 12),
                    Text(
                      'Upload CV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Loading overlay
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.mainColor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}