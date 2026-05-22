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

  group('Account — Listagem de contas do usuário', () {
    test('CT01 — Listar contas do usuário autenticado', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-accounts');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

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
      final response = await api.get('/user-accounts', token: token);

      final accounts = response['data'] as List<dynamic>;
      final account = accounts.single as Map<String, dynamic>;

      //ASSERT
      expect(response['message'], isA<String>());
      expect(accounts, isNotEmpty);
      expect(
        account.keys,
        containsAll(['id_account', 'description', 'balance']),
      );
    });

    test('CT02 — Listar múltiplas contas do usuário', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-accounts');

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Contas encontradas.',
            'data': [
              {'id_account': 1, 'description': 'Carteira', 'balance': 150.00},
              {'id_account': 2, 'description': 'Poupança', 'balance': 1000.00},
              {'id_account': 3, 'description': 'Conta Corrente', 'balance': 500.00},
            ],
          },
        );
      });

      //ACT
      final response = await api.get('/user-accounts', token: token);
      final accounts = response['data'] as List<dynamic>;

      //ASSERT
      expect(accounts.length, 3);
    });

    test('CT03 — Retornar lista vazia quando usuário não tem contas', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-accounts');

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Nenhuma conta encontrada.',
            'data': [],
          },
        );
      });

      //ACT
      final response = await api.get('/user-accounts', token: token);
      final accounts = response['data'] as List<dynamic>;

      //ASSERT
      expect(accounts, isEmpty);
    });

    test('CT04 — Rejeitar listagem sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/user-accounts');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/user-accounts');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT05 — Validar estrutura completa de cada conta retornada', () async {
      //ARRANGE
      server.enqueue((request) async {
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
      final response = await api.get('/user-accounts', token: token);
      final account = (response['data'] as List<dynamic>).first as Map<String, dynamic>;

      //ASSERT
      expect(account['id_account'], isA<int>());
      expect(account['description'], isA<String>());
      expect(account['balance'], isA<num>());
    });
  });
}
