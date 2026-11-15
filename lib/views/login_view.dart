import 'package:flutter/material.dart';
import 'dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _erroMensagem;

  void _autenticar() {
    if (_emailController.text.trim().isEmpty || _senhaController.text.isEmpty) {
      setState(() {
        _erroMensagem = 'Preencha o e-mail institucional e a senha.';
      });
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.access_time_filled, size: 64, color: Color(0xFF0A4D8C)),
                  const SizedBox(height: 12),
                  const Text(
                    'Validade Zero',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A4D8C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Acesse o sistema da sua unidade.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  const Text('E-mail institucional', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'ex: barista.cabral@thecoffee.com.br',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Senha', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Insira sua senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_erroMensagem != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _erroMensagem!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A4D8C),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _autenticar,
                      child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}