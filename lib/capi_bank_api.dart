// Capi-Bank API — serviço Flutter pronto
// Base: https://desafio-capi-bank.onrender.com — v6.0.0
// Docs: https://desafio-capi-bank.onrender.com/docs
//
// Dependências no pubspec.yaml:
//   http: ^1.2.0
//   shared_preferences: ^2.2.0
// (flutter_secure_storage foi removido: quebra o build Web/WASM.
//  O token agora vai para TokenStorage, em lib/utils/token_storage.dart.)
//
// Fluxo:
//   1. register() cria o cliente (sem token)
//   2. login(cpf) faz POST /auth/login?cpf=... e guarda o JWT
//   3. Todas as outras chamadas mandam Authorization: Bearer <token>
//      O app gera o próprio token no login — NÃO copie o token do Swagger.
//
// Atenção: login é só por CPF (query param, sem senha e sem body).
// O Render gratuito pode demorar na primeira chamada (cold start).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'utils/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ---------- Modelos ----------

class Cliente {
  final String id; // = CPF, 11 dígitos
  final String nome;
  final String dataNascimento; // YYYY-MM-DD
  final String endereco;

  Cliente({
    required this.id,
    required this.nome,
    required this.dataNascimento,
    required this.endereco,
  });

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
        id: j['id'] as String,
        nome: j['nome'] as String,
        dataNascimento: j['data_nascimento'] as String,
        endereco: j['endereco'] as String,
      );
}

class Conta {
  final String clienteId;
  final int numero;
  final String agencia; // fixa '0001'
  final String dataCriacao;

  Conta({
    required this.clienteId,
    required this.numero,
    required this.agencia,
    required this.dataCriacao,
  });

  factory Conta.fromJson(Map<String, dynamic> j) => Conta(
        clienteId: j['cliente_id'] as String,
        numero: j['numero'] as int,
        agencia: j['agencia'] as String,
        dataCriacao: j['data_criacao'] as String,
      );
}

class Transacao {
  final int id;
  final int contaId;
  final double valor;
  final String tipo;
  final String dataHora;
  final double? saldoApos;

  Transacao({
    required this.id,
    required this.contaId,
    required this.valor,
    required this.tipo,
    required this.dataHora,
    this.saldoApos,
  });

  factory Transacao.fromJson(Map<String, dynamic> j) => Transacao(
        id: j['id'] as int,
        contaId: j['conta_id'] as int,
        valor: (j['valor'] as num).toDouble(),
        tipo: j['tipo'] as String,
        dataHora: j['data_hora'] as String,
        saldoApos: j['saldo_apos'] == null
            ? null
            : (j['saldo_apos'] as num).toDouble(),
      );
}

class LogEntry {
  final int id;
  final String timestamp;
  final String? funcName;
  final String? payload;
  final String? status;

  LogEntry({
    required this.id,
    required this.timestamp,
    this.funcName,
    this.payload,
    this.status,
  });

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
        id: j['id'] as int,
        timestamp: j['timestamp'] as String,
        funcName: j['func_name'] as String?,
        payload: j['payload'] as String?,
        status: j['status'] as String?,
      );
}

// ---------- Serviço ----------

class CapiBankApi {
  static const String baseUrl = 'https://desafio-capi-bank.onrender.com';

  final http.Client _http;
  final TokenStorage _storage;

  CapiBankApi({http.Client? httpClient, TokenStorage? storage})
      : _http = httpClient ?? http.Client(),
        _storage = storage ?? TokenStorage();

  // ----- Token -----

  Future<String?> getToken() => _storage.readToken();
  Future<bool> get isLoggedIn async => await getToken() != null;
  Future<void> logout() => _storage.deleteToken();

  Map<String, String> _headers(String? token, {bool json = false}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw ApiException(401, 'Sem token. Faça login primeiro.');
    }
    return token;
  }

  dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return res.body;
    }
  }

  Never _throwIfError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      throw StateError('unreachable');
    }
    final body = _decode(res);
    String msg = 'Erro ${res.statusCode}';
    if (body is Map && body['detail'] != null) {
      final d = body['detail'];
      msg = d is String ? d : d.toString();
    } else if (body is String && body.isNotEmpty) {
      msg = body;
    }
    throw ApiException(res.statusCode, msg);
  }

  // ----- Autenticação [lg] -----
  // POST /auth/login?cpf=12345678901
  // 200 -> {"access_token": "...", "token_type": "bearer"}

  Future<String> login(String cpf) async {
    final cleanCpf = cpf.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse(
        '$baseUrl/auth/login?cpf=${Uri.encodeComponent(cleanCpf)}');
    final res = await _http.post(uri);
    if (res.statusCode != 200) _throwIfError(res);
    final body = _decode(res) as Map<String, dynamic>;
    final token = body['access_token'] as String;
    await _storage.saveToken(token);
    return token;
  }

  // ----- Clientes [nu] -----
  // POST /clientes/ — sem autenticação
  // Body: {"cpf","nome","data_nascimento":"YYYY-MM-DD","endereco"}

  Future<Cliente> register({
    required String cpf,
    required String nome,
    required String dataNascimento, // YYYY-MM-DD
    required String endereco,
  }) async {
    final uri = Uri.parse('$baseUrl/clientes/');
    final res = await _http.post(
      uri,
      headers: _headers(null, json: true),
      body: jsonEncode({
        'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
        'nome': nome,
        'data_nascimento': dataNascimento,
        'endereco': endereco,
      }),
    );
    if (res.statusCode != 201) _throwIfError(res);
    return Cliente.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // GET /clientes/me — Bearer

  Future<Cliente> getMe() async {
    final token = await _requireToken();
    final res = await _http.get(
      Uri.parse('$baseUrl/clientes/me'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) _throwIfError(res);
    return Cliente.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ----- Contas [nc] -----
  // GET /contas/ — Bearer

  Future<List<Conta>> listAccounts() async {
    final token = await _requireToken();
    final res = await _http.get(
      Uri.parse('$baseUrl/contas/'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) _throwIfError(res);
    final list = _decode(res) as List;
    return list
        .map((e) => Conta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // POST /contas/ — Bearer, sem body. Agência fixa '0001'.

  Future<Conta> createAccount() async {
    final token = await _requireToken();
    final res = await _http.post(
      Uri.parse('$baseUrl/contas/'),
      headers: _headers(token),
    );
    if (res.statusCode != 201) _throwIfError(res);
    return Conta.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ----- Saldo e extrato [ex] -----

  /// GET /contas/{numero}/saldo — Bearer
  /// O Swagger não tipa o retorno, então aceita número direto
  /// ou objeto {"saldo": ...}.
  Future<double> getBalance(int numero) async {
    final token = await _requireToken();
    final res = await _http.get(
      Uri.parse('$baseUrl/contas/$numero/saldo'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) _throwIfError(res);
    final body = _decode(res);
    if (body is num) return body.toDouble();
    if (body is Map) {
      for (final key in ['saldo', 'balance', 'valor']) {
        if (body[key] is num) return (body[key] as num).toDouble();
      }
    }
    throw ApiException(
        200, 'Formato de saldo inesperado: ${res.body}');
  }

  /// GET /contas/{numero}/extrato — Bearer
  Future<List<Transacao>> getStatement(int numero) async {
    final token = await _requireToken();
    final res = await _http.get(
      Uri.parse('$baseUrl/contas/$numero/extrato'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) _throwIfError(res);
    final list = _decode(res) as List;
    return list
        .map((e) => Transacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ----- Depósito [de] -----
  // POST /contas/{numero}/depositar?valor=100.0 — Bearer, 201

  Future<Transacao> deposit(int numero, double valor) async {
    final token = await _requireToken();
    final uri = Uri.parse(
        '$baseUrl/contas/$numero/depositar?valor=$valor');
    final res = await _http.post(uri, headers: _headers(token));
    if (res.statusCode != 201) _throwIfError(res);
    return Transacao.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ----- Saque [sa] — Double Guard -----
  // POST /contas/{numero}/sacar?valor=100.0 — Bearer, 201
  // Máx R$ 500 por operação, máx 3 saques/dia,
  // máx 10 transações/dia, máx R$ 1.200/dia, saldo não negativo.

  Future<Transacao> withdraw(int numero, double valor) async {
    final token = await _requireToken();
    final uri =
        Uri.parse('$baseUrl/contas/$numero/sacar?valor=$valor');
    final res = await _http.post(uri, headers: _headers(token));
    if (res.statusCode != 201) _throwIfError(res);
    return Transacao.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ----- Transferência -----
  // POST /contas/{numero}/transferir?destino=2&valor=50.0 — Bearer, 201
  // Double Guard aplicado na conta de origem.

  Future<Transacao> transfer({
    required int origem,
    required int destino,
    required double valor,
  }) async {
    final token = await _requireToken();
    final uri = Uri.parse(
        '$baseUrl/contas/$origem/transferir?destino=$destino&valor=$valor');
    final res = await _http.post(uri, headers: _headers(token));
    if (res.statusCode != 201) _throwIfError(res);
    return Transacao.fromJson(_decode(res) as Map<String, dynamic>);
  }

  // ----- Auditoria [lt] -----
  // GET /logs/?limit=100 — Bearer

  Future<List<LogEntry>> listLogs({int limit = 100}) async {
    final token = await _requireToken();
    final res = await _http.get(
      Uri.parse('$baseUrl/logs/?limit=$limit'),
      headers: _headers(token),
    );
    if (res.statusCode != 200) _throwIfError(res);
    final list = _decode(res) as List;
    return list
        .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ---------- Exemplo de uso ----------
//
// final api = CapiBankApi();
//
// // 1. Cadastro (primeiro acesso, sem token)
// await api.register(
//   cpf: '12345678901',
//   nome: 'Capibaribe',
//   dataNascimento: '1990-01-01',
//   endereco: 'Crato, CE',
// );
//
// // 2. Login — o app gera o próprio bearer aqui
// await api.login('12345678901');
//
// // 3. Usar os endpoints com o token guardado
// final eu = await api.getMe();
// final contas = await api.listAccounts();
// final conta = contas.isEmpty ? await api.createAccount() : contas.first;
// final saldo = await api.getBalance(conta.numero);
// await api.deposit(conta.numero, 100.0);
// final extrato = await api.getStatement(conta.numero);
