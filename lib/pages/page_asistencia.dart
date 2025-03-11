import 'package:flutter/material.dart';
import 'package:asistencia_flutter/services/asistencia_service.dart';
import 'package:asistencia_flutter/widgets/card_asistencia.dart';
import 'package:asistencia_flutter/widgets/qr_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PageAsistencia extends StatelessWidget {
  void _abrirEscaner(BuildContext context, String tipo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QRScannerScreen(
              onScan: (qrCode) async {
                print("QR Escaneado: $qrCode");

                bool hayInternet = await _verificarConexion();
                Map<String, dynamic> respuesta = {};

                if (hayInternet) {
                  print("Enviando asistencia...");
                  respuesta = await AsistenciaService.enviarAsistencia(
                    qrCode,
                    tipo,
                  );
                } else {
                  print("Guardando asistencia offline...");
                  await AsistenciaService.guardarAsistenciaLocal(qrCode, tipo);
                  respuesta = {
                    "success": true,
                    "mensaje":
                        "Asistencia guardada offline. Se enviará cuando haya internet.",
                  };
                }

                print("Respuesta del servidor: ${respuesta}");

                // 🔹 Esperar 300ms después de cerrar el scanner para mostrar el modal
                await Future.delayed(Duration(milliseconds: 300));

                if (!context.mounted) {
                  print(
                    "Contexto ya no está montado, no se puede abrir el modal.",
                  );
                  return;
                }

                _mostrarModal(
                  context,
                  respuesta["success"],
                  respuesta["mensaje"],
                );
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
