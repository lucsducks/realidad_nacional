import 'package:flutter/material.dart';
import 'package:realidadnacional/router.dart';
import 'package:realidadnacional/auth_services.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  final authService = AuthService();
  await authService.initialize();

  runApp(
    ChangeNotifierProvider<AuthService>.value(
      value: authService, // Provee la instancia ya inicializada
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Realidad Nacional',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
