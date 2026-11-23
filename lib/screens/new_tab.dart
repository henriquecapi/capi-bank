// Aba NOVO (mais numa caixa) — Capi-Bank
// Criar NOVA CONTA bancaria para o cliente logado: POST /contas/
// (sem body, agencia fixa 0001). O cliente pode ter VARIAS contas:
// a lista mostra todas e tocar numa delas deixa ela como conta ativa.
// Criar CLIENTE continua no CRIAR CONTA (RegisterScreen, POST /clientes/).

import 'package:flutter/material.dart';
import '../capi_bank_api.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/pixel_widgets.dart';
import 'account_data.dart';

class NewTab extends StatefulWidget {
  final CapiBankApi api;
  final AccountData data;
  final Future<void> Function() onRefresh;
  final ValueChanged<Conta> onSelectAccount;
  final VoidCallback onLoggedOut;

  const NewTab({
    super.key,
    required this.api,
    required this.data,
    required this.onRefresh,
    required this.onSelectAccount,
    required this.onLoggedOut,
  });

  @override
  State<NewTab> createState() => _NewTabState();
}

class _NewTabState extends State<NewTab> {
  bool _busy = false;
  String? _error;
  Conta? _created;

  Future<void> _criarConta() async {
    setState(() {
      _busy = true;
      _error = null;
      _created = null;
    });
    try {
      final conta = await widget.api.createAccount();
      if (!mounted) return;
      setState(() => _created = conta);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conta ${conta.numero} criada! Agencia ${conta.agencia}.',
          ),
        ),
      );
      await widget.onRefresh();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        widget.onLoggedOut();
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Nao consegui criar a conta. Tente de novo.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.s2),
        children: [
          Text('NOVO', style: AppText.title(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s1),
          Text(
            'CRIAR NOVA CONTA',
            style: AppText.subtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          if (_error != null) ...[
            PixelError(message: _error),
            const SizedBox(height: AppSpacing.s2),
          ],
          if (_created != null)
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTA CRIADA',
                    style: AppText.label(color: AppColors.panelText),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    'CONTA ${_created!.numero}  |  AG ${_created!.agencia}',
                    style: AppText.label(color: AppColors.panelText),
                  ),
                  Text(
                    'CRIADA EM ${formatData(_created!.dataCriacao)}',
                    style: AppText.subtitle(),
                  ),
                ],
              ),
            ),
          if (_created != null) const SizedBox(height: AppSpacing.s3),
          PixelButton(
            label: _busy ? 'CRIANDO...' : 'CRIAR NOVA CONTA',
            onPressed: _criarConta,
            busy: _busy,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Toda conta nova abre na agencia 0001.',
            style: AppText.subtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          Text('MINHAS CONTAS', style: AppText.label()),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Toque numa conta para deixa-la ativa nas outras abas.',
            style: AppText.subtitle(),
          ),
          const SizedBox(height: AppSpacing.s2),
          if (data.loading)
            Text('CARREGANDO...', style: AppText.label())
          else if (data.contas.isEmpty)
            Text('Nenhuma conta ainda.', style: AppText.body())
          else
            ...data.contas.map((conta) {
              final ativa = data.contaAtiva?.numero == conta.numero;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                child: InkWell(
                  onTap: () => widget.onSelectAccount(conta),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s2),
                    decoration: BoxDecoration(
                      color: ativa ? AppColors.panel : AppColors.paper,
                      border: Border.all(
                        color: AppColors.ink,
                        width: 3,
                      ),
                    ),
                    child: Text(
                      'CONTA ${conta.numero}  |  AG ${conta.agencia}'
                      '${ativa ? '  —  ATIVA' : ''}',
                      style: AppText.label(
                        color: ativa
                            ? AppColors.panelText
                            : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
