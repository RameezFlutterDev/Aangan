import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'Account Issues',
    'Payment Problems',
    'Gameplay Tips',
    'Bug Reports',
    'Technical Support',
    'Updates',
  ];

  final List<FAQ> faqs = [
    FAQ('How to reset my password?',
        'Go to settings > Account > Reset Password.'),
    FAQ('How to report a bug?',
        'Visit the Bug Reports section and provide details.'),
    FAQ('What payment methods are supported?',
        'We support credit cards, PayPal, and Google Pay.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Help Topics',
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help Categories
              Text('Help Categories',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of items per row
                  crossAxisSpacing: 8, // Spacing between columns
                  mainAxisSpacing: 8, // Spacing between rows
                  childAspectRatio: 3.0, // Aspect ratio of each grid cell
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // Handle category selection
                      },
                      child: Center(
                        child: Text(
                          categories[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14), // Adjust text size
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // FAQs Section
              // Text('FAQs',
              //     style: GoogleFonts.poppins(
              //         fontSize: 18, fontWeight: FontWeight.bold)),
              // const SizedBox(height: 8),
              // SingleChildScrollView(
              //   child: ExpansionPanelList(
              //     expansionCallback: (int index, bool isExpanded) {
              //       setState(() {
              //         print("yes");
              //         faqs[index].isExpanded = !isExpanded;
              //       });
              //     },
              //     children: faqs.map((FAQ faq) {
              //       return ExpansionPanel(
              //         headerBuilder: (BuildContext context, bool isExpanded) {
              //           return ListTile(
              //             title: Text(
              //               faq.question,
              //               style: GoogleFonts.poppins(),
              //             ),
              //           );
              //         },
              //         body: ListTile(
              //           title: Text(faq.answer),
              //         ),
              //         isExpanded: faq.isExpanded,
              //       );
              //     }).toList(),
              //   ),
              // ),

              ListView.builder(
                itemCount: faqs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(faqs[index].question,
                        style: GoogleFonts.poppins()),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          faqs[index].answer,
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Contact Support
              ElevatedButton.icon(
                onPressed: () {
                  // Add your contact support functionality
                },
                icon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.headset_mic),
                ),
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Contact Support',
                    style: GoogleFonts.poppins(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQ {
  String question;
  String answer;

  FAQ(this.question, this.answer);
}
