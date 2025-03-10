import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:asistencia_flutter/utils/axios.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

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
      // ✅ Comparar con valores fijos en lugar de llamar al backend
      if (email == "asistencia.offline@tower.com.pe" &&
          password == "clave123") {
        _token = "token_falso"; // No se necesita un token real
        notifyListeners();
        Navigator.pushReplacementNamed(context, "/asistencia");
      } else {
        throw Exception("Credenciales incorrectas");
      }

      // final response = await Axios.post("/login", {
      //   'email': email,
      //   'password': password,
      // });
      // final responseData = jsonDecode(response.body);

      // if (response.statusCode == 200 && responseData['token'] != null) {
      //   _token = responseData['token'];
      //   await _saveToken(_token!);
      //   notifyListeners();

      //   if (context.mounted) {
      //     Navigator.pushReplacementNamed(context, "/asistencia");
      //   }
      // } else {
      //   throw Exception(responseData['message'] ?? 'Error al iniciar sesión');
      // }
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

  // 🔹 Guardar token de manera segura
  Future<void> _saveToken(String token) async {
    await secureStorage.write(key: 'token', value: token);
  }

  // 🔹 Eliminar token de manera segura
  Future<void> _removeToken() async {
    await secureStorage.delete(key: 'token');
  }

  // 🔹 Obtener token de manera segura
  Future<String?> _getToken() async {
    return await secureStorage.read(key: 'token');
  }
}
