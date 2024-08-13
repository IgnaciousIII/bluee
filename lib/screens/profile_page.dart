import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _numberController.text = prefs.getString('number') ?? '';
      _plateNumberController.text = prefs.getString('plate_number') ?? '';
      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('number', _numberController.text);
    await prefs.setString('plate_number', _plateNumberController.text);
    if (_profileImage != null) {
      await prefs.setString('profile_image', _profileImage!.path);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(directory.path, basename(pickedFile.path));
      final imageFile = await File(pickedFile.path).copy(imagePath);
      setState(() {
        _profileImage = imageFile;
      });
      _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                child: _profileImage == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              style: GoogleFonts.hammersmithOne(),
            ),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(labelText: 'Number'),
              keyboardType: TextInputType.phone,
              style: GoogleFonts.hammersmithOne(),
            ),
            TextField(
              controller: _plateNumberController,
              decoration: InputDecoration(labelText: 'Plate Number'),
              style: GoogleFonts.hammersmithOne(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProfile();
              },
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.hammersmithOne(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
