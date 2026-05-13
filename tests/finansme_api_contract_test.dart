import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_api_server.dart';

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

  group('FinansMe API - Testes de contrato', () {
    test('CT01 — Cadastrar usuário com sucesso', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Silva',
        'email': 'maria@teste.com',
        'password_hash': '12345678',
        'active': true,
      };

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/signin');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Usuário cadastrado com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/signin',
        body: body,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT02 — Bloquear cadastro com e-mail duplicado', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Silva',
        'email': 'maria@teste.com',
        'password_hash': '12345678',
        'active': true,
      };

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/signin');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.conflict,
          {'message': 'E-mail já cadastrado.'},
        );
      });

      //ACT
      final result = api.post(
        '/signin',
        body: body,
      );

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.message,
                'message',
                contains('E-mail'),
              ),
        ),
      );
    });

    test('CT03 — Realizar login com sucesso', () async {
      //ARRANGE
      final body = {
        'email': 'maria@teste.com',
        'password_hash': '12345678',
      };

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/login');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Login realizado com sucesso.',
            'token': token,
          },
        );
      });

      //ACT
      final response = await api.post(
        '/login',
        body: body,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );

      expect(
        response['token'],
        token,
      );
    });

    test('CT04 — Atualizar usuário autenticado', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Souza',
        'password_hash': '87654321',
        'active': true,
      };

      server.enqueue((request) async {
        _expectRequest(request, 'PUT', '/alter');
        _expectBearerToken(request, token);
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Dados atualizados com sucesso.'},
        );
      });

      //ACT
      final response = await api.put(
        '/alter',
        body: body,
        token: token,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT05 — Cadastrar conta financeira válida', () async {
      //ARRANGE
      final body = {
        'description': 'Carteira',
        'balance': 150.00,
      };

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/accounts');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Conta cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/accounts',
        body: body,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT06 — Listar contas do usuário', () async {
      //ARRANGE
      server.enqueue((request) async {
        _expectRequest(request, 'GET', '/user-accounts');
        _expectBearerToken(request, token);

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Contas encontradas.',
            'data': [
              {
                'id_account': 1,
                'description': 'Carteira',
                'balance': 150.00,
              },
            ],
          },
        );
      });

      //ACT
      final response = await api.get(
        '/user-accounts',
        token: token,
      );

      final accounts = response['data'] as List<dynamic>;
      final account = accounts.single as Map<String, dynamic>;

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );

      expect(
        accounts,
        isNotEmpty,
      );

      expect(
        account.keys,
        containsAll(['id_account', 'description', 'balance']),
      );
    });

    test('CT07 — Cadastrar plano de conta válido', () async {
      //ARRANGE
      final body = {'description': 'Alimentação'};

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/account-plans');
        _expectBearerToken(request, token);
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Plano de conta cadastrado com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/account-plans',
        body: body,
        token: token,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT08 — Cadastrar transator com autorização', () async {
      //ARRANGE
      final body = {'name': 'Supermercado X'};

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/transactors');
        _expectBearerToken(request, token);
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Transator cadastrado com sucesso.'},
        );
      });

      //ACT
      final response = await api.post(
        '/transactors',
        body: body,
        token: token,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT09 — Registrar movimentação financeira válida', () async {
      //ARRANGE
      final body = _movementBody();

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/financial-movements');
        _expectBearerToken(request, token);
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
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT10 — Rejeitar lançamento com campo obrigatório ausente', () async {
      //ARRANGE
      final body = _movementBody()..remove('reason');

      server.enqueue((request) async {
        _expectRequest(request, 'POST', '/financial-movements');
        _expectBearerToken(request, token);
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: reason.'},
        );
      });

      //ACT
      final result = api.post(
        '/financial-movements',
        body: body,
        token: token,
      );

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 400)
              .having(
                (error) => error.message,
                'message',
                contains('reason'),
              ),
        ),
      );
    });

    test('CT11 — Listar movimentações do usuário', () async {
      //ARRANGE
      server.enqueue((request) async {
        _expectRequest(request, 'GET', '/user-financial-movements');
        _expectBearerToken(request, token);

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Movimentações encontradas.',
            'data': [_movementResponse()],
          },
        );
      });

      //ACT
      final response = await api.get(
        '/user-financial-movements',
        token: token,
      );

      final movements = response['data'] as List<dynamic>;
      final movement = movements.single as Map<String, dynamic>;

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );

      expect(
        movements,
        isNotEmpty,
      );

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

    test('CT12 — Validar impacto do lançamento no saldo', () async {
      //ARRANGE
      var balance = 150.00;

      server
        ..enqueue((request) async {
          _expectRequest(request, 'GET', '/user-balance');
          _expectBearerToken(request, token);

          await request.respondJson(
            HttpStatus.ok,
            {
              'message': 'Saldo encontrado.',
              'balance': balance,
            },
          );
        })
        ..enqueue((request) async {
          _expectRequest(request, 'POST', '/financial-movements');
          _expectBearerToken(request, token);

          final body = await request.jsonBody();
          expect(body['type_movement_id'], 1);

          balance += (body['value'] as num).toDouble();

          await request.respondJson(
            HttpStatus.created,
            {'message': 'Receita cadastrada.'},
          );
        })
        ..enqueue((request) async {
          _expectRequest(request, 'GET', '/user-balance');
          _expectBearerToken(request, token);

          await request.respondJson(
            HttpStatus.ok,
            {
              'message': 'Saldo encontrado.',
              'balance': balance,
            },
          );
        })
        ..enqueue((request) async {
          _expectRequest(request, 'POST', '/financial-movements');
          _expectBearerToken(request, token);

          final body = await request.jsonBody();
          expect(body['type_movement_id'], 2);

          balance -= (body['value'] as num).toDouble();

          await request.respondJson(
            HttpStatus.created,
            {'message': 'Despesa cadastrada.'},
          );
        })
        ..enqueue((request) async {
          _expectRequest(request, 'GET', '/user-balance');
          _expectBearerToken(request, token);

          await request.respondJson(
            HttpStatus.ok,
            {
              'message': 'Saldo encontrado.',
              'balance': balance,
            },
          );
        });

      //ACT
      final saldoInicial = await api.get(
        '/user-balance',
        token: token,
      );

      await api.post(
        '/financial-movements',
        body: _movementBody(
          typeMovementId: 1,
          value: 100.00,
        ),
        token: token,
      );

      final saldoAposReceita = await api.get(
        '/user-balance',
        token: token,
      );

      await api.post(
        '/financial-movements',
        body: _movementBody(
          typeMovementId: 2,
          value: 40.00,
        ),
        token: token,
      );

      final saldoAposDespesa = await api.get(
        '/user-balance',
        token: token,
      );

      //ASSERT
      expect(
        saldoAposReceita['balance'],
        greaterThan(saldoInicial['balance']),
      );

      expect(
        saldoAposDespesa['balance'],
        lessThan(saldoAposReceita['balance']),
      );
    });

    test('CT13 — Alterar lançamento existente', () async {
      //ARRANGE
      final body = _movementBody(reason: 'Compra mensal ajustada');

      server.enqueue((request) async {
        _expectRequest(request, 'PUT', '/financial-movements/501');
        _expectBearerToken(request, token);
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Movimentação atualizada com sucesso.'},
        );
      });

      //ACT
      final response = await api.put(
        '/financial-movements/501',
        body: body,
        token: token,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT14 — Excluir lançamento existente', () async {
      //ARRANGE
      server.enqueue((request) async {
        _expectRequest(request, 'DELETE', '/financial-movements/501');
        _expectBearerToken(request, token);

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Movimentação excluída com sucesso.'},
        );
      });

      //ACT
      final response = await api.delete(
        '/financial-movements/501',
        token: token,
      );

      //ASSERT
      expect(
        response['message'],
        isA<String>(),
      );
    });

    test('CT15 — Gerar resposta do conselheiro de IA', () async {
      //ARRANGE
      server.enqueue((request) async {
        _expectRequest(request, 'GET', '/ai-response');
        _expectBearerToken(request, token);

        await request.respondJson(
          HttpStatus.ok,
          {
            'AI_response':
                'Revise seus maiores gastos e mantenha uma reserva mensal.',
          },
        );
      });

      //ACT
      final response = await api.get(
        '/ai-response',
        token: token,
      );

      //ASSERT
      expect(
        response['AI_response'],
        isA<String>(),
      );
    });
  });
}

void _expectRequest(TestRequest request, String method, String path) {
  expect(
    request.method,
    method,
  );

  expect(
    request.uri.path,
    path,
  );
}

void _expectBearerToken(TestRequest request, String token) {
  expect(
    request.headers.value(HttpHeaders.authorizationHeader),
    'Bearer $token',
  );
}

Map<String, dynamic> _movementBody({
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

Map<String, dynamic> _movementResponse() {
  return {
    'id_financial_movement': 501,
    ..._movementBody(),
  };
}
