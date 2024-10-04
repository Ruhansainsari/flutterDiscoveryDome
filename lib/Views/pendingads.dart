import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../Widgets/bottomnav.dart';

class PendingAdsScreen extends StatefulWidget {
  @override
  _PendingAdsScreenState createState() => _PendingAdsScreenState();
}

class _PendingAdsScreenState extends State<PendingAdsScreen> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<dynamic> ads = [];
  bool isLoading = true;
  String adStatus = 'pending'; // To keep track of which ads to show

  @override
  void initState() {
    super.initState();
    fetchAds(); // Load the pending ads by default
  }

  // Fetch ads based on status
  Future<void> fetchAds() async {
    setState(() {
      isLoading = true;
    });

    String? token = await storage.read(key: 'auth_token');
    String apiUrl = 'http://192.168.1.16:8000/api/user/$adStatus-ads';

    var url = Uri.parse(apiUrl);
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        ads = jsonDecode(response.body);
      });
    } else {
      print('Failed to load ads: ${response.body}');
    }

    setState(() {
      isLoading = false;
    });
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
      body: Column(
        children: [
          // Tabs for pending, approved, and rejected ads
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton('Pending', Colors.orange),
                _buildTabButton('Approved', Colors.green),
                _buildTabButton('Rejected', Colors.red),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0), // Add padding around the GridView
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Display 2 ads per row
                  childAspectRatio: 0.7, // Adjust the aspect ratio to make it look better
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the image
                        ad['image'] != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.network(
                            ad['image'],
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.grey,
                          child: Center(child: Text('No Image')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ad['topic'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            ad['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '\$${ad['price']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 3),
    );
  }

  Widget _buildTabButton(String label, Color color) {
    return TextButton(
      onPressed: () {
        setState(() {
          adStatus = label.toLowerCase();
        });
        fetchAds(); // Fetch ads based on selected status
      },
      child: Text(
        label,
        style: TextStyle(
          color: adStatus == label.toLowerCase() ?  color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
