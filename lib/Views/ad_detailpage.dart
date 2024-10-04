import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Widgets/bottomnav.dart';

class AdDetailPage extends StatefulWidget {
  final int adId;

  AdDetailPage({required this.adId});

  @override
  _AdDetailPageState createState() => _AdDetailPageState();
}

class _AdDetailPageState extends State<AdDetailPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? adDetails;
  bool isLoading = true;
  List<dynamic> reviews = [];
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  late TabController _tabController;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchAdDetails();
    fetchReviews();
    _tabController = TabController(length: 2, vsync: this);
  }

  //  ad details
  Future<void> fetchAdDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.16:8000/api/ads/${widget.adId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        adDetails = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load ad details');
    }
  }

  Future<void> fetchReviews() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('http://192.168.1.16:8000/api/ads/${widget.adId}/ratings'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        reviews = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // submit a new rating and review
  Future<void> submitReview() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.post(
      Uri.parse('http://192.168.1.16:8000/api/ads/${widget.adId}/rating'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'rating': _ratingController.text,
        'review': _reviewController.text,
      }),
    );

    if (response.statusCode == 201) {
      _ratingController.clear();
      _reviewController.clear();
      fetchReviews();//to refresh
    } else {
      throw Exception('Failed to submit review');
    }
  }



  // share the ad details
  void shareAdDetails() {
    if (adDetails != null) {
      final String adTopic = adDetails!['topic'];
      final String adDescription = adDetails!['description'];
      final String adPrice = adDetails!['price'].toString();
      final String adCity = adDetails!['city'];
      final String adPhoneNumber = adDetails!['phone_number'];
      final String adImage = adDetails!['image'] ?? '';
      final String adUrl = 'http://192.168.1.16:8000/api/ads/${widget.adId}';

      Share.share(
        'Check out this ad on OurApp!\n\n'
            'Topic: $adTopic\n'
            'Description: $adDescription\n'
            'Price: \$${adPrice}\n'
            'City: $adCity\n'
            'Contact: $adPhoneNumber\n\n'
            'View more:\n $adUrl\n\n'
            'See image:\n $adImage',
        subject: 'Ad: $adTopic',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: shareAdDetails,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('Ad Details', style: TextStyle(color: Colors.white))),
            Tab(child: Text('Ad Reviews', style: TextStyle(color: Colors.white))),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ad Details Tab
          isLoading
              ? Center(child: CircularProgressIndicator())
              : adDetails == null
              ? Center(child: Text('Ad not found'))
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ad Image
                Stack(
                  children: [
                    Image.network(adDetails!['image'] ?? '', height: 280, width: double.infinity, fit: BoxFit.cover),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(adDetails!['topic'] ?? 'Ad Topic', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailCard(icon: Icons.description, label: 'Description', value: adDetails!['description'] ?? 'No description available.'),
                      _buildDetailCard(icon: Icons.monetization_on, label: 'Price', value: '\$${adDetails!['price']}'),
                      _buildDetailCard(icon: Icons.location_on, label: 'City', value: adDetails!['city'] ?? 'Not available'),
                      _buildDetailCard(icon: Icons.phone, label: 'Call Now', value: adDetails!['phone_number'] ?? 'Not available', isContactCard: true),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ad Reviews Tab
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Submit Your Review',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Rating (1-5)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _ratingController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      hintText: 'Enter rating',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow[700],
                                  size: 28,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Review Input
                            Text(
                              'Review',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _reviewController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Write your review here',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              maxLines: 3,
                            ),
                            SizedBox(height: 24),

                            // Submit Button
                            Center(
                              child: ElevatedButton(
                                onPressed: submitReview,
                                child: Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


                // Displaying ratings and reviews
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            // Review content
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${review['user']['first_name']} ${review['user']['last_name']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    review['review'],
                                    style: TextStyle(fontSize: 14,  color: Theme.of(context).colorScheme.onBackground,),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${review['created_at'].substring(0, 10)}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 16,
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.yellow[700], size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    '${review['rating']} / 5',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: 1),
    );
  }

  //  method for detail card
  Widget _buildDetailCard({required IconData icon, required String label, required String value, bool isContactCard = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isContactCard ? Colors.green : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isContactCard ? Colors.green : null,
        ),
        title: Text(label),
        subtitle: Text(value),
        onTap: isContactCard ? () => launch('tel:$value') : null,
      ),
    );
  }
}
