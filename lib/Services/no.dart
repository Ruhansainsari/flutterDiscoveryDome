// import 'package:flutter/material.dart';
// import 'ad_service.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   late Future<List<dynamic>> recommendedAds;
//
//   @override
//   void initState() {
//     super.initState();
//     recommendedAds = AdService().fetchCityBasedAds();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         backgroundColor: Colors.purple,
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           Text(
//             'Recommendations',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           _buildRecommendationSection(),
//           SizedBox(height: 20),
//           // Add other sections like Popular, Offers, etc.
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRecommendationSection() {
//     return FutureBuilder<List<dynamic>>(
//       future: recommendedAds,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error fetching recommendations'));
//         } else {
//           final ads = snapshot.data ?? [];
//
//           return Container(
//             height: 150,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: ads.length,
//               itemBuilder: (context, index) {
//                 final ad = ads[index];
//
//                 return GestureDetector(
//                   onTap: () {
//                     // Navigate to ad details screen
//                   },
//                   child: Card(
//                     elevation: 4,
//                     child: Container(
//                       width: 200,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (ad['image'] != null)
//                             Image.network(
//                               ad['image'],
//                               width: 200,
//                               height: 100,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) =>
//                                   Icon(Icons.broken_image),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               ad['topic'],
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: Text('\$${ad['price']}'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//       },
//     );
//   }
// }
