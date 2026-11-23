// Fluxo de criar conta — Capi-Bank
// Lógica embutida, num fluxo só, sem fazer na mão no Swagger.
//
// 1. Pessoa NOVA: cadastro -> login -> abrir conta
//    register() -> login(cpf) -> createAccount()
//
// 2. Pessoa que JÁ tem cadastro: login -> abrir conta
//    login(cpf) -> createAccount()
//    Sem cadastrar de novo. É esse o fluxo da página de login separada.
//
// Uso:
//   final flow = CreateAccountFlow();
//   final conta = await flow.criarContaCompleta(
//     cpf: '12345678901',
//     nome: 'Capibaribe',
//     dataNascimento: '1990-01-01',
//     endereco: 'Crato, CE',
//   );
//
//   final conta2 = await flow.abrirContaParaQuemJaTemCadastro('12345678901');

import 'capi_bank_api.dart';

class CreateAccountFlow {
  final CapiBankApi api;

  CreateAccountFlow({CapiBankApi? api}) : api = api ?? CapiBankApi();

  /// Pessoa nova: cadastra, faz login e abre a conta corrente.
  /// Retorna a conta criada (agência fixa '0001').
  Future<Conta> criarContaCompleta({
    required String cpf,
    required String nome,
    required String dataNascimento, // YYYY-MM-DD
    required String endereco,
  }) async {
    // 1. Cadastro — POST /clientes/, sem token
    await api.register(
      cpf: cpf,
      nome: nome,
      dataNascimento: dataNascimento,
      endereco: endereco,
    );

    // 2. Login — POST /auth/login?cpf=, gera e guarda o bearer
    await api.login(cpf);

    // 3. Abrir conta — POST /contas/, com Bearer, sem body
    return await api.createAccount();
  }

  /// Pessoa que já tem cadastro: só login e abrir conta.
  /// Não chama register() — sem cadastrar de novo.
  Future<Conta> abrirContaParaQuemJaTemCadastro(String cpf) async {
    await api.login(cpf);
    return await api.createAccount();
  }
}
