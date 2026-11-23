// Aba INICIO (casinha) — Capi-Bank
// Igual ao Home do SemUmReal: titulo, subtitulo e o cartao preto
// RESUMO DA CONTA com o nome, a conta e o saldo — so que com dados
// REAIS da API (GET /clientes/me, GET /contas/, GET /saldo).
// Sem mock: sem "gastos mensais" inventados — a API nao tem isso.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/pixel_tab_bar.dart';
import '../widgets/pixel_widgets.dart';
import 'account_data.dart';

class HomeTab extends StatelessWidget {
  final AccountData data;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppTab> onGoToTab;

  const HomeTab({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onGoToTab,
  });

  @override
  Widget build(BuildContext context) {
    if (data.loading) {
      return Center(child: Text('CARREGANDO...', style: AppText.label()));
    }
    final preview = data.extrato.take(3).toList();
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.s2),
        children: [
          if (data.error != null) ...[
            PixelError(message: data.error),
            const SizedBox(height: AppSpacing.s2),
          ],
          Text('SEMUMREAL', style: AppText.title(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s1),
          Text(
            'SEU DINHEIRO SEM FIRULA',
            style: AppText.subtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESUMO DA CONTA',
                  style: AppText.label(color: AppColors.panelText),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  (data.cliente?.nome ?? '').toUpperCase(),
                  style: AppText.label(color: AppColors.panelText),
                ),
                Text(
                  data.contaAtiva == null
                      ? ''
                      : 'CONTA ${data.contaAtiva!.numero}  |  AG ${data.contaAtiva!.agencia}',
                  style: AppText.subtitle(),
                ),
                const SizedBox(height: AppSpacing.s2),
                const Divider(color: AppColors.panelText),
                const SizedBox(height: AppSpacing.s1),
                Text('SALDO', style: AppText.label(color: AppColors.panelText)),
                Text(
                  brl(data.saldo),
                  style: AppText.value(color: AppColors.panelText),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Text('TRANSAÇÕES RECENTES', style: AppText.label()),
          const SizedBox(height: AppSpacing.s2),
          if (preview.isEmpty)
            Text(
              'Nenhuma transacao ainda. Faca um deposito para comecar.',
              style: AppText.body(),
            )
          else
            ...preview.map(
              (tx) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                child: Text(
                  '${formatDataHora(tx.dataHora)} | ${tx.tipo.toUpperCase()} | ${brl(tx.valor)}',
                  style: AppText.label(),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s2),
          OutlinedButton(
            onPressed: () => onGoToTab(AppTab.transactions),
            child: const Text('VER EXTRATO'),
          ),
          const SizedBox(height: AppSpacing.s2),
          TextButton(
            onPressed: onRefresh,
            child: const Text('ATUALIZAR'),
          ),
        ],
      ),
    );
  }
}
