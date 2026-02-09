import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator/web
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; 
  // For iOS Simulator use localhost
  static const String baseUrl = 'http://localhost:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data; // Returns user and token
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Sign Up
  Future<Map<String, dynamic>> signUp(String firstName, String lastName, String userName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'userName': userName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data; 
      } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['message'] ?? 'Failed to sign up');
      }
    } catch (e) {
      throw Exception('Sign Up error: $e');
    }
  }

  // Fetch Notifications
  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notification/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Delete Notification
  Future<void> deleteNotification(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/notification/deleteone/$id'),
      headers: {
         'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

   // Clear All Notifications
  Future<void> clearAllNotifications() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/notification/'),
      headers: {
         'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear notifications');
    }
  }
}
