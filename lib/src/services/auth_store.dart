import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStore {
  // Instância privada do storage seguro
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';

  // Salva no disco de forma segura
  static Future<void> setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Recupera do disco (assíncrono)
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Deleta para o logout
  static Future<void> clear() async {
    await _storage.delete(key: _keyToken);
  }
}