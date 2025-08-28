import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/post.dart';
import '../models/event.dart';

class ApiService {
  static const String baseUrl = 'https://breach-api.qa.mvm-tech.xyz';
  static const String wsUrl = 'wss://breach-api-ws.qa.mvm-tech.xyz';

  // Authentication
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Posts
  Future<List<Post>> getPosts({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response = await http.get(
        Uri.parse('$baseUrl/posts').replace(queryParameters: queryParams),
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
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // User Interests
  Future<void> saveUserInterests(String token, List<String> interests) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/interests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'interests': interests}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save interests: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
