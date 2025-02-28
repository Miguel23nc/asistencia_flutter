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
    facing: CameraFacing.back, // Cámara trasera
    torchEnabled: false,
  );

  bool isScanning = true;
  Timer? _timeoutTimer; // Timer para el tiempo límite

  @override
  void initState() {
    super.initState();
    // 🔹 Iniciar el temporizador de 10 segundos
    _timeoutTimer = Timer(Duration(seconds: 10), () {
      if (isScanning) {
        _mostrarErrorYSalir();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer
        ?.cancel(); // Cancelar el temporizador si el widget se destruye
    cameraController.dispose();
    super.dispose();
  }

  void _mostrarErrorYSalir() {
    if (!mounted) return; // ✅ Verificamos si el widget está montado

    setState(() => isScanning = false);
    Navigator.pop(context);

    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text("Error"),
              content: Text("No se pudo escanear el QR"),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) Navigator.pop(context);
                  },
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
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (isScanning) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  _timeoutTimer?.cancel(); // Cancelar el temporizador
                  setState(() => isScanning = false);

                  widget.onScan(barcodes.first.rawValue ?? "");
                  Navigator.pop(context);
                }
              }
            },
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
