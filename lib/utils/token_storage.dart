// Guarda o Bearer do Capi-Bank de forma compatível com Web.
// Por que não flutter_secure_storage aqui:
// ele puxa flutter_secure_storage_web, que usa dart:html / dart:js_util,
// e isso quebra o build Web / WASM no Flutter 3.50 (stable).
// SharedPreferences funciona no Web, Android e iOS, e usa
// localStorage no Web. Para a V1 do Capi-Bank é o suficiente.
// Na V2, se quiser cofre seguro no celular, dá para voltar a usar
// flutter_secure_storage só no mobile com import condicional.

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'capi_bank_token';

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
