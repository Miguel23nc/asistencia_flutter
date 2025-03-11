import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  int quarterTurns = 0; // Inicialmente sin rotación
  StreamSubscription? _sensorSubscription;

  @override
  void initState() {
    super.initState();

    // Iniciar temporizador de 10s
    _timeoutTimer = Timer(Duration(seconds: 10), () {
      if (isScanning) _mostrarErrorYSalir();
    });

    // Escuchar cambios del acelerómetro para detectar rotación
    _sensorSubscription = accelerometerEvents.listen((event) {
      setState(() {
        if (event.x.abs() < 3 && event.y > 7) {
          quarterTurns = 0; // 📱 Vertical normal
        } else if (event.x > 7) {
          quarterTurns = -1; // 🔄 Rotado a la izquierda (antes era 1, ahora -1)
        } else if (event.x < -7) {
          quarterTurns = 1; // 🔄 Rotado a la derecha (antes era -1, ahora 1)
        } else if (event.y < -7) {
          quarterTurns = 2; // 🔄 Volteado completamente
        }
      });
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _sensorSubscription?.cancel(); // Parar detección del acelerómetro
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: quarterTurns, // ✅ Aplica la rotación correcta
              child: MobileScanner(
                controller: cameraController,
                onDetect: (capture) async {
                  if (isScanning) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      _timeoutTimer?.cancel();
                      setState(() => isScanning = false);

                      String qrCode = barcodes.first.rawValue ?? "";
                      print("Código QR detectado: $qrCode");

                      if (!mounted) return;

                      await widget.onScan(qrCode);

                      if (mounted) Navigator.pop(context);
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
