import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xupstore/firebase_options.dart';
import 'package:xupstore/provider/DownloadPP/search_game_provider.dart';
import 'package:xupstore/views/Auth/auth_gate.dart';
import 'package:xupstore/views/Developer/dev_payment.dart';
import 'package:xupstore/views/Developer/dev_profile.dart';
import 'package:xupstore/views/Developer/payment_method.dart';
import 'package:xupstore/views/HelpCenter/help_center_screen.dart';
import 'package:xupstore/views/dashboard.dart';
import 'package:xupstore/views/downloadpage.dart';
import 'package:xupstore/views/Auth/login.dart';

import 'provider/DownloadPP/download_button_provider.dart';
import 'provider/DownloadPP/game_rating_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RatingProvider()),
        ChangeNotifierProvider(
          create: (context) => DownloadProvider(),
        ),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}
