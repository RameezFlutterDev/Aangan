import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xupstore/views/Auth/login.dart';
import 'package:xupstore/views/dashboard.dart';
import 'package:xupstore/views/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String userid = FirebaseAuth.instance.currentUser!.uid;
            print(userid);
            return Homepage(
              userid: userid,
            );
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
