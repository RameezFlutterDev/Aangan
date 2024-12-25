import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the Google Fonts package
import 'package:xupstore/consts/forward_buttons.dart';
import 'package:xupstore/views/Developer/dev_payment.dart';
import '../../consts/themes.dart';

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String? selectedPaymentMethod;
  String? selectedBank;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController accountTitleController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();

  // List of Pakistani banks
  List<String> pakistaniBanks = [
    'Allied Bank Limited',
    'Askari Bank Limited',
    'Bank Alfalah',
    'Bank Al Habib',
    'Bank of Punjab',
    'Faysal Bank',
    'Habib Bank Limited',
    'MCB Bank',
    'Meezan Bank',
    'National Bank of Pakistan',
    'Silk Bank',
    'Standard Chartered Bank',
    'UBL (United Bank Limited)',
    'Summit Bank',
    'JS Bank',
    'Sindh Bank',
    'Al Baraka Bank',
  ];

  List<String> get bankOptions {
    // If Easy Paisa or Jazz Cash is selected, use it as the only bank option
    if (selectedPaymentMethod == 'Easy Paisa' ||
        selectedPaymentMethod == 'Jazz Cash') {
      return [selectedPaymentMethod!];
    }
    // Otherwise, show the list of Pakistani banks
    return pakistaniBanks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Use a Form widget
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Page Title
                  Center(
                    child: Text(
                      'Your Account Details',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Payment Method Label
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Payment Method Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
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
                    ),
                    hint: Text(
                      'Select method',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    items: ['Bank Account', 'Easy Paisa', 'Jazz Cash']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value;
                        selectedBank = null; // Reset bank selection
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a payment method';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bank Name Dropdown
                  Text(
                    'Bank Name',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
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
                    ),
                    hint: Text(
                      'Select Bank',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    items: bankOptions
                        .map((bank) => DropdownMenuItem(
                              value: bank,
                              child: Text(bank),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                      });
                    },
                    value: selectedBank,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a bank';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Account Title
                  Text(
                    'Account Title',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: accountTitleController,
                    decoration: InputDecoration(
                      hintText: 'Account Title',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an account title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Account No
                  Text(
                    'Account No.',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: accountNoController,
                    decoration: InputDecoration(
                      hintText: 'Account No.',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your account number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Next Button
                  Center(
                    child: CustomButton(
                      text: 'Next',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentAccessScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
