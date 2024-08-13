import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'bluetooth_service.dart';
import 'hospital.dart'; // Import the HOS page
import 'location.dart'; // Import the HomeScreen

class TimerPage extends StatefulWidget {
  final LatLng? coordinates;

  TimerPage({this.coordinates});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int countdown = 10;
  late Timer _timer;
  List<String> emergencyEmails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
    startCountdown();
  }

  Future<void> _loadEmails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyEmails = prefs.getStringList('emergency_emails') ?? [];
    });
  }

  void startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _timer.cancel();
          sendEmailRequest();
          navigateToHospitalMailPage();
        }
      });
    });
  }

  Future<void> sendEmailRequest() async {
    const url =
        'https://ars-server-eight.vercel.app/send-email'; // works for anyone
    const name = 'Ajitha';
    final coordinates = {
      'latitude': widget.coordinates?.latitude.toString(),
      'longitude': widget.coordinates?.longitude.toString(),
    };

    for (var email in emergencyEmails) {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receiver_email': email,
          'name': name,
          'coordinates': coordinates,
        }),
      );

      if (response.statusCode == 200) {
        print('Email sent successfully to $email');
      } else {
        print('Failed to send email to $email');
      }
    }
  }

  void navigateToHospitalMailPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) => const HOS()), // Ensure this import is correct
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/alert.png',
              width: 150,
              height: 120,
            ),
            const SizedBox(height: 40.0),
            Align(
              alignment: Alignment.center,
              child: Text(
                'An Accident has been detected!',
                style: GoogleFonts.hammersmithOne(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40.0),
            Text(
              '$countdown',
              style: const TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // This takes you back to the previous page
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                textStyle: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}