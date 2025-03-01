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
              })
              : await http.patch(
                Uri.parse(Axios.baseUrl + endpoint),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  'dni': qrCode,
                  '$tipo': obtenerHoraDispositivo(),
                }),
              );

      final responseData = jsonDecode(response.body);
      final mensajeServidor = responseData["message"] ?? "Error desconocido.";

      if (response.statusCode == 200) {
        return {
          "success": true,
          "mensaje": "Asistencia registrada correctamente.",
        };
      } else {
        return {
          "success": false,
          "mensaje": mensajeServidor, // Ahora muestra el mensaje real
        };
      }
    } catch (e) {
      return {"success": false, "mensaje": "Error de conexión: $e"};
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
