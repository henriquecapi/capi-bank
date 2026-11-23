// Aba TRANSACOES (setinha dupla) — Capi-Bank
// Extrato REAL: GET /contas/{n}/extrato, com Depositar, Sacar e
// Transferir na mesma aba (POST /depositar, /sacar, /transferir).
// Saque tem o Double Guard da API: max R$ 500 por operacao,
// max 3 saques/dia, max 10 transacoes/dia, max R$ 1.200/dia.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../capi_bank_api.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/coin_game.dart';
import '../widgets/pixel_widgets.dart';
import 'account_data.dart';

class _ValorResult {
  final double valor;
  final int? destino;
  _ValorResult(this.valor, this.destino);
}

class TransactionsTab extends StatefulWidget {
  final CapiBankApi api;
  final AccountData data;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoggedOut;

  const TransactionsTab({
    super.key,
    required this.api,
    required this.data,
    required this.onRefresh,
    required this.onLoggedOut,
  });

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  String? _error;

  Future<_ValorResult?> _showValorDialog({
    required String titulo,
    required String hintLimite,
    bool comDestino = false,
  }) {
    final valorCtrl = TextEditingController();
    final destinoCtrl = TextEditingController();
    String? erroLocal;

    return showDialog<_ValorResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(titulo, style: AppText.label()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: valorCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'VALOR (R\$)',
                  hintText: 'Ex: 100.00',
                ),
              ),
              if (comDestino) ...[
                const SizedBox(height: AppSpacing.s2),
                TextField(
                  controller: destinoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'CONTA DESTINO',
                    hintText: 'Numero da conta',
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s1),
              Text(hintLimite, style: AppText.subtitle()),
              if (erroLocal != null) ...[
                const SizedBox(height: AppSpacing.s1),
                Text(
                  erroLocal!,
                  style: AppText.label(color: AppColors.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(
                  valorCtrl.text.replaceAll(',', '.'),
                );
                if (valor == null || valor <= 0) {
                  setDialogState(
                      () => erroLocal = 'Digite um valor maior que zero.');
                  return;
                }
                int? destino;
                if (comDestino) {
                  destino = int.tryParse(destinoCtrl.text);
                  if (destino == null) {
                    setDialogState(
                        () => erroLocal = 'Digite a conta destino.');
                    return;
                  }
                }
                Navigator.of(ctx).pop(_ValorResult(valor, destino));
              },
              child: const Text('CONFIRMAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _fail(Object e) {
    if (e is ApiException && e.statusCode == 401) {
      widget.onLoggedOut();
      return;
    }
    setState(() => _error = e is ApiException
        ? e.message
        : 'Nao consegui completar. Tente de novo.');
  }

  Future<void> _depositar() async {
    final conta = widget.data.contaAtiva;
    if (conta == null) return;
    final res = await _showValorDialog(
      titulo: 'DEPOSITAR',
      hintLimite: 'Sem limite por operacao.',
    );
    if (res == null) return;
    try {
      await widget.api.deposit(conta.numero, res.valor);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deposito de ${brl(res.valor)} feito!')),
      );
      await widget.onRefresh();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> _sacar() async {
    final conta = widget.data.contaAtiva;
    if (conta == null) return;
    final res = await _showValorDialog(
      titulo: 'SACAR',
      hintLimite: 'Max R\$ 500 por saque. Max 3 saques/dia, R\$ 1.200/dia.',
    );
    if (res == null) return;
    if (res.valor > 500) {
      setState(() => _error = 'Saque maximo de R\$ 500 por operacao.');
      return;
    }
    if (res.valor > widget.data.saldo) {
      setState(() => _error = 'Saldo insuficiente para esse saque.');
      return;
    }
    try {
      await widget.api.withdraw(conta.numero, res.valor);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saque de ${brl(res.valor)} feito!')),
      );
      await widget.onRefresh();
    } catch (e) {
      _fail(e);
    }
  }

  Future<void> _transferir() async {
    final conta = widget.data.contaAtiva;
    if (conta == null) return;
    final res = await _showValorDialog(
      titulo: 'TRANSFERIR',
      hintLimite: 'Limites diarios compartilhados com saques.',
      comDestino: true,
    );
    if (res == null || res.destino == null) return;
    try {
      await widget.api.transfer(
        origem: conta.numero,
        destino: res.destino!,
        valor: res.valor,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transferencia de ${brl(res.valor)} feita!')),
      );
      await widget.onRefresh();
    } catch (e) {
      _fail(e);
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
          Text('TRANSAÇÕES', style: AppText.title(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s1),
          Text(
            data.contaAtiva == null
                ? ''
                : 'CONTA ${data.contaAtiva!.numero}  |  SALDO ${brl(data.saldo)}',
            style: AppText.subtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          if (_error != null || data.error != null) ...[
            PixelError(message: _error ?? data.error),
            const SizedBox(height: AppSpacing.s2),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _depositar,
                  child: const Text('DEPOSITAR'),
                ),
              ),
              const SizedBox(width: AppSpacing.s1),
              Expanded(
                child: OutlinedButton(
                  onPressed: _sacar,
                  child: const Text('SACAR'),
                ),
              ),
              const SizedBox(width: AppSpacing.s1),
              Expanded(
                child: OutlinedButton(
                  onPressed: _transferir,
                  child: const Text('TRANSFERIR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Text('EXTRATO', style: AppText.label()),
          const SizedBox(height: AppSpacing.s2),
          if (data.loading)
            Text('CARREGANDO...', style: AppText.label())
          else if (data.extrato.isEmpty) ...[
            Text(
              'Nenhuma transacao ainda. Faca um deposito para comecar.',
              style: AppText.body(),
            ),
            const SizedBox(height: AppSpacing.s2),
            const CoinGameStatic(height: 150),
          ] else
            ...data.extrato.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                child: Text(
                  '${formatDataHora(tx.dataHora)} | ${tx.tipo.toUpperCase()} | ${brl(tx.valor)}',
                  style: AppText.label(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
