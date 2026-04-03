import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // =========================
  // SAVE TOKEN
  // =========================
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // =========================
  // SIGNUP
  // =========================
  static Future<bool> signup(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      ).timeout(Duration(seconds: 5));

      print("Signup Response: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Signup Error: $e");
      return false;
    }
  }

  // =========================
  // LOGIN
  // =========================
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      ).timeout(Duration(seconds: 5));

      print("Login Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data["token"]);
        return true;
      }

      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // =========================
  // GET ALERTS
  // =========================
  static Future<List<dynamic>> getAlerts() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("${Config.baseUrl}/alerts"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  // =========================
  // UPLOAD IMAGE
  // =========================
  static Future<bool> uploadImage(File imageFile) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("${Config.baseUrl}/alerts"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath("image", imageFile.path),
    );

    final response = await request.send();

    return response.statusCode == 200;
  }
}