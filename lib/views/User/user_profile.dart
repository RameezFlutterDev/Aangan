import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xupstore/services/firestore_profilepage_services.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId; // Pass the userId to identify the user document

  const UserProfileScreen({super.key, required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _username;
  String? _email;
  String? _avatarUrl;
  final ImagePicker _picker = ImagePicker();
  final FirestoreProfilepageServices _profileServices =
      FirestoreProfilepageServices();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _updateProfile(String? newUsername, String? newAvatarUrl) async {
    await _profileServices.updateUserProfile(
        widget.userId, newUsername, newAvatarUrl);
    setState(() {
      _username = newUsername;
      _avatarUrl = newAvatarUrl;
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final userData = await _profileServices.getUserData(widget.userId);
    if (userData != null) {
      setState(() {
        _username = userData['username'];
        _email = userData['email'];
        _avatarUrl = userData['avatarUrl'];
      });
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarUrl = pickedFile
            .path; // Placeholder: handle storage upload for real cases
      });
    }
  }

  // Function to save profile changes locally
  // Example usage inside the save profile method
  void _saveProfile() {
    _updateProfile(_usernameController.text, _avatarUrl);
    Navigator.pop(context); // Close the edit dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('User Profile', style: GoogleFonts.poppins()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _avatarUrl != null
                      ? FileImage(File(_avatarUrl!))
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon:
                        const Icon(Icons.camera_alt, color: Color(0xff6d72ea)),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Username Display and Edit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Username:', style: GoogleFonts.poppins(fontSize: 18)),
                Row(
                  children: [
                    Text(
                      _username ?? 'Loading...',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xff6d72ea)),
                      onPressed: () {
                        _usernameController.text = _username ?? '';
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Edit Username',
                                  style: GoogleFonts.poppins()),
                              content: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'New Username',
                                  labelStyle: GoogleFonts.poppins(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: _saveProfile,
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Divider(),

            // Email Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email:', style: GoogleFonts.poppins(fontSize: 18)),
                Text(
                  _email ?? 'Loading...',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Divider(),

            const SizedBox(height: 30),

            // Edit Profile Button (Placeholder)
            ElevatedButton(
              onPressed: () {
                print("Edit Profile Button Pressed");
              },
              child: Text("Edit Profile", style: GoogleFonts.poppins()),
            ),

            const SizedBox(height: 15),

            // Account Settings
            Text(
              'Account Settings',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text('Change Password', style: GoogleFonts.poppins()),
              onTap: () {
                // Implement Change Password functionality
              },
            ),
            ListTile(
              title: Text('Two-Factor Authentication',
                  style: GoogleFonts.poppins()),
              onTap: () {
                // Implement Two-Factor Authentication functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
