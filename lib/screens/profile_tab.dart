// Aba PERFIL (userzinho) — Capi-Bank
// Dados do cliente logado: GET /clientes/me — nome, CPF, nascimento
// e endereco. SAIR apaga o Bearer e volta para a tela de login (CPF).

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/pixel_tab_bar.dart';
import '../widgets/pixel_widgets.dart';
import 'account_data.dart';

class ProfileTab extends StatelessWidget {
  final AccountData data;
  final ValueChanged<AppTab> onGoToTab;
  final VoidCallback onLoggedOut;

  const ProfileTab({
    super.key,
    required this.data,
    required this.onGoToTab,
    required this.onLoggedOut,
  });

  @override
  Widget build(BuildContext context) {
    final cliente = data.cliente;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s2),
      children: [
        Text('PERFIL', style: AppText.title(), textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.s1),
        Text(
          'SEUS DADOS',
          style: AppText.subtitle(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s3),
        if (data.loading)
          Text('CARREGANDO...', style: AppText.label())
        else if (cliente == null)
          Text('Nao consegui carregar seus dados.', style: AppText.body())
        else
          PixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('NOME', cliente.nome.toUpperCase()),
                const SizedBox(height: AppSpacing.s2),
                _row('CPF', cliente.id),
                const SizedBox(height: AppSpacing.s2),
                _row('NASCIMENTO', formatData(cliente.dataNascimento)),
                const SizedBox(height: AppSpacing.s2),
                _row('ENDERECO', cliente.endereco.toUpperCase()),
                const SizedBox(height: AppSpacing.s2),
                const Divider(color: AppColors.panelText),
                const SizedBox(height: AppSpacing.s1),
                _row('CONTAS', '${data.contas.length}'),
                if (data.contaAtiva != null) ...[
                  const SizedBox(height: AppSpacing.s1),
                  _row(
                    'CONTA ATIVA',
                    '${data.contaAtiva!.numero}  |  AG ${data.contaAtiva!.agencia}',
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.s3),
        OutlinedButton(
          onPressed: () => onGoToTab(AppTab.novo),
          child: const Text('MINHAS CONTAS'),
        ),
        const SizedBox(height: AppSpacing.s2),
        PixelButton(
          label: 'SAIR',
          onPressed: () async {
            // O logout em si fica no MainShell/RootGate: aqui so avisamos.
            onLoggedOut();
          },
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Sair apaga o token deste aparelho. Para voltar, entre com o CPF.',
          style: AppText.subtitle(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label(color: AppColors.panelText)),
        const SizedBox(height: 4),
        Text(value, style: AppText.body(color: AppColors.panelText)),
      ],
    );
  }
}
