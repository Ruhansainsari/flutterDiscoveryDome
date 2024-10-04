import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Widgets/bottomnav.dart';
import 'ad_detailpage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List ads = [];
  String searchTopic = '';
  String searchCity = '';
  bool isLoading = true; // To manage loading state

  // Fetch approved ads from the backend
  Future<void> fetchApprovedAds() async {
    final response = await http.get(Uri.parse('http://192.168.1.16:8000/api/ads/approved'));

    if (response.statusCode == 200) {
      setState(() {
        ads = json.decode(response.body);
        isLoading = false; // Set loading to false after fetching
      });
    } else {
      throw Exception('Failed to load ads');
    }
  }

  // Search ads by topic and city
  Future<void> searchAds() async {
    setState(() {
      isLoading = true; // Set loading to true when starting search
    });

    final response = await http.get(
      Uri.parse('http://192.168.1.16:8000/api/ads/search?topic=$searchTopic&city=$searchCity'),
    );

    if (response.statusCode == 200) {
      setState(() {
        ads = json.decode(response.body);
        isLoading = false; // Set loading to false after searching
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchApprovedAds(); // Load all approved ads on page load
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search Fields
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: 'Search by Topic',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.topic, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: searchAds,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                onChanged: (value) {
                  setState(() {
                    searchTopic = value;
                  });
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent, // Make background transparent to blend with container
                  hintText: 'Search by City',
                  hintStyle: TextStyle(color: Colors.grey[600]), // Hint text style
                  prefixIcon: Icon(Icons.location_city, color: Colors.grey), // Change icon color to grey
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: searchAds,
                  ),
                  border: InputBorder.none, // No border
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15), // Adjusted padding
                ),
                onChanged: (value) {
                  setState(() {
                    searchCity = value;
                  });
                },
              ),
            ),
            // Ads List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Loading Indicator
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  childAspectRatio: 0.7, // Aspect ratio of the cards
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Navigate to AdDetailPage on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdDetailPage(adId: ad['id']),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Display
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ad['image'] != null
                                  ? Image.network(ad['image'], height: 120, width: double.infinity, fit: BoxFit.cover)
                                  : Icon(Icons.image_not_supported, size: 100),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ad['topic'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('\$${ad['price']}', style: TextStyle(color: Colors.green)),
                            Text('${ad['city']}', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1),
    );
  }
}
