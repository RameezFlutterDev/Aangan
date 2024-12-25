import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xupstore/consts/themes.dart';
import 'package:xupstore/views/Developer/payment_method.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../consts/forward_buttons.dart';

class DevProfile extends StatefulWidget {
  const DevProfile({super.key});

  @override
  _DevProfileState createState() => _DevProfileState();
}

class _DevProfileState extends State<DevProfile> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _logoImage; // For the logo (avatar)
  File? _cnicImage; // For the CNIC upload

  // Function to pick an image for the logo
  Future<void> _pickLogoImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
      });
    }
  }

  // Function to pick an image for the CNIC
  Future<void> _pickCnicImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _cnicImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                'Developer Profile',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Avatar (Logo)
              GestureDetector(
                onTap: _pickLogoImage,
                child: AvatarGlow(
                  child: Material(
                    elevation: 8.0,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      radius: 50.0,
                      child: const Center(
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Information Containers
              _buildLabeledTextBox('Name', 'Enter your full name'),
              _buildLabeledTextBox('Store Name', 'Enter your store name'),
              _buildLabeledTextBox('Email', 'Enter your email'),
              _buildLabeledTextBox('NIC', 'Enter your NIC'),
              _buildLabeledTextBox('Contact', 'Enter your contact number'),
              const SizedBox(height: 20),
              // CNIC Upload Box
              GestureDetector(
                onTap: _pickCnicImage,
                child: Container(
                  alignment: Alignment.center,
                  width: 250,
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    children: [
                      _cnicImage != null
                          ? Image.file(_cnicImage!)
                          : Column(
                              children: [
                                const Icon(Icons.image,
                                    size: 50, color: Colors.white),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload NIC Image',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Next Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: 'Next',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentDetailsPage(),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build labeled text boxes
  Widget _buildLabeledTextBox(String label, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle:
                  GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
              filled: true,
              fillColor: textboxcolor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
