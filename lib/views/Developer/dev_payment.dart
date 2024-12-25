import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:xupstore/consts/forward_buttons.dart';
import '../../consts/themes.dart';

class PaymentAccessScreen extends StatefulWidget {
  const PaymentAccessScreen({super.key});

  @override
  _PaymentAccessScreenState createState() => _PaymentAccessScreenState();
}

class _PaymentAccessScreenState extends State<PaymentAccessScreen> {
  String? selectedPaymentMethod;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pay and be a Developer', style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Label
                  Text(
                    'Select Payment Method',
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
                    ),
                    hint: Text(
                      'Select method',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    items: ['Card', 'EasyPaisa']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value;
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

                  // Amount Input
                  Text(
                    'Amount (PKR)',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                      filled: true,
                      fillColor: textboxcolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Card Number Input
                  if (selectedPaymentMethod == 'Card') ...[
                    Text(
                      'Card Number',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        hintText: 'Enter your card number',
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                        filled: true,
                        fillColor: textboxcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Expiry Date Input
                    Text(
                      'Expiry Date (MM/YY)',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: expiryDateController,
                      decoration: InputDecoration(
                        hintText: 'MM/YY',
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                        filled: true,
                        fillColor: textboxcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // CVV Input
                    Text(
                      'CVV',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        hintText: 'Enter CVV',
                        hintStyle:
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                        filled: true,
                        fillColor: textboxcolor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your CVV';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Submit Button
                  Center(
                    child: CustomButton(
                      text: 'Proceed to Payment',
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Handle payment processing here
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Payment Successful'),
                                content: const Text(
                                    'Thank you for your payment! You now have access to upload your games.'),
                                actions: [
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Navigate to the game upload screen
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => GameUploadScreen()));
                                    },
                                  ),
                                ],
                              );
                            },
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
