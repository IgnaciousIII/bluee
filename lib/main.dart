import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv package

import 'screens/intropage.dart'; // Import Intropage

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure WidgetsFlutterBinding is initialized

  try {
    // Load the .env file
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print("Environment variables loaded successfully");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Failed to load .env file: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Intropage(), // Start with Intropage
    );
  }
}
