import 'package:go_router/go_router.dart';
import 'package:realidadnacional/home_screen.dart';
import 'package:realidadnacional/restore_password_screen.dart';
import 'package:realidadnacional/tema2_screen.dart';
import 'package:realidadnacional/tema_screen.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/estructura-economica-desarrollo',
      builder: (context, state) => TemaScreen(),
    ),
    GoRoute(
      path: '/descentralizacion-y-impacto',
      builder: (context, state) => TemaDescentralizacionScreen(),
    ),
    GoRoute(
      path: '/restore-password',
      builder: (context, state) {
        final token = state.pathParameters['token'];
        print('Token: $token');
        if (token == null || token.isEmpty) {
          // Manejar el caso en que no haya token
          return const Scaffold(
            body: Center(
              child: Text('Token de restauración no válido.'),
            ),
          );
        }
        return RestorePasswordScreen(token: token);
      },
    ),
  ],
);
