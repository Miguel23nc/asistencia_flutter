import 'dart:convert';
import 'package:http/http.dart' as http;

class Axios {
  static const String baseUrl =
      "https://backuptower-production.up.railway.app/api"; // ✅ Verifica la URL base

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
