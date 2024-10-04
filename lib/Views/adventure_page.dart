import 'package:flutter/material.dart';
import 'create_ad_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'home_page.dart';

class AdventurePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'Assets/image/banner.jpg',
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              _buildActivityCard(
                'Sunway Lagoon Surfing',
                'Learn to surf with our beginner lessons',
                'Rs. 5000',
                'Assets/image/surfing.png',
              ),
              _buildActivityCard(
                'Hiking at Rockwood',
                'Gain a memorable hiking experience',
                'Rs. 3450',
                'Assets/image/hike.png',
              ),
              _buildActivityCard(
                'Zip-lining at ella',
                'Enjoy a range of thrilling activities here',
                'Rs. 4500',
                'Assets/image/zip.png',
              ),
              _buildActivityCard(
                'Jetskiing - Bentota',
                'Enjoy a range of thrilling activities here',
                'Rs. 6000',
                'Assets/image/jetski.png',
              ),
              _buildActivityCard(
                'Sky Diving Experience',
                'Enjoy a range of thrilling activities here',
                'Rs. 9000',
                'Assets/image/skydive.png',
              ),
              _buildActivityCard(
                'Camping - Moon Plains',
                'Enjoy a range of thrilling activities here',
                'Rs. 5000',
                'Assets/image/camp.png',
              ),
              _buildActivityCard(
                'Hot Air Balloon Rides',
                'Enjoy a range of thrilling activities here',
                'Rs. 7450',
                'Assets/image/ballon.png',
              ),
              _buildActivityCard(
                'Rock Climbing Lessons',
                'Enjoy a range of thrilling activities here',
                'Rs. 8450',
                'Assets/image/climb.png',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateAdPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }


  Widget _buildActivityCard(String title, String description, String price, String imagePath) {
    return Card(
      margin: EdgeInsets.only(bottom: 20.0), //spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14.0),
                  ),
                  SizedBox(height: 10),
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
