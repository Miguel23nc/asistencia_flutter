import 'dart:convert';
import 'package:http/http.dart' as http;

class Axios {
  static const String baseUrl =
      // "http://localhost:3001/api";
      "https://backuptower-production.up.railway.app/api";
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    return http.post(
      Uri.parse("$baseUrl$endpoint"), // 🔹 Usa la URL base con el endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }
}
