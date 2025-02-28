import 'package:flutter/material.dart';

class CardAsistencia extends StatefulWidget {
  final String imagen;
  final VoidCallback onClick;

  const CardAsistencia({
    super.key,
    required this.imagen,
    required this.onClick,
  });

  @override
  State<CardAsistencia> createState() => _CardAsistenciaState();
}

class _CardAsistenciaState extends State<CardAsistencia> {
  double _scale = 1.0; // Escala inicial

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.1), // Hover: agrandar
      onExit: (_) => setState(() => _scale = 1.0), // Hover: normal
      child: GestureDetector(
        onTap: widget.onClick,
        onTapDown: (_) => setState(() => _scale = 1.2), // Presionar: más grande
        onTapUp: (_) => setState(() => _scale = 1.1), // Soltar: mantiene hover
        onTapCancel: () => setState(() => _scale = 1.0), // Cancelar: normal
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut, // Suaviza la animación
          child: Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * 0.18, // Tamaño dinámico
            height: MediaQuery.of(context).size.width * 0.25, // Tamaño dinámico
            constraints: const BoxConstraints(
              minHeight: 0, // Permite reducción
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                widget.imagen,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
