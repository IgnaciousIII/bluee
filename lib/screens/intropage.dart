import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'infopage.dart'; // Make sure this is the correct import for Infare

class Intropage extends StatefulWidget {
  const Intropage({super.key});

  @override
  _IntropageState createState() => _IntropageState();
}

class _IntropageState extends State<Intropage> {
  bool _visible = false;
  bool _fadeInOver = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250),
        () => setState(() => _visible = true));
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _fadeInOver = true;
        Future.delayed(const Duration(seconds: 6), () {
          setState(() => _fadeInOver = false);
        });
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _navigateToInfoPage();
      });
    });
  }

  void _navigateToInfoPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) {
        return const Infare(); // Navigate to the Infare page
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 160),
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                curve: Curves.easeIn,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/Vector.png',
                      width: 124,
                      height: 111,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Accident',
                          style: GoogleFonts.hammersmithOne(
                            color: Colors.black,
                            fontSize: 40.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Detection',
                          style: GoogleFonts.hammersmithOne(
                            color: Colors.red,
                            fontSize: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            curve: Curves.easeIn,
            color: _fadeInOver ? Colors.red : Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ],
      ),
    );
  }
}
