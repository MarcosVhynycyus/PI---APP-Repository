import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

void main() {
  late TestApiServer server;
  late ApiClient api;

  const token = 'token-ct-finansme';
  const movementId = 501;

  setUp(() async {
    server = await TestApiServer.start();
    api = ApiClient(baseUrl: server.baseUrl);
  });

  tearDown(() async {
    await server.close();
  });

  group('Financial Movement — Exclusão de movimentação', () {
    test('CT01 — Excluir lançamento existente com sucesso', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'DELETE');
        expect(request.uri.path, '/financial-movements/$movementId');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Movimentação excluída com sucesso.'},
        );
      });

      //ACT
      final response = await api.delete(
        '/financial-movements/$movementId',
        token: token,
      );

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Rejeitar exclusão sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'DELETE');
        expect(request.uri.path, '/financial-movements/$movementId');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.delete('/financial-movements/$movementId');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT03 — Rejeitar exclusão de lançamento inexistente', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'DELETE');
        expect(request.uri.path, '/financial-movements/9999');

        await request.respondJson(
          HttpStatus.notFound,
          {'message': 'Movimentação não encontrada.'},
        );
      });

      //ACT
      final result = api.delete('/financial-movements/9999', token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('CT04 — Rejeitar exclusão com token inválido', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'DELETE');
        expect(request.uri.path, '/financial-movements/$movementId');

        await request.respondJson(
          HttpStatus.forbidden,
          {'message': 'Acesso negado. Você não tem permissão para excluir este lançamento.'},
        );
      });

      //ACT
      final result = api.delete(
        '/financial-movements/$movementId',
        token: 'token-invalido',
      );

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });
  });
}
