import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:xupstore/auth/auth_service.dart';
import 'package:xupstore/views/Auth/login.dart';

import '../../widgets/text_fields.dart';

class Register extends StatelessWidget {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _cpwcontroller = TextEditingController();
  TextEditingController _usernamecontroller = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RoundedLoadingButtonController LoginbtnController =
      RoundedLoadingButtonController();

  Register({super.key});

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
              Icon(
                Icons.games,
                size: 60,
                color: Colors.purple,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Lets create an account for you",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: _emailcontroller,
                label: Text(
                  "Email",
                  style: GoogleFonts.poppins(),
                ),
                icn: Icon(Icons.email_outlined),
                obscuretext: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _pwcontroller,
                  label: Text(
                    "Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: Icon(Icons.password_outlined),
                  obscuretext: true),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _cpwcontroller,
                  label: Text(
                    "Confirm Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: Icon(Icons.check_box_outlined),
                  obscuretext: true),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: _usernamecontroller,
                label: Text(
                  "Enter Username",
                  style: GoogleFonts.poppins(),
                ),
                icn: Icon(Icons.person),
                obscuretext: false,
              ),
              SizedBox(
                height: 10,
              ),
              RoundedLoadingButton(
                width: 2000,
                borderRadius: 10,
                controller: LoginbtnController,
                color: (Colors.grey.shade600),
                onPressed: () {
                  final _authService = AuthService();
                  if (_pwcontroller.text == _cpwcontroller.text) {
                    try {
                      _authService.SignUpWithEmailPassword(
                          _emailcontroller.text,
                          _pwcontroller.text,
                          _usernamecontroller.text);

                      // _authService.SignInWithEmailPassword(
                      //     _emailcontroller.text, _pwcontroller.text);

                      LoginbtnController.success();
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(title: Text(e.toString())),
                      );

                      LoginbtnController.reset();
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(title: Text("Password dont match")),
                    );
                    LoginbtnController.reset();
                  }
                },
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a member? ",
                    style: GoogleFonts.poppins(),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                    },
                    child: Text(
                      "Log In",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
