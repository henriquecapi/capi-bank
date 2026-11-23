// Página de login separada — Capi-Bank
// Só para quem JÁ tem cadastro. Não cadastra de novo.
// Fluxo: digita só o CPF -> POST /auth/login?cpf= -> guarda o JWT
// -> GET /clientes/me para confirmar quem entrou.
//
// Uso:
//   MaterialApp(home: LoginPage(
//     onLoggedIn: (cliente) {
//       // ex: Navigator.push(... HomePage(cliente: cliente))
//     },
//   ))

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'capi_bank_api.dart';

class LoginPage extends StatefulWidget {
  final void Function(Cliente cliente)? onLoggedIn;

  const LoginPage({super.key, this.onLoggedIn});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cpfController = TextEditingController();
  final _api = CapiBankApi();
  bool _loading = false;
  String? _erro;

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) {
      setState(() => _erro = 'Digite o CPF com 11 dígitos.');
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      // 1. Login só com CPF — o app gera o próprio bearer aqui
      await _api.login(cpf);
      // 2. Confere quem entrou — prova que o token funciona
      final cliente = await _api.getMe();
      if (!mounted) return;
      widget.onLoggedIn?.call(cliente);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${cliente.nome}!')),
      );
    } on ApiException catch (e) {
      setState(() => _erro = e.message);
    } catch (_) {
      setState(() => _erro = 'Não consegui entrar. Confira o CPF e tente de novo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capi-Bank — Entrar')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Já tenho cadastro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Digite só o CPF. Não precisa cadastrar de novo.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: 'Somente números',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _entrar(),
            ),
            const SizedBox(height: 16),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            if (_erro != null) const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _entrar,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
