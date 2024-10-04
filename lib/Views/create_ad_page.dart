import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../Widgets/bottomnav.dart';

class CreateAdPage extends StatefulWidget {
  @override
  _CreateAdPageState createState() => _CreateAdPageState();
}

class _CreateAdPageState extends State<CreateAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  final picker = ImagePicker();

  String _topic = '';
  String _description = '';
  String? _selectedCategory;
  String _city = '';
  String _price = '';
  File? _image;
  String _phoneNumber = '';

  bool _isSubmitting = false;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.16:8000/api/categories'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load categories')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred while fetching categories')));
    }
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            TextButton(
              child: Text('Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  if (pickedFile != null) {
                    _image = File(pickedFile.path);
                  }
                });
              },
            ),
            TextButton(
              child: Text('Camera'),
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                setState(() {
                  if (pickedFile != null) {
                    _image = File(pickedFile.path);
                  }
                });
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    String? token = await _storage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token not found')));
      return;
    }

    try {
      FormData formData = FormData.fromMap({
        'topic': _topic,
        'description': _description,
        'category_id': _selectedCategory,
        'city': _city,
        'price': _price,
        'phone_number': _phoneNumber,
        'image': _image != null
            ? await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last)
            : null,
      });

      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      dio.options.validateStatus = (status) {
        return status! < 500; // Allow redirections and client errors (302, 400, etc.)
      };

      final response = await dio.post('http://192.168.1.16:8000/api/ads', data: formData);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ad submitted for approval'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 302) {
        print("Redirection: ${response.headers['location']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Redirecting...')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit ad: ${response.statusCode}')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error occurred while submitting the ad')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        toolbarHeight: 80.0,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
          },
        ),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Topic',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a topic';
                  return null;
                },
                onSaved: (value) {
                  _topic = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a description';
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: _categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a city';
                  return null;
                },
                onSaved: (value) {
                  _city = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a price';
                  return null;
                },
                onSaved: (value) {
                  _price = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a phone number';
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : Icon(Icons.camera_alt, color: Colors.purple, size: 50),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAd,
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Submit Ad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 2),
    );
  }
}
