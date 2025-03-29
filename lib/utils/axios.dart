import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Axios {
  static const String baseUrl =
      // "http://localhost:3001/api";
      "https://api.gestower.com/api";

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      "Authorization": token != null ? "Bearer $token" : "",
      "Content-Type": "application/json",
    };
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print("🚨 Error en POST $endpoint: $e");
      return http.Response('{"message": "Error en la petición"}', 500);
    }
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print("🚨 Error en PATCH $endpoint: $e");
      return http.Response('{"message": "Error en la petición"}', 500);
    }
  }
}
