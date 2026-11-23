// Dados da conta ativa dentro do MainShell — Capi-Bank
// O MainShell carrega tudo uma vez (cliente, contas, saldo, extrato)
// e reparte com as 5 abas. Trocar de conta ou de cliente recarrega.

import '../capi_bank_api.dart';

class AccountData {
  final Cliente? cliente;
  final List<Conta> contas;
  final Conta? contaAtiva;
  final double saldo;
  final List<Transacao> extrato;
  final bool loading;
  final String? error;

  const AccountData({
    this.cliente,
    this.contas = const [],
    this.contaAtiva,
    this.saldo = 0,
    this.extrato = const [],
    this.loading = true,
    this.error,
  });

  AccountData copyWith({
    Cliente? cliente,
    List<Conta>? contas,
    Conta? contaAtiva,
    double? saldo,
    List<Transacao>? extrato,
    bool? loading,
    String? error,
  }) {
    return AccountData(
      cliente: cliente ?? this.cliente,
      contas: contas ?? this.contas,
      contaAtiva: contaAtiva ?? this.contaAtiva,
      saldo: saldo ?? this.saldo,
      extrato: extrato ?? this.extrato,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
