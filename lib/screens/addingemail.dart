import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddingEmailPage extends StatefulWidget {
  @override
  _AddingEmailPageState createState() => _AddingEmailPageState();
}

class _AddingEmailPageState extends State<AddingEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  final List<String> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emails.addAll(prefs.getStringList('emergency_emails') ?? []);
    });
  }

  Future<void> _saveEmails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergency_emails', _emails);
  }

  void _addEmail() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _emails.add(_emailController.text);
        _emailController.clear();
      });
      _saveEmails();
    }
  }

  void _removeEmail(int index) {
    setState(() {
      _emails.removeAt(index);
    });
    _saveEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Emergency Emails'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addEmail,
            child: Text('Add Email'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _emails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_emails[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEmail(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
