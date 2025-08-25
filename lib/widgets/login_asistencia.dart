import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asistencia_flutter/providers/auth_provider.dart';
import 'package:asistencia_flutter/widgets/input_text.dart';

class LoginAsistencia extends StatefulWidget {
  @override
  _LoginAsistenciaState createState() => _LoginAsistenciaState();
}

class _LoginAsistenciaState extends State<LoginAsistencia> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sedeController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String sede = _sedeController.text.trim();

    if (email.isEmpty || password.isEmpty || sede.isEmpty) {
      _mostrarAlerta("Por favor ingresa usuario, contraseña y sede", false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(email, password, sede, context);
    } catch (e) {
      _mostrarAlerta("Error al iniciar sesión: ${e.toString()}", false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarAlerta(String mensaje, bool esExito) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              esExito ? "Éxito" : "Error",
              style: TextStyle(color: esExito ? Colors.green : Colors.red),
            ),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          double containerWidth =
              screenWidth > 1200 ? screenWidth * 0.4 : screenWidth * 0.55;
          double containerHeight =
              screenWidth > 1200 ? screenHeight * 0.85 : screenHeight * 0.99;
          double topSpacing =
              screenWidth > 1200
                  ? containerHeight * 0.55
                  : containerHeight * 0.52;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/SOFTOWER_LOGIN.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: containerWidth,
                height: containerHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: containerWidth * 0.08,
                  vertical: containerHeight * 0.05,
                ),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage("assets/images/SOFTOWER_LOGIN2.jpg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    Column(
                      children: [
                        const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          icon: Icons.business,
                          hintText: "SEDE",
                          width: screenWidth > 1000 ? 350 : 280,
                          controller: _sedeController,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 15),

                        CustomTextField(
                          icon: Icons.email,
                          hintText: "USUARIO",
                          width: screenWidth > 1000 ? 350 : 280,
                          controller: _emailController,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          icon: Icons.lock,
                          hintText: "CONTRASEÑA",
                          isPassword: true,
                          width: screenWidth > 1000 ? 350 : 280,
                          controller: _passwordController,
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 20),
                        _buildLoginButton(screenWidth),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginButton(double screenWidth) {
    double buttonWidth = screenWidth > 1000 ? 200 : 170;

    return Container(
      width: buttonWidth,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF4392E1), Color(0xFF00FFFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  "INICIAR SESIÓN",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
