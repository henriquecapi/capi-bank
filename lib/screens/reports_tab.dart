// Aba RELATORIOS (grafico de barras) — Capi-Bank
// Auditoria: GET /logs/?limit=100 — lista os registros da tabela
// bank_logs (id, timestamp, func_name, payload, status).

import 'package:flutter/material.dart';
import '../capi_bank_api.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/coin_game.dart';
import '../widgets/pixel_widgets.dart';

class ReportsTab extends StatefulWidget {
  final CapiBankApi api;
  final VoidCallback onLoggedOut;

  const ReportsTab({
    super.key,
    required this.api,
    required this.onLoggedOut,
  });

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  bool _loading = true;
  String? _error;
  List<LogEntry> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final logs = await widget.api.listLogs(limit: 100);
      if (!mounted) return;
      setState(() => _logs = logs);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        widget.onLoggedOut();
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Nao consegui carregar os logs. Tente de novo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.s2),
        children: [
          Text('RELATÓRIOS', style: AppText.title(), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.s1),
          Text(
            'AUDITORIA — LOGS',
            style: AppText.subtitle(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s3),
          if (_error != null) ...[
            PixelError(message: _error),
            const SizedBox(height: AppSpacing.s2),
          ],
          if (_loading)
            Text('CARREGANDO...', style: AppText.label())
          else if (_logs.isEmpty) ...[
            Text('Nenhum registro de auditoria.', style: AppText.body()),
            const SizedBox(height: AppSpacing.s2),
            const CoinGameStatic(height: 150),
          ] else
            ..._logs.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${log.id}  |  ${formatDataHora(log.timestamp)}',
                      style: AppText.label(),
                    ),
                    Text(
                      '${(log.funcName ?? '-').toUpperCase()}'
                      '${log.status == null ? '' : '  |  ${log.status!.toUpperCase()}'}',
                      style: AppText.subtitle(),
                    ),
                    if (log.payload != null && log.payload!.isNotEmpty)
                      Text(log.payload!, style: AppText.body()),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.s2),
          TextButton(
            onPressed: _load,
            child: const Text('ATUALIZAR'),
          ),
        ],
      ),
    );
  }
}
