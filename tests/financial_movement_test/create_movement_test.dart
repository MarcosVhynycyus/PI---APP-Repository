import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

Map<String, dynamic> _validMovementBody({
  int typeMovementId = 2,
  double value = 80.50,
  String reason = 'Compra mensal',
}) {
  return {
    'type_movement_id': typeMovementId,
    'movement_date': '2026-04-14',
    'due_date': '2026-04-14',
    'payment_date': null,
    'doc_num': 'DOC-001',
    'transator_id': 30,
    'value': value,
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

  setUp(() async {
    server = await TestApiServer.start();
    api = ApiClient(baseUrl: server.baseUrl);
  });

  tearDown(() async {
    await server.close();
  });

  group('Financial Movement — Criação de movimentação', () {
    test('CT01 — Registrar movimentação financeira válida (despesa)', () async {
      //ARRANGE
      final body = _validMovementBody();

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Movimentação cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/financial-movements',
        body: body,
        token: token,
      );

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Registrar movimentação financeira válida (receita)', () async {
      //ARRANGE
      final body = _validMovementBody(typeMovementId: 1, value: 3000.00, reason: 'Salário');

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');

        final receivedBody = await request.jsonBody();
        expect(receivedBody['type_movement_id'], 1);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Movimentação cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/financial-movements',
        body: body,
        token: token,
      );

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT03 — Rejeitar lançamento com campo obrigatório ausente (reason)', () async {
      //ARRANGE
      final body = _validMovementBody()..remove('reason');

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: reason.'},
        );
      });

      //ACT
      final result = api.post('/financial-movements', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('reason')),
        ),
      );
    });

    test('CT04 — Rejeitar lançamento com valor negativo', () async {
      //ARRANGE
      final body = _validMovementBody(value: -100.00);

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'O valor do lançamento deve ser positivo.'},
        );
      });

      //ACT
      final result = api.post('/financial-movements', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('CT05 — Rejeitar lançamento sem autenticação', () async {
      //ARRANGE
      final body = _validMovementBody();

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.post('/financial-movements', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT06 — Rejeitar lançamento com tipo de movimentação inválido', () async {
      //ARRANGE
      final body = _validMovementBody(typeMovementId: 99);

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/financial-movements');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Tipo de movimentação inválido.'},
        );
      });

      //ACT
      final result = api.post('/financial-movements', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}
