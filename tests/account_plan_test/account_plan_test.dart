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

  group('Account Plan — Planos de conta', () {
    test('CT01 — Cadastrar plano de conta com dados válidos', () async {
      //ARRANGE
      final body = {'description': 'Alimentação'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/account-plans');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );
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
      expect(response['message'], isA<String>());
    });

    test('CT02 — Rejeitar plano de conta sem descrição', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/account-plans');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: description.'},
        );
      });

      //ACT
      final result = api.post('/account-plans', body: {}, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('description')),
        ),
      );
    });

    test('CT03 — Rejeitar cadastro de plano sem autenticação', () async {
      //ARRANGE
      final body = {'description': 'Transporte'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/account-plans');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.post('/account-plans', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT04 — Rejeitar plano com descrição duplicada', () async {
      //ARRANGE
      final body = {'description': 'Alimentação'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/account-plans');

        await request.respondJson(
          HttpStatus.conflict,
          {'message': 'Plano de conta já cadastrado.'},
        );
      });

      //ACT
      final result = api.post('/account-plans', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('CT05 — Listar planos de conta do usuário', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/account-plans');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Planos encontrados.',
            'data': [
              {'id_account_plan': 1, 'description': 'Alimentação'},
              {'id_account_plan': 2, 'description': 'Transporte'},
            ],
          },
        );
      });

      //ACT
      final response = await api.get('/account-plans', token: token);
      final plans = response['data'] as List<dynamic>;

      //ASSERT
      expect(plans, isNotEmpty);
      expect(
        (plans.first as Map<String, dynamic>).keys,
        containsAll(['id_account_plan', 'description']),
      );
    });

    test('CT06 — Rejeitar listagem sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/account-plans');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/account-plans');

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
