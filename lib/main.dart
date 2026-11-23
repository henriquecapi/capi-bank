// Capi-Bank — entry point
// Login DIRETO na API: se ha Bearer guardado, vai para a Home com
// as 5 abas. Se nao, mostra Login (CPF) / Cadastro (criar cliente).
// Sem Google, sem e-mail e sem senha — a API v6 so tem login por CPF.
// O layout (separado ou pagina unica) segue o SemUmReal: login e
// cadastro em telas separadas, Home em 5 abas no rodape.

import 'package:flutter/material.dart';
import 'capi_bank_api.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/register_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CapiBankApp());
}

class CapiBankApp extends StatelessWidget {
  const CapiBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capi-Bank',
      debugShowCheckedModeBanner: false,
      theme: capiBankTheme(),
      home: const RootGate(),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final _api = CapiBankApi();
  bool _checking = true;
  bool _loggedIn = false;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await _api.isLoggedIn;
    if (!mounted) return;
    setState(() {
      _loggedIn = loggedIn;
      _checking = false;
    });
  }

  void _goHome() {
    setState(() {
      _loggedIn = true;
      _showRegister = false;
    });
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    setState(() {
      _loggedIn = false;
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        backgroundColor: AppColors.loginSky,
        body: Center(
          child: Text('SEMUMREAL', style: AppText.title()),
        ),
      );
    }

    if (_loggedIn) {
      return MainShell(api: _api, onLoggedOut: _logout);
    }

    if (_showRegister) {
      return RegisterScreen(
        api: _api,
        onRegistered: _goHome,
        onGoToLogin: () => setState(() => _showRegister = false),
      );
    }

    return LoginScreen(
      api: _api,
      onLoggedIn: _goHome,
      onGoToRegister: () => setState(() => _showRegister = true),
    );
  }
}
