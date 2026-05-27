import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

void main() {
  late TestApiServer server;
  late ApiClient api;

  const token = 'token-ct-finansme';

  setUp(() async {
    server = await TestApiServer.start();
    api = ApiClient(baseUrl: server.baseUrl);
  });

  tearDown(() async {
    await server.close();
  });

  group('AI Advisor — Conselheiro de IA', () {
    test('CT01 — Gerar resposta do conselheiro de IA para usuário autenticado',
        () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/ai-response');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {
            'AI_response':
                'Revise seus maiores gastos e mantenha uma reserva mensal.',
          },
        );
      });

      //ACT
      final response = await api.get('/ai-response', token: token);

      //ASSERT
      expect(response['AI_response'], isA<String>());
    });

    test('CT02 — Rejeitar consulta ao conselheiro sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/ai-response');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/ai-response');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT03 — Validar que resposta da IA é uma string não vazia', () async {
      //ARRANGE
      server.enqueue((request) async {
        await request.respondJson(
          HttpStatus.ok,
          {
            'AI_response':
                'Você está gastando mais do que ganha. Considere reduzir despesas variáveis.',
          },
        );
      });

      //ACT
      final response = await api.get('/ai-response', token: token);

      //ASSERT
      expect(response['AI_response'], isA<String>());
      expect((response['AI_response'] as String), isNotEmpty);
    });

    test('CT04 — Validar chave de resposta da IA no payload', () async {
      //ARRANGE
      server.enqueue((request) async {
        await request.respondJson(
          HttpStatus.ok,
          {'AI_response': 'Dica financeira gerada com sucesso.'},
        );
      });

      //ACT
      final response = await api.get('/ai-response', token: token);

      //ASSERT
      expect(response.keys, contains('AI_response'));
    });

    test('CT05 — Rejeitar consulta com token expirado', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/ai-response');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token expirado.'},
        );
      });

      //ACT
      final result = api.get('/ai-response', token: 'token-expirado');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', contains('Token')),
        ),
      );
    });
  });
}
