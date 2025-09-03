import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/categories.dart';
import '../models/user_interest.dart';

class ApiService {
  static const String baseUrl = 'https://breach-api.qa.mvm-tech.xyz/api/';
  static const String wsUrl = 'wss://breach-api-ws.qa.mvm-tech.xyz';

  // Authentication
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // Extract user-friendly error message from response body
        String errorMessage = 'Registration failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        // Re-throw the parsed error message
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else { 
        String errorMessage = 'Login failed';
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        throw Exception(e.toString().replaceFirst('Exception: ', ''));
      }
      throw Exception('Network error: $e');
    }
  }

  // Posts
  Future<List<Post>> getPosts({int? categoryId}) async {
    try {
      String url = '$baseUrl/blog/posts';
      if (categoryId != null) {
        url += '?categoryId=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Categories
  Future<List<Categories>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/blog/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Categories.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Interests
  Future<List<UserInterest>> getUserInterests(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson == null) {
        throw Exception('No user data found');
      }
      
      final userData = json.decode(userJson);
      final token = userData['token'];
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/interests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserInterest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user interests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> saveUserInterests(List<int> interests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson == null) {
        throw Exception('No user data found');
      }

      final userData = json.decode(userJson);
      final token = userData['token'];
      final userId = userData['userId'];

      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/interests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'interests': interests}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save interests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
