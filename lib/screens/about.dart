import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.hammersmithOne(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/RNC.jpg', // Make sure you have this image in your assets folder
                width: 300,
                height: 300,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We at RnC of Manipal Institute of Technology firmly believe in safety of passengers and the driver while driving. We also believe in fast acting emergency services which is why this app was created. Not only would the hospital be informed regarding your accident but also those who consider your safety as their utmost priority.',
                style: GoogleFonts.hammersmithOne(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}
