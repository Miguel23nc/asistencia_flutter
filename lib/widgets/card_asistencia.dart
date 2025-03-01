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
  double _scale = 1.0;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _scale = 1.2);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onClick(); // Llamar la función después del tap
  }

  void _handleTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.18,
          height: MediaQuery.of(context).size.width * 0.25,
          constraints: const BoxConstraints(minHeight: 0),
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
    );
  }
}
