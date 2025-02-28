import 'package:asistencia_flutter/widgets/login_asistencia.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:asistencia_flutter/providers/auth_provider.dart';
import 'package:asistencia_flutter/pages/page_asistencia.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => LoginAsistencia()),
        GoRoute(
          path: '/asistencia',
          builder: (context, state) => PageAsistencia(),
        ),
      ],
      redirect: (context, state) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final isGoingToLogin = state.uri.toString() == '/';

        if (!auth.isAuthenticated && !isGoingToLogin) {
          return '/';
        }
        if (auth.isAuthenticated && isGoingToLogin) {
          return '/asistencia';
        }
        return null;
      },
      refreshListenable: Provider.of<AuthProvider>(
        context,
        listen: true,
      ), // 🔹 Corrección aquí
    );
  }
}
