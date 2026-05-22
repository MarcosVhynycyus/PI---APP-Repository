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

  group('Account — Cadastro de conta financeira', () {
    test('CT01 — Cadastrar conta financeira com dados válidos', () async {
      //ARRANGE
      final body = {
        'description': 'Carteira',
        'balance': 150.00,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Conta cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post('/accounts', body: body);

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Cadastrar conta com saldo zero', () async {
      //ARRANGE
      final body = {
        'description': 'Poupança',
        'balance': 0.00,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Conta cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post('/accounts', body: body);

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT03 — Rejeitar cadastro sem descrição', () async {
      //ARRANGE
      final body = {'balance': 100.00};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: description.'},
        );
      });

      //ACT
      final result = api.post('/accounts', body: body);

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

    test('CT04 — Rejeitar cadastro com saldo negativo', () async {
      //ARRANGE
      final body = {
        'description': 'Conta inválida',
        'balance': -50.00,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'O saldo inicial não pode ser negativo.'},
        );
      });

      //ACT
      final result = api.post('/accounts', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('CT05 — Rejeitar cadastro sem autenticação', () async {
      //ARRANGE
      final body = {
        'description': 'Conta sem auth',
        'balance': 100.00,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.post('/accounts', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT06 — Cadastrar conta com autenticação válida', () async {
      //ARRANGE
      final body = {
        'description': 'Conta Corrente',
        'balance': 500.00,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/accounts');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Conta cadastrada com sucesso.'},
        );
      });

      //ACT
      final response = await api.post('/accounts', body: body, token: token);

      //ASSERT
      expect(response['message'], isA<String>());
    });
  });
}
