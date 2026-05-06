import 'api_client.dart';

class LoginResponse {
  final String token;
  final String message;

  LoginResponse({
    required this.token,
    required this.message,
  });
}

class LoginException implements Exception {
  final String message;

  LoginException(this.message);

  @override
  String toString() => message;
}

class LoginService {
  final ApiClient api;

  LoginService({ApiClient? api})
      : api = api ?? ApiClient();

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await api.post(
        '/login',
        body: {
          'email': email.trim(),
          'password_hash': password,
        },
      );

      return LoginResponse(
        token: data['token']?.toString() ?? '',
        message: data['message']?.toString() ?? 'Login realizado com sucesso.',
      );
    } on ApiException catch (e) {
      // Mantém o comportamento de transformar em LoginException
      throw LoginException(e.message);
    } catch (_) {
      throw LoginException(
        'Erro de conexão ao tentar fazer login.',
      );
    }
  }
}