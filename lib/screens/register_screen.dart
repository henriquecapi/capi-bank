// Cadastro + abrir conta — Capi-Bank
// Logica embutida num fluxo so:
//   1. POST /clientes/ (cpf, nome, data_nascimento, endereco)
//   2. POST /auth/login?cpf= (gera e guarda o bearer)
//   3. POST /contas/ (abre a conta corrente, agencia 0001)
// Depois vai direto para a Home. Sem fazer nada na mao no Swagger.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../capi_bank_api.dart';
import '../create_account_flow.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_widgets.dart';

class RegisterScreen extends StatefulWidget {
  final CapiBankApi api;
  final VoidCallback onRegistered;
  final VoidCallback onGoToLogin;

  const RegisterScreen({
    super.key,
    required this.api,
    required this.onRegistered,
    required this.onGoToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cpfController = TextEditingController();
  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _enderecoController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _nascimentoController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  String? _validate() {
    final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11) return 'CPF precisa ter 11 digitos.';
    if (_nomeController.text.trim().isEmpty) return 'Digite o nome.';
    final nasc = _nascimentoController.text.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(nasc)) {
      return 'Data de nascimento no formato AAAA-MM-DD.';
    }
    if (_enderecoController.text.trim().isEmpty) return 'Digite o endereco.';
    return null;
  }

  Future<void> _cadastrar() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final flow = CreateAccountFlow(api: widget.api);
      final conta = await flow.criarContaCompleta(
        cpf: _cpfController.text,
        nome: _nomeController.text.trim(),
        dataNascimento: _nascimentoController.text.trim(),
        endereco: _enderecoController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta ${conta.numero} criada! Agencia ${conta.agencia}.')),
      );
      widget.onRegistered();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Nao consegui cadastrar. Confira os dados e tente de novo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s2),
              Text('CAPI-BANK', style: AppText.title(), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.s1),
              Text(
                'CRIAR CONTA',
                style: AppText.subtitle(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s3),
              PixelField(
                controller: _cpfController,
                label: 'CPF',
                hint: 'Somente numeros',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.s2),
              PixelField(
                controller: _nomeController,
                label: 'NOME',
                hint: 'Nome completo',
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.s2),
              PixelField(
                controller: _nascimentoController,
                label: 'DATA DE NASCIMENTO',
                hint: 'AAAA-MM-DD',
                keyboardType: TextInputType.datetime,
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.s2),
              PixelField(
                controller: _enderecoController,
                label: 'ENDERECO',
                hint: 'Rua, numero, cidade - UF',
                enabled: !_busy,
              ),
              const SizedBox(height: AppSpacing.s2),
              PixelError(message: _error),
              const SizedBox(height: AppSpacing.s2),
              PixelButton(
                label: _busy ? 'CRIANDO...' : 'CADASTRAR E ABRIR CONTA',
                onPressed: _cadastrar,
                busy: _busy,
              ),
              const SizedBox(height: AppSpacing.s2),
              TextButton(
                onPressed: widget.onGoToLogin,
                child: const Text('JA TENHO CONTA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
