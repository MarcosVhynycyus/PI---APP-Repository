import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

Map<String, dynamic> _validMovementBody({String reason = 'Compra mensal'}) {
  return {
    'type_movement_id': 2,
    'movement_date': '2026-04-14',
    'due_date': '2026-04-14',
    'payment_date': null,
    'doc_num': 'DOC-001',
    'transator_id': 30,
    'value': 80.50,
    'payment_method_id': 1,
    'situation_id': 1,
    'account_id': 10,
    'account_plan_id': 20,
    'reason': reason,
  };
}

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

  group('Financial Movement — Atualização de movimentação', () {
    test('CT01 — Alterar lançamento existente com sucesso', () async {
      //ARRANGE
      final body = _validMovementBody(reason: 'Compra mensal ajustada');

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/financial-movements/$movementId');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Movimentação atualizada com sucesso.'},
        );
      });

      //ACT
      final response = await api.put(
        '/financial-movements/$movementId',
        body: body,
        token: token,
      );

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Rejeitar atualização sem autenticação', () async {
      //ARRANGE
      final body = _validMovementBody();

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/financial-movements/$movementId');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.put('/financial-movements/$movementId', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT03 — Rejeitar atualização de lançamento inexistente', () async {
      //ARRANGE
      final body = _validMovementBody();

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/financial-movements/9999');

        await request.respondJson(
          HttpStatus.notFound,
          {'message': 'Movimentação não encontrada.'},
        );
      });

      //ACT
      final result = api.put('/financial-movements/9999', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('CT04 — Rejeitar atualização com dados inválidos', () async {
      //ARRANGE
      final body = {'value': -999.00};

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/financial-movements/$movementId');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Dados inválidos para atualização.'},
        );
      });

      //ACT
      final result = api.put(
        '/financial-movements/$movementId',
        body: body,
        token: token,
      );

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('CT05 — Atualizar apenas o motivo do lançamento', () async {
      //ARRANGE
      final body = {'reason': 'Ajuste de compra'};

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/financial-movements/$movementId');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Movimentação atualizada com sucesso.'},
        );
      });

      //ACT
      final response = await api.put(
        '/financial-movements/$movementId',
        body: body,
        token: token,
      );

      //ASSERT
      expect(response['message'], isA<String>());
    });
  });
}
