import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../Theme Provider/dark_theme_provider.dart';
import 'editprofile.dart';
import 'login_screen.dart';
import 'pendingads.dart';
import '../Widgets/bottomnav.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = FlutterSecureStorage();
  String firstName = '';
  String lastName = '';
  String email = '';
  String city = '';
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    String? token = await storage.read(key: 'auth_token');

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://192.168.1.16:8000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstName = data['first_name'];
          lastName = data['last_name'];
          email = data['email'];
          city = data['city'];
        });
      }
    }
  }

  Future<void> _logout() async {
    await storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () {},
        ),
        backgroundColor: Colors.purple,
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return _buildPortraitLayout();
          } else {
            return _buildLandscapeLayout();
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('Assets/image/pfp.jpg'),
            child: Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.purple,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 30),
          SwitchListTile(
            title: Text("Enable Dark Mode"),
            value: isDarkMode,
            onChanged: (value) {
              setState(() {
                isDarkMode = value;
                DarkThemeProvider.toggleTheme(isDarkMode);
              });
            },
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.purple,
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person, color: Colors.purple),
            title: Text('Personal Data'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPersonalDataScreen(
                    firstName: firstName,
                    lastName: lastName,
                    city: city,
                  ),
                ),
              ).then((_) => _getUserProfile());
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.ad_units, color: Colors.purple),
            title: Text('My Ads'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PendingAdsScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('Assets/image/pfp.jpg'),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.purple),
                title: Text('Personal Data'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPersonalDataScreen(
                        firstName: firstName,
                        lastName: lastName,
                        city: city,
                      ),
                    ),
                  ).then((_) => _getUserProfile());
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.ad_units, color: Colors.purple),
                title: Text('My Ads'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PendingAdsScreen()),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
              Divider(),
            ],
          ),
        ),
      ],
    );
  }
}
