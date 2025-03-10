import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asistencia_flutter/utils/axios.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String obtenerHoraDispositivo() {
  final now = DateTime.now();
  final formatter = DateFormat('hh:mm a');
  return formatter.format(now);
}

String obtenerFechaDispositivo() {
  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(now);
}

class AsistenciaService {
  static Future<Map<String, dynamic>> enviarAsistencia(
    String qrCode,
    String tipo,
  ) async {
    String endpoint =
        (tipo == 'ingreso')
            ? '/postAsistenciaColaborador'
            : '/patchAsistenciaColaborador';

    try {
      final response =
          (tipo == 'ingreso')
              ? await Axios.post(endpoint, {
                'dni': qrCode,
                "ingreso": obtenerHoraDispositivo(),
                "fecha": obtenerFechaDispositivo(),
              })
              : await http.patch(
                Uri.parse(Axios.baseUrl + endpoint),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  'dni': qrCode,
                  '$tipo': obtenerHoraDispositivo(),
                  "fecha": obtenerFechaDispositivo(),
                }),
              );

      final responseData = jsonDecode(response.body);
      final int statusCode = response.statusCode;
      final String mensajeServidor =
          responseData["message"] ?? "Respuesta desconocida del servidor.";

      print(
        "📡 Código de respuesta del backend: $statusCode - $mensajeServidor",
      );

      if (statusCode >= 200 && statusCode < 300) {
        return {
          "success": true,
          "status": statusCode,
          "mensaje": mensajeServidor,
        };
      } else {
        return {
          "success": false,
          "status": statusCode,
          "mensaje": "Código $statusCode: $mensajeServidor",
        };
      }
    } catch (e) {
      print("🚨 Error en enviarAsistencia: $e");
      return {
        "success": false,
        "status": 500,
        "mensaje": "Error en la conexión con el servidor.",
      };
    }
  }

  static Future<void> guardarAsistenciaLocal(String qrCode, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> asistencias =
        prefs.getStringList('asistencias_pendientes') ?? [];

    asistencias.add(
      jsonEncode({
        'qr': qrCode,
        'tipo': tipo,
        'hora': DateTime.now().toIso8601String(),
      }),
    );
    await prefs.setStringList('asistencias_pendientes', asistencias);
  }

  static Future<void> sincronizarAsistencias() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> asistencias =
        prefs.getStringList('asistencias_pendientes') ?? [];

    if (asistencias.isEmpty) return;

    Map<String, List<Map<String, dynamic>>> asistenciasAgrupadas = {};

    for (String asistencia in asistencias) {
      Map<String, dynamic> data = jsonDecode(asistencia);
      String qr = data['qr'];
      asistenciasAgrupadas.putIfAbsent(qr, () => []).add(data);
    }

    for (String qr in asistenciasAgrupadas.keys) {
      List<Map<String, dynamic>> registros = asistenciasAgrupadas[qr]!;
      registros.sort((a, b) => a['hora'].compareTo(b['hora']));

      for (var asistencia in registros) {
        await enviarAsistencia(asistencia['qr'], asistencia['tipo']);
      }
    }

    await prefs.remove('asistencias_pendientes');
  }
}
