import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linkedin_login/linkedin_login.dart';

class LinkedInProfileWidget extends StatefulWidget {
  final User? currentUser;
  final Color mainColor;
  final Function(Map<String, dynamic>) onProfileImported;
  final Function(String) onErrorCallback;
  final bool hasLinkedInProfile;
  final Map<String, dynamic>? linkedInProfileData;

  const LinkedInProfileWidget({
    super.key,
    required this.currentUser,
    required this.mainColor,
    required this.onProfileImported,
    required this.onErrorCallback,
    this.hasLinkedInProfile = false,
    this.linkedInProfileData,
  });

  @override
  State<LinkedInProfileWidget> createState() => _LinkedInProfileWidgetState();
}

class _LinkedInProfileWidgetState extends State<LinkedInProfileWidget> {
  // LinkedIn configuration
  static const String redirectUrl = 'http://localhost:3000/linkedin-callback';
  static const String clientId = '78mzl0i0122xm8';
  static const String clientSecret = 'WPL_AP1.OWUCtGgt0JAf3DBz.eCkJlw==';

  Future<void> _importFromLinkedIn() async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LinkedInUserWidget(
            redirectUrl: redirectUrl,
            clientId: clientId,
            clientSecret: clientSecret,
            onGetUserProfile: (UserSucceededAction userAction) {
              final profileData = {
                'id': _safeGetValue(() => userAction.user.sub),
                'name': _safeGetValue(
                  () => "${userAction.user.givenName} ${userAction.user.familyName}",
                ),
                'firstName': _safeGetValue(() => userAction.user.givenName),
                'lastName': _safeGetValue(() => userAction.user.familyName),
                'email': _safeGetValue(() => userAction.user.email),
                'picture': _safeGetValue(() => userAction.user.picture),
                'importDate': FieldValue.serverTimestamp(),
              };

              _saveLinkedInProfile(profileData);
            },
            onError: (UserFailedAction e) {
              widget.onErrorCallback('LinkedIn import failed: ${e.toString()}');
            },
          ),
        ),
      );
    } catch (e) {
      widget.onErrorCallback('Error importing from LinkedIn: ${e.toString()}');
    }
  }

  T? _safeGetValue<T>(T? Function() getter) {
    try {
      return getter();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveLinkedInProfile(Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser!.uid)
          .set({'linkedInProfile': profileData}, SetOptions(merge: true));

      Navigator.pop(context);
      widget.onProfileImported(profileData);
    } catch (e) {
      widget.onErrorCallback('Error saving LinkedIn profile: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.import_contacts_rounded, 
                    color: const Color(0xFF0077B5), 
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'LinkedIn Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Existing LinkedIn Profile Display
              if (widget.hasLinkedInProfile && widget.linkedInProfileData != null)
                _buildLinkedInProfileView()
              else
                _buildEmptyStateView(),

              const SizedBox(height: 20),

              // Import Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _importFromLinkedIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.hasLinkedInProfile 
                          ? 'Reconnect LinkedIn' 
                          : 'Import from LinkedIn',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedInProfileView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0077B5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0077B5).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0077B5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.person_pin_rounded, 
              color: Colors.white, 
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.linkedInProfileData!['firstName'] ?? ''} ${widget.linkedInProfileData!['lastName'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.linkedInProfileData!['email'] ?? 'No email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off_rounded, 
            color: Colors.grey[600], 
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No LinkedIn profile connected',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Import your LinkedIn profile to enhance your professional details',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}