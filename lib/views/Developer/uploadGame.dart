import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class Uploadgame extends StatefulWidget {
  const Uploadgame({super.key});

  @override
  State<Uploadgame> createState() => _UploadgameState();
}

class _UploadgameState extends State<Uploadgame> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  File? _apkFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid uuid = Uuid();
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isPaid = false; // Indicates if the game is free or paid

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickApkFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _apkFile = File(result.files.single.path!);
      });
    } else {
      _showAlertDialog(context, "No APK file selected.");
    }
  }

  Future<void> _uploadGameDetails(String title, String description) async {
    if (_apkFile == null) {
      if (mounted) {
        _showAlertDialog(context, "Please select an APK file.");
      }
      return;
    }

    if (_isPaid && _priceController.text.trim().isEmpty) {
      _showAlertDialog(context, "Please enter the price for a paid game.");
      return;
    }

    String? apkUrl;

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final String gameId = uuid.v4();
      final storagePath = 'uploads/games/${user.uid}/$gameId';

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      final apkRef = _storage.ref().child(storagePath);
      final uploadTask = apkRef.putFile(
          _apkFile!,
          SettableMetadata(
              contentType: "application/vnd.android.package-archive"));

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (mounted) {
            setState(() {
              _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            _showAlertDialog(context, "Error during upload: ${error.message}");
          }
        },
      );

      await uploadTask;
      apkUrl = await apkRef.getDownloadURL();

      List<String> imageUrls = await _uploadImages(user.uid, gameId);

      await _firestore.collection('games').doc(gameId).set({
        'userid': user.uid,
        'gameid': gameId,
        'title': title,
        'description': description,
        'apkFileUrl': apkUrl,
        'gameImagesList': imageUrls,
        'storagePath': storagePath,
        'isPaid': _isPaid,
        'price': _isPaid ? double.parse(_priceController.text.trim()) : 0.0,
      });

      if (mounted) {
        _showAlertDialog(context, "Game uploaded successfully!");

        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (error) {
      if (mounted) {
        _showAlertDialog(context, "Upload failed: $error");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<List<String>> _uploadImages(String uid, String gameId) async {
    List<String> urls = [];
    for (File image in _images) {
      final ref =
          _storage.ref().child('uploads/games/$uid/$gameId/${uuid.v4()}.jpg');
      await ref.putFile(image);
      String url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xFF262635)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "Post a Game",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(width: 10),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildTextField("Enter game title", _titleController),
                    SizedBox(height: 16),
                    _buildTextField(
                        "Describe your game", _descriptionController,
                        maxLines: 4),
                    SizedBox(height: 16),
                    _buildFilePickerRow(
                        "APK File", Icons.insert_drive_file, _pickApkFile),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Is this game paid?",
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.white),
                        ),
                        Switch(
                          value: _isPaid,
                          onChanged: (value) {
                            setState(() {
                              _isPaid = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isPaid)
                      _buildTextField("Enter price", _priceController),
                    SizedBox(height: 16),
                    Text(
                      'Upload images',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    _buildImageGrid(),
                    SizedBox(height: 200),
                  ],
                ),
              ),
              if (_isUploading) _buildProgressIndicator(),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () {
                          String title = _titleController.text.trim();
                          String description =
                              _descriptionController.text.trim();

                          if (title.isEmpty) {
                            _showAlertDialog(
                                context, "Please enter the game title.");
                          } else if (description.isEmpty) {
                            _showAlertDialog(
                                context, "Please enter the game description.");
                          } else if (_images.isEmpty) {
                            _showAlertDialog(
                                context, "Please upload at least one image.");
                          } else if (_apkFile == null) {
                            _showAlertDialog(
                                context, "Please upload an APK file.");
                          } else {
                            _uploadGameDetails(title, description);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Publish',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildFilePickerRow(
      String label, IconData icon, Function() onPressed) {
    return Row(
      children: [
        Icon(icon, size: 40, color: Colors.white),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        Spacer(),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Choose file',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        for (File image in _images)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image:
                  DecorationImage(image: FileImage(image), fit: BoxFit.cover),
            ),
          ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: _uploadProgress),
          SizedBox(height: 10),
          Text(
            "Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
