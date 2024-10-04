import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Widgets/bottomnav.dart';

class EditPersonalDataScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String city;

  EditPersonalDataScreen({
    required this.firstName,
    required this.lastName,
    required this.city,
  });

  @override
  _EditPersonalDataScreenState createState() => _EditPersonalDataScreenState();
}

class _EditPersonalDataScreenState extends State<EditPersonalDataScreen> {
  final storage = FlutterSecureStorage();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _cityController = TextEditingController(text: widget.city);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    String? token = await storage.read(key: 'auth_token');

    if (token != null) {
      final response = await http.post(
        Uri.parse('http://192.168.1.16:8000/api/user/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'city': _cityController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data.toString()),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 80.0,
        titleSpacing: 0,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: Image.asset(
              'Assets/image/logo2.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Your Personal Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                prefixIcon: Icon(Icons.person, color: Colors.purple),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                prefixIcon: Icon(Icons.person_outline, color: Colors.purple),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city, color: Colors.purple),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: _updateProfile,
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
    );
  }
}
