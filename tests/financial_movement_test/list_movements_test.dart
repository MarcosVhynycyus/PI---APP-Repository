import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

Map<String, dynamic> _movementResponse({int id = 501}) {
  return {
    'id_financial_movement': id,
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
    'reason': 'Compra mensal',
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

  group('Financial Movement — Listagem de movimentações', () {
    test('CT01 — Listar movimentações do usuário autenticado', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-financial-movements');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Movimentações encontradas.',
            'data': [_movementResponse()],
          },
        );
      });

      //ACT
      final response = await api.get('/user-financial-movements', token: token);

      final movements = response['data'] as List<dynamic>;
      final movement = movements.single as Map<String, dynamic>;

      //ASSERT
      expect(response['message'], isA<String>());
      expect(movements, isNotEmpty);
      expect(
        movement.keys,
        containsAll([
          'id_financial_movement',
          'type_movement_id',
          'movement_date',
          'due_date',
          'payment_date',
          'doc_num',
          'transator_id',
          'value',
          'situation_id',
          'account_id',
          'account_plan_id',
          'reason',
        ]),
      );
    });

    test('CT02 — Retornar lista vazia quando não há movimentações', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-financial-movements');

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Nenhuma movimentação encontrada.', 'data': []},
        );
      });

      //ACT
      final response = await api.get('/user-financial-movements', token: token);
      final movements = response['data'] as List<dynamic>;

      //ASSERT
      expect(movements, isEmpty);
    });

    test('CT03 — Listar múltiplas movimentações', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-financial-movements');

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Movimentações encontradas.',
            'data': [
              _movementResponse(id: 501),
              _movementResponse(id: 502),
              _movementResponse(id: 503),
            ],
          },
        );
      });

      //ACT
      final response = await api.get('/user-financial-movements', token: token);
      final movements = response['data'] as List<dynamic>;

      //ASSERT
      expect(movements.length, 3);
    });

    test('CT04 — Validar tipos dos campos de cada movimentação retornada', () async {
      //ARRANGE
      server.enqueue((request) async {
        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Movimentações encontradas.',
            'data': [_movementResponse()],
          },
        );
      });

      //ACT
      final response = await api.get('/user-financial-movements', token: token);
      final movement = (response['data'] as List<dynamic>).first as Map<String, dynamic>;

      //ASSERT
      expect(movement['id_financial_movement'], isA<int>());
      expect(movement['type_movement_id'], isA<int>());
      expect(movement['value'], isA<num>());
      expect(movement['reason'], isA<String>());
    });

    test('CT05 — Rejeitar listagem sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-financial-movements');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/user-financial-movements');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}
