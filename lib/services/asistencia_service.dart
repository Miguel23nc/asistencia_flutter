import 'dart:convert';
import 'package:asistencia_flutter/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asistencia_flutter/utils/axios.dart';
import 'package:intl/intl.dart';

/// ===============================
/// UTILIDADES DE FECHA Y HORA
/// ===============================

String formatHora(DateTime dateTime) {
  return DateFormat('hh:mm a').format(dateTime);
}

String formatFecha(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

/// ===============================
/// SERVICIO DE ASISTENCIA
/// ===============================

class AsistenciaService {
  /// ENVÍO ONLINE U OFFLINE SINCRONIZADO
  static Future<Map<String, dynamic>> enviarAsistencia(
    String qrCode,
    String tipo, {
    DateTime? fechaHora,
  }) async {
    String endpoint =
        (tipo == 'ingreso')
            ? '/postAsistenciaColaborador'
            : '/patchAsistenciaColaborador';

    try {
      final sede = await AuthProvider().getSede() ?? "Sede no definida";

      // 👉 USA LA HORA GUARDADA SI EXISTE, SI NO LA ACTUAL
      final DateTime now = fechaHora ?? DateTime.now();

      final String hora = formatHora(now);
      final String fecha = formatFecha(now);

      final Map<String, dynamic> payload =
          (tipo == 'ingreso')
              ? {
                'dni': qrCode,
                'ingreso': hora,
                'fecha': fecha,
                'ingresoSede': sede,
              }
              : {
                'dni': qrCode,
                tipo: hora,
                'fecha': fecha,
                '${tipo}Sede': sede,
              };

      final response =
          (tipo == 'ingreso')
              ? await Axios.post(endpoint, payload)
              : await Axios.patch(endpoint, payload);

      final responseData = jsonDecode(response.body);
      final int statusCode = response.statusCode;
      final String mensajeServidor =
          responseData["message"] ?? "Respuesta desconocida del servidor.";

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
    } catch (_) {
      return {
        "success": false,
        "status": 500,
        "mensaje": "Error en la conexión con el servidor.",
      };
    }
  }

  /// ===============================
  /// GUARDADO OFFLINE
  /// ===============================
  static Future<void> guardarAsistenciaLocal(
    String qrCode,
    String tipo,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> asistencias =
        prefs.getStringList('asistencias_pendientes') ?? [];

    asistencias.add(
      jsonEncode({
        'qr': qrCode,
        'tipo': tipo,
        // 👉 HORA REAL DEL EVENTO
        'fechaHora': DateTime.now().toIso8601String(),
      }),
    );

    await prefs.setStringList('asistencias_pendientes', asistencias);
  }

  /// ===============================
  /// SINCRONIZACIÓN OFFLINE → ONLINE
  /// ===============================
  static Future<void> sincronizarAsistencias() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> asistencias =
        prefs.getStringList('asistencias_pendientes') ?? [];

    if (asistencias.isEmpty) return;

    Map<String, List<Map<String, dynamic>>> asistenciasAgrupadas = {};

    for (String asistencia in asistencias) {
      final Map<String, dynamic> data = jsonDecode(asistencia);
      final String qr = data['qr'];

      asistenciasAgrupadas.putIfAbsent(qr, () => []).add(data);
    }

    for (final String qr in asistenciasAgrupadas.keys) {
      final List<Map<String, dynamic>> registros =
          asistenciasAgrupadas[qr]!;

      // Orden correcto por fecha real
      registros.sort(
        (a, b) => a['fechaHora'].compareTo(b['fechaHora']),
      );

      for (final registro in registros) {
        final DateTime fechaHora =
            DateTime.parse(registro['fechaHora']);

        await enviarAsistencia(
          registro['qr'],
          registro['tipo'],
          fechaHora: fechaHora,
        );
      }
    }

    await prefs.remove('asistencias_pendientes');
  }
}
