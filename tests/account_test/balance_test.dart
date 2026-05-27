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

  group('Account — Saldo do usuário', () {
    test('CT01 — Consultar saldo do usuário autenticado', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-balance');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Saldo encontrado.',
            'balance': 150.00,
          },
        );
      });

      //ACT
      final response = await api.get('/user-balance', token: token);

      //ASSERT
      expect(response['message'], isA<String>());
      expect(response['balance'], isA<num>());
    });

    test('CT02 — Saldo aumenta após lançamento de receita', () async {
      //ARRANGE
      var balance = 150.00;

      server
        ..enqueue((request) async {
          expect(request.method, 'GET');
          expect(request.uri.path, '/user-balance');

          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        })
        ..enqueue((request) async {
          expect(request.method, 'POST');
          expect(request.uri.path, '/financial-movements');

          final body = await request.jsonBody();
          expect(body['type_movement_id'], 1);
          balance += (body['value'] as num).toDouble();

          await request.respondJson(
            HttpStatus.created,
            {'message': 'Receita cadastrada.'},
          );
        })
        ..enqueue((request) async {
          expect(request.method, 'GET');
          expect(request.uri.path, '/user-balance');

          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        });

      //ACT
      final saldoInicial = await api.get('/user-balance', token: token);

      await api.post(
        '/financial-movements',
        body: {
          'type_movement_id': 1,
          'movement_date': '2026-04-14',
          'due_date': '2026-04-14',
          'payment_date': null,
          'doc_num': 'DOC-001',
          'transator_id': 30,
          'value': 100.00,
          'payment_method_id': 1,
          'situation_id': 1,
          'account_id': 10,
          'account_plan_id': 20,
          'reason': 'Salário',
        },
        token: token,
      );

      final saldoAposReceita = await api.get('/user-balance', token: token);

      //ASSERT
      expect(
        saldoAposReceita['balance'],
        greaterThan(saldoInicial['balance']),
      );
    });

    test('CT03 — Saldo diminui após lançamento de despesa', () async {
      //ARRANGE
      var balance = 150.00;

      server
        ..enqueue((request) async {
          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        })
        ..enqueue((request) async {
          final body = await request.jsonBody();
          expect(body['type_movement_id'], 2);
          balance -= (body['value'] as num).toDouble();

          await request.respondJson(
            HttpStatus.created,
            {'message': 'Despesa cadastrada.'},
          );
        })
        ..enqueue((request) async {
          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        });

      //ACT
      final saldoInicial = await api.get('/user-balance', token: token);

      await api.post(
        '/financial-movements',
        body: {
          'type_movement_id': 2,
          'movement_date': '2026-04-14',
          'due_date': '2026-04-14',
          'payment_date': null,
          'doc_num': 'DOC-002',
          'transator_id': 30,
          'value': 40.00,
          'payment_method_id': 1,
          'situation_id': 1,
          'account_id': 10,
          'account_plan_id': 20,
          'reason': 'Mercado',
        },
        token: token,
      );

      final saldoAposDespesa = await api.get('/user-balance', token: token);

      //ASSERT
      expect(
        saldoAposDespesa['balance'],
        lessThan(saldoInicial['balance']),
      );
    });

    test('CT04 — Validar impacto sequencial de receita e despesa', () async {
      //ARRANGE
      var balance = 150.00;

      server
        ..enqueue((request) async {
          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        })
        ..enqueue((request) async {
          final body = await request.jsonBody();
          balance += (body['value'] as num).toDouble();
          await request.respondJson(HttpStatus.created, {'message': 'Receita cadastrada.'});
        })
        ..enqueue((request) async {
          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        })
        ..enqueue((request) async {
          final body = await request.jsonBody();
          balance -= (body['value'] as num).toDouble();
          await request.respondJson(HttpStatus.created, {'message': 'Despesa cadastrada.'});
        })
        ..enqueue((request) async {
          await request.respondJson(
            HttpStatus.ok,
            {'message': 'Saldo encontrado.', 'balance': balance},
          );
        });

      //ACT
      final saldoInicial = await api.get('/user-balance', token: token);

      await api.post(
        '/financial-movements',
        body: {'type_movement_id': 1, 'movement_date': '2026-04-14', 'due_date': '2026-04-14',
          'payment_date': null, 'doc_num': 'DOC-001', 'transator_id': 30, 'value': 100.00,
          'payment_method_id': 1, 'situation_id': 1, 'account_id': 10, 'account_plan_id': 20, 'reason': 'Receita'},
        token: token,
      );

      final saldoAposReceita = await api.get('/user-balance', token: token);

      await api.post(
        '/financial-movements',
        body: {'type_movement_id': 2, 'movement_date': '2026-04-14', 'due_date': '2026-04-14',
          'payment_date': null, 'doc_num': 'DOC-002', 'transator_id': 30, 'value': 40.00,
          'payment_method_id': 1, 'situation_id': 1, 'account_id': 10, 'account_plan_id': 20, 'reason': 'Despesa'},
        token: token,
      );

      final saldoAposDespesa = await api.get('/user-balance', token: token);

      //ASSERT
      expect(saldoAposReceita['balance'], greaterThan(saldoInicial['balance']));
      expect(saldoAposDespesa['balance'], lessThan(saldoAposReceita['balance']));
    });

    test('CT05 — Rejeitar consulta de saldo sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-balance');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/user-balance');

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
