import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:asistencia_flutter/utils/axios.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email == "asistencia@towerandtower.com.pe" &&
          password == "Tow3r(2025)*.") {
        _token = "token_falso_123";
        await _saveToken(_token!);
        notifyListeners();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, "/asistencia");
        }
      } else {
        throw Exception(
          "Usuario o contraseña incorrectos",
        ); // Mantener mensaje real
      }
    } catch (error) {
      print("Error en login: $error");
      throw Exception('Error de conexión con el servidor');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    await _removeToken();
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _getToken();
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
