import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Widgets/bottomnav.dart';
import 'ad_detailpage.dart';
import 'create_ad_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic> _ads = [];
  List<dynamic> _suggestedAds = [];
  bool _isLoadingAds = true;
  bool _isLoadingSuggestedAds = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedAds();
    _fetchSuggestedAds();
  }

  Future<void> _fetchRecommendedAds() async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://192.168.1.16:8000/api/ads/approved/random'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _ads = json.decode(response.body);
          _isLoadingAds = false;
        });
      } else {
        setState(() {
          _isLoadingAds = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAds = false;
      });
    }
  }

  Future<void> _fetchSuggestedAds() async {
    try {
      String? token = await _storage.read(key: 'auth_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('http://192.168.1.16:8000/api/ads/approved/suggested'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _suggestedAds = json.decode(response.body);
          _isLoadingSuggestedAds = false;
        });
      } else {
        setState(() {
          _isLoadingSuggestedAds = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSuggestedAds = false;
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
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey there!',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 10),
                        _buildAdvertisementSection(context),
                        SizedBox(height: 20),
                        _isLoadingAds
                            ? Center(child: CircularProgressIndicator())
                            : _buildRecommendedAdsSection(),
                        SizedBox(height: 20),
                        _isLoadingSuggestedAds
                            ? Center(child: CircularProgressIndicator())
                            : _buildSuggestedAdsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Landscape mode
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildAdvertisementSection(context),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _isLoadingAds
                              ? Center(child: CircularProgressIndicator())
                              : _buildRecommendedAdsSection(),
                          SizedBox(height: 20),
                          _isLoadingSuggestedAds
                              ? Center(child: CircularProgressIndicator())
                              : _buildSuggestedAdsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildAdvertisementSection(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Advertising',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Launch your campaign, grow with us!',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateAdPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text(
                      'Post Ad',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              child: Image.asset(
                'Assets/image/stats.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedAdsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Ads',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _ads.length,
            itemBuilder: (context, index) {
              final ad = _ads[index];
              return _buildAdCard(ad);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedAdsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested For You',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestedAds.length,
            itemBuilder: (context, index) {
              final ad = _suggestedAds[index];
              return _buildAdCard(ad);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdCard(dynamic ad) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdDetailPage(adId: ad['id'])),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(ad['image'] ?? 'https://via.placeholder.com/160'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  ad['topic'] ?? 'Ad Title',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '\$${ad['price'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
