import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:xupstore/auth/auth_service.dart';
import 'package:xupstore/views/Auth/login.dart';

import '../../widgets/text_fields.dart';

class Register extends StatelessWidget {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _pwcontroller = TextEditingController();
  final TextEditingController _cpwcontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              const Icon(
                Icons.games,
                size: 60,
                color: Colors.purple,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Lets create an account for you",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: _emailcontroller,
                label: Text(
                  "Email",
                  style: GoogleFonts.poppins(),
                ),
                icn: const Icon(Icons.email_outlined),
                obscuretext: false,
              ),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _pwcontroller,
                  label: Text(
                    "Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: const Icon(Icons.password_outlined),
                  obscuretext: true),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                  controller: _cpwcontroller,
                  label: Text(
                    "Confirm Password",
                    style: GoogleFonts.poppins(),
                  ),
                  icn: const Icon(Icons.check_box_outlined),
                  obscuretext: true),
              const SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: _usernamecontroller,
                label: Text(
                  "Enter Username",
                  style: GoogleFonts.poppins(),
                ),
                icn: const Icon(Icons.person),
                obscuretext: false,
              ),
              const SizedBox(
                height: 10,
              ),
              RoundedLoadingButton(
                width: 2000,
                borderRadius: 10,
                controller: LoginbtnController,
                color: (Colors.grey.shade600),
                onPressed: () {
                  final authService = AuthService();
                  if (_pwcontroller.text == _cpwcontroller.text) {
                    try {
                      authService.SignUpWithEmailPassword(_emailcontroller.text,
                          _pwcontroller.text, _usernamecontroller.text);

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
                          const AlertDialog(title: Text("Password dont match")),
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
              const SizedBox(
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
