import 'api_client.dart';
import 'auth_store.dart';

class UserException implements Exception {
  final String message;

  UserException(this.message);

  @override
  String toString() => message;
}

class UserService {
  final ApiClient api;

  UserService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw UserException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  Future<String> alterUser({
    required String name,
    required String password,
    bool active = true,
  }) async {
    try {
      final token = await _getTokenOrThrow();
      final payload = _buildAlterPayload(
        name: name,
        password: password,
        active: active,
      );

      final response = await api.put(
        '/alter',
        body: payload,
        token: token,
      );

      await AuthStore.setUserProfile(name: payload['name'] as String);

      if (response is Map) {
        return response['message']?.toString() ??
            'Dados atualizados com sucesso.';
      }

      return 'Dados atualizados com sucesso.';
    } on ApiException catch (e) {
      throw UserException(e.message);
    } on UserException {
      rethrow;
    } catch (_) {
      throw UserException('Erro de conexao com o servidor.');
    }
  }

  Map<String, dynamic> _buildAlterPayload({
    required String name,
    required String password,
    required bool active,
  }) {
    final trimmedName = name.trim();

    if (trimmedName.length < 3) {
      throw UserException('O nome deve ter pelo menos 3 caracteres.');
    }

    if (password.length < 8) {
      throw UserException('A senha deve ter pelo menos 8 caracteres.');
    }

    return {
      'name': trimmedName,
      'password_hash': password,
      'active': active,
    };
  }
}
