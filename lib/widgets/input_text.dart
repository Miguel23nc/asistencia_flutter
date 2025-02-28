import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String hintText;
  final bool isPassword;
  final double width;
  final TextEditingController? controller; // Agregar este parámetro
  final void Function(String)? onSubmitted; // Agregar este parámetro

  const CustomTextField({
    Key? key,
    this.icon,
    this.imagePath,
    required this.hintText,
    this.isPassword = false,
    this.width = 350,
    this.controller, // Recibir el controlador
    this.onSubmitted, // Recibir la función
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller, // Pasar el controlador aquí
        obscureText: isPassword,
        onSubmitted: onSubmitted, // Pasar la función aquí
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIconConstraints: const BoxConstraints(
            minWidth: 60,
            minHeight: 40,
          ),
          prefixIcon: _buildPrefixIcon(),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black54,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (imagePath != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          imagePath!,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
      );
    } else if (icon != null) {
      return Icon(icon, color: Colors.white);
    }
    return null;
  }
}
