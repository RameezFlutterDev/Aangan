import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final Text label;
  final Icon icn;
  final bool obscuretext;
  final TextEditingController controller;

  const MyTextField(
      {super.key,
      required this.label,
      required this.icn,
      required this.obscuretext,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        width: double.infinity,
        child: TextField(
          obscureText: obscuretext,
          controller: controller,
          decoration: InputDecoration(
              prefixIcon: icn,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: label,
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 1, color: Colors.grey)),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20))),
        ));
  }
}
