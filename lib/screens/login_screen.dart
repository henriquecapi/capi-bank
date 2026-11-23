// Login — Capi-Bank
// Visual EXATAMENTE como o login do SemUmReal original (docs/login.jpg):
// titulo SEMUMREAL, subtitulo SEU DINHEIRO SEM FIRULA, campo com
// borda grossa, botao preto ENTRAR, link CRIAR CONTA e, embaixo,
// a arte do joguinho: sol-moeda com $ e o dolarzinho correndo.
//
// Login DIRETO na API Capi-Bank, sem Google, sem e-mail e sem senha:
// a API v6 nao tem esses campos. Quem ja tem cadastro entra so com
// o CPF (11 digitos): POST /auth/login?cpf= guarda o Bearer e vai
// para a Home com as 5 abas. Quem nao tem, usa CRIAR CONTA.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../capi_bank_api.dart';
import '../theme/app_theme.dart';
import '../widgets/coin_game.dart';
import '../widgets/pixel_widgets.dart';

class LoginScreen extends StatefulWidget {
  final CapiBankApi api;
  final VoidCallback onLoggedIn;
  final VoidCallback onGoToRegister;

  const LoginScreen({
    super.key,
    required this.api,
    required this.onLoggedIn,
    required this.onGoToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _cpfController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) {
      setState(() => _error = 'Digite o CPF com 11 digitos.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.login(cpf);
      // Prova que o token funciona e busca quem entrou.
      final cliente = await widget.api.getMe();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${cliente.nome}!')),
      );
      widget.onLoggedIn();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Nao consegui entrar. Confira o CPF e tente de novo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginSky,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s3,
                  AppSpacing.s2,
                  AppSpacing.s3,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('SEMUMREAL', style: AppText.title(), textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.s1),
                    Text(
                      'SEU DINHEIRO SEM FIRULA',
                      style: AppText.subtitle(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text('JA TENHO CADASTRO', style: AppText.label()),
                    const SizedBox(height: AppSpacing.s2),
                    PixelField(
                      controller: _cpfController,
                      label: 'CPF',
                      hint: 'Somente numeros',
                      keyboardType: TextInputType.number,
                      borderWidth: 2,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      enabled: !_busy,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    PixelError(message: _error),
                    const SizedBox(height: AppSpacing.s2),
                    PixelButton(
                      label: _busy ? 'ENTRANDO...' : 'ENTRAR',
                      onPressed: _entrar,
                      busy: _busy,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    TextButton(
                      onPressed: widget.onGoToRegister,
                      child: const Text('CRIAR CONTA'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              const CoinGame(height: 210),
            ],
          ),
        ),
      ),
    );
  }
}
