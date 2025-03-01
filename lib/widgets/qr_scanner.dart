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
    facing: CameraFacing.front, // ✅ Cámara frontal
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
              content: Text("No se pudo escanear el QR en 10 segundos."),
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
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.1416), // ✅ Activa el modo espejo
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (isScanning) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    _timeoutTimer?.cancel();
                    setState(() => isScanning = false);

                    widget.onScan(barcodes.first.rawValue ?? "");
                    Navigator.pop(context);
                  }
                }
              },
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
