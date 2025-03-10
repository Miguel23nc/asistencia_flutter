import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  const QRScannerScreen({Key? key, required this.onScan}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.front, // ✅ Usa la cámara frontal
    torchEnabled: false,
  );

  bool isScanning = true;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(Duration(seconds: 10), () {
      if (isScanning) {
        _mostrarErrorYSalir();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    cameraController.dispose();
    super.dispose();
  }

  void _mostrarErrorYSalir() {
    if (!mounted) return;

    setState(() => isScanning = false);
    Navigator.pop(context);

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Tiempo agotado"),
              content: Text("No se pudo escanear el QR"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Aceptar"),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Size screenSize = MediaQuery.of(context).size;
    bool isPortrait = orientation == Orientation.portrait;

    // Detectar si la pantalla está rotada hacia la izquierda o derecha
    bool isLandscapeLeft =
        screenSize.width > screenSize.height &&
        MediaQuery.of(context).size.aspectRatio < 1;
    bool isLandscapeRight =
        screenSize.width > screenSize.height &&
        MediaQuery.of(context).size.aspectRatio > 1;

    // Determinar cuántas rotaciones aplicar
    int quarterTurns = 0;
    if (isPortrait) {
      quarterTurns = 0; // Modo vertical normal
    } else if (isLandscapeLeft) {
      quarterTurns = 1; // Girado 90° a la izquierda
    } else if (isLandscapeRight) {
      quarterTurns = -1; // Girado 90° a la derecha
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RotatedBox(
              quarterTurns:
                  quarterTurns, // ✅ Ahora rota correctamente en cualquier dirección
              child: MobileScanner(
                controller: cameraController,
                onDetect: (capture) async {
                  if (isScanning) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      _timeoutTimer?.cancel();
                      setState(() => isScanning = false);

                      String qrCode = barcodes.first.rawValue ?? "";
                      print("📷 QR detectado: $qrCode"); // 🛠 Depuración

                      // Llamar a la función en `page_asistencia.dart` que maneja el envío y los mensajes
                      Navigator.pop(context, qrCode);
                    }
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
