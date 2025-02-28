import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asistencia_flutter/providers/auth_provider.dart';
import 'package:asistencia_flutter/providers/app_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:asistencia_flutter/services/asistencia_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => authProvider)],
      child: const MyApp(),
    ),
  );

  // Detectar conexión a Internet y sincronizar datos
  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      AsistenciaService.sincronizarAsistencias();
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Asistencia App',
      routerConfig: AppRouter.createRouter(context),
    );
  }
}
