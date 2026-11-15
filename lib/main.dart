import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/lote_controller.dart';
import 'views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LoteController(),
      child: const ValidadeZeroApp(),
    ),
  );
}

class ValidadeZeroApp extends StatelessWidget {
  const ValidadeZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validade Zero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A4D8C)),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}