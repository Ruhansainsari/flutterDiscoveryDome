import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdService {
  final String baseUrl = 'http://192.168.1.16:8000/api'; // Replace with your backend URL
  final storage = FlutterSecureStorage();

  Future<List<dynamic>> getUserPendingAds() async {
    String? token = await storage.read(key: 'auth_token');

    final response = await http.get(
      Uri.parse('$baseUrl/user/pending-ads'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pending ads');
    }
  }

  // Future<List<dynamic>> fetchCityBasedAds() async {
  //   try {
  //     String? token = await storage.read(key: 'auth_token');
  //
  //     if (token == null) {
  //       throw Exception('User not authenticated. No token found.');
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/ads/recommended'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       throw Exception('Failed to load ads. Server responded with ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     throw Exception('Error fetching ads: $error');
  //   }
  // }
}
