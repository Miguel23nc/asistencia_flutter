import 'package:flutter/material.dart';
import 'package:asistencia_flutter/services/asistencia_service.dart';
import 'package:asistencia_flutter/widgets/card_asistencia.dart';
import 'package:asistencia_flutter/widgets/qr_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PageAsistencia extends StatelessWidget {
  void _abrirEscaner(BuildContext context, String tipo) {
    bool escaneoExitoso = false;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QRScannerScreen(
              onScan: (qrCode) async {
                escaneoExitoso = true;
                print("QR Escaneado: $qrCode");

                bool hayInternet = await _verificarConexion();

                if (hayInternet) {
                  final respuesta = await AsistenciaService.enviarAsistencia(
                    qrCode,
                    tipo,
                  );
                  final mensaje = respuesta["mensaje"] ?? "Error desconocido.";

                  _mostrarModal(context, respuesta["success"], mensaje);
                } else {
                  await AsistenciaService.guardarAsistenciaLocal(qrCode, tipo);
                  _mostrarModal(
                    context,
                    true,
                    "Asistencia guardada offline. Se enviará cuando haya internet.",
                  );
                }
              },
            ),
      ),
    );
  }

  Future<bool> _verificarConexion() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _mostrarModal(BuildContext context, bool exito, String mensaje) {
    if (!context.mounted) return; // 🔹 Verifica si el contexto sigue activo

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(exito ? "Éxito" : "Error"),
              content: Text(mensaje),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Aceptar"),
                ),
              ],
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/FONDO_ASISTENCIA.webp",
            ), // 🖼 Fondo
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardAsistencia(
                imagen: "assets/images/HORA_DE_INGRESO.webp",
                onClick: () => _abrirEscaner(context, "ingreso"),
              ),
              CardAsistencia(
                imagen: "assets/images/INICIO_ALMUERZO.webp",
                onClick: () => _abrirEscaner(context, "inicioAlmuerzo"),
              ),
              CardAsistencia(
                imagen: "assets/images/FIN_ALMUERZO.webp",
                onClick: () => _abrirEscaner(context, "finAlmuerzo"),
              ),
              CardAsistencia(
                imagen: "assets/images/HORA_DE_SALIDA.webp",
                onClick: () => _abrirEscaner(context, "salida"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
