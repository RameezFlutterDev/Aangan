import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:xupstore/auth/auth_service.dart';
import 'package:xupstore/views/Auth/register.dart';
import 'package:xupstore/views/homepage.dart';
import 'package:xupstore/widgets/text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _pwcontroller = TextEditingController();

  final RoundedLoadingButtonController LoginbtnController =
      RoundedLoadingButtonController();

  Login({super.key});

  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseAuth instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _firestore.collection("users").doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'username': userCredential.user!.displayName,
        'status': 'Active'
      });

      // Navigate to Homepage after successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Homepage(userid: userCredential.user!.uid),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Google Sign-In Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logoa.png",
                height: 60,
                width: 120,
              ),
              Text(
                "Welcome to Aangan!",
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _emailcontroller,
                label: Text(
                  "Email",
                  style: GoogleFonts.poppins(),
                ),
                icn: const Icon(Icons.email_outlined),
                obscuretext: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _pwcontroller,
                label: Text(
                  "Password",
                  style: GoogleFonts.poppins(),
                ),
                icn: const Icon(Icons.password_outlined),
                obscuretext: true,
              ),
              const SizedBox(height: 10),
              RoundedLoadingButton(
                width: 2000,
                borderRadius: 10,
                controller: LoginbtnController,
                color: (Colors.grey.shade600),
                onPressed: () async {
                  final authService = AuthService();

                  try {
                    await authService.SignInWithEmailPassword(
                            _emailcontroller.text, _pwcontroller.text)
                        .then(
                      (value) {
                        print(value.user!.uid);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Homepage(userid: value.user!.uid),
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(title: Text(e.toString())),
                    );
                    LoginbtnController.reset();
                  }
                },
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _signInWithGoogle(context),
                icon: const Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
                label: Text(
                  "Sign in with Google",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Google-themed button color
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
