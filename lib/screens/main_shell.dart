// Shell das 5 abas — Capi-Bank
// Depois do login (Bearer guardado), carrega os dados do cliente
// uma vez e reparte com as abas: GET /clientes/me, GET /contas/
// (cria uma se nao houver), GET /saldo e GET /extrato da conta ativa.
// Trocar de conta recarrega saldo/extrato. SAIR apaga o Bearer e
// volta para a tela de login (CPF). Sem mock em nenhuma aba.

import 'package:flutter/material.dart';
import '../capi_bank_api.dart';
import '../widgets/pixel_tab_bar.dart';
import 'account_data.dart';
import 'home_tab.dart';
import 'new_tab.dart';
import 'profile_tab.dart';
import 'reports_tab.dart';
import 'transactions_tab.dart';

class MainShell extends StatefulWidget {
  final CapiBankApi api;
  final VoidCallback onLoggedOut;

  const MainShell({
    super.key,
    required this.api,
    required this.onLoggedOut,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppTab _tab = AppTab.home;
  AccountData _data = const AccountData();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _data = _data.copyWith(loading: true, error: null));
    try {
      final cliente = await widget.api.getMe();
      final contas = await widget.api.listAccounts();
      final conta = contas.isEmpty
          ? await widget.api.createAccount()
          : contas.first;
      final allContas =
          contas.isEmpty ? <Conta>[conta] : contas;
      final saldo = await widget.api.getBalance(conta.numero);
      final extrato = await widget.api.getStatement(conta.numero);
      if (!mounted) return;
      setState(() {
        _data = AccountData(
          cliente: cliente,
          contas: allContas,
          contaAtiva: conta,
          saldo: saldo,
          extrato: extrato,
          loading: false,
        );
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        widget.onLoggedOut();
        return;
      }
      if (!mounted) return;
      setState(() => _data = _data.copyWith(loading: false, error: e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _data = _data.copyWith(
            loading: false,
            error: 'Nao consegui carregar a conta. Tente de novo.',
          ));
    }
  }

  /// Recarrega saldo + extrato da conta ativa (apos deposito/saque/
  /// transferencia ou troca de conta), sem recarregar tudo.
  Future<void> _refreshConta() async {
    final conta = _data.contaAtiva;
    if (conta == null) {
      await _load();
      return;
    }
    try {
      final contas = await widget.api.listAccounts();
      final saldo = await widget.api.getBalance(conta.numero);
      final extrato = await widget.api.getStatement(conta.numero);
      if (!mounted) return;
      setState(() {
        _data = _data.copyWith(
          contas: contas,
          saldo: saldo,
          extrato: extrato,
          error: null,
        );
      });
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        widget.onLoggedOut();
        return;
      }
      if (!mounted) return;
      setState(() => _data = _data.copyWith(error: e.message));
    }
  }

  Future<void> _logout() async {
    await widget.api.logout();
    widget.onLoggedOut();
  }

  void _selectAccount(Conta conta) {
    if (_data.contaAtiva?.numero == conta.numero) return;
    setState(() => _data = _data.copyWith(contaAtiva: conta));
    _refreshConta();
  }

  void _goToTab(AppTab tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(
          index: _tab.index,
          children: [
            HomeTab(
              data: _data,
              onRefresh: _load,
              onGoToTab: _goToTab,
            ),
            TransactionsTab(
              api: widget.api,
              data: _data,
              onRefresh: _refreshConta,
              onLoggedOut: widget.onLoggedOut,
            ),
            NewTab(
              api: widget.api,
              data: _data,
              onRefresh: _load,
              onSelectAccount: _selectAccount,
              onLoggedOut: widget.onLoggedOut,
            ),
            ReportsTab(
              api: widget.api,
              onLoggedOut: widget.onLoggedOut,
            ),
            ProfileTab(
              data: _data,
              onGoToTab: _goToTab,
              onLoggedOut: _logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: PixelTabBar(
        active: _tab,
        onTabPress: _goToTab,
      ),
    );
  }
}
