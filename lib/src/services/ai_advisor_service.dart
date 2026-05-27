import '../models/ai_response_model.dart';
import 'api_client.dart';
import 'auth_store.dart';

class AiAdvisorException implements Exception {
  final String message;

  AiAdvisorException(this.message);

  @override
  String toString() => message;
}

class AiAdvisorService {
  final ApiClient api;

  AiAdvisorService({ApiClient? api}) : api = api ?? ApiClient();

  Future<String> _getTokenOrThrow() async {
    final token = await AuthStore.getToken();

    if (token == null || token.isEmpty) {
      throw AiAdvisorException(
        'Sessao expirada. Faca login novamente.',
      );
    }

    return token;
  }

  Future<AiResponseModel> getAiResponse() async {
    try {
      final token = await _getTokenOrThrow();

      final response = await api.get(
        '/ai-response',
        token: token,
      );

      if (response is Map<String, dynamic>) {
        return AiResponseModel.fromJson(response);
      }

      if (response is Map) {
        return AiResponseModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }

      throw AiAdvisorException('Resposta invalida da API.');
    } on ApiException catch (e) {
      throw AiAdvisorException(e.message);
    } on AiAdvisorException {
      rethrow;
    } on FormatException {
      throw AiAdvisorException('Resposta invalida da API.');
    } catch (_) {
      throw AiAdvisorException('Connection error with API.');
    }
  }
}
