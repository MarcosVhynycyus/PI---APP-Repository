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

  group('Transactor — Cadastro e listagem de transatores', () {
    test('CT01 — Cadastrar transator com dados válidos', () async {
      //ARRANGE
      final body = {'name': 'Supermercado X'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/transactors');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Transator cadastrado com sucesso.'},
        );
      });

      //ACT
      final response = await api.post('/transactors', body: body, token: token);

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Rejeitar transator sem nome', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/transactors');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: name.'},
        );
      });

      //ACT
      final result = api.post('/transactors', body: {}, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('name')),
        ),
      );
    });

    test('CT03 — Rejeitar cadastro sem autenticação', () async {
      //ARRANGE
      final body = {'name': 'Farmácia Y'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/transactors');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.post('/transactors', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT04 — Rejeitar transator com nome duplicado', () async {
      //ARRANGE
      final body = {'name': 'Supermercado X'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/transactors');

        await request.respondJson(
          HttpStatus.conflict,
          {'message': 'Transator já cadastrado.'},
        );
      });

      //ACT
      final result = api.post('/transactors', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });

    test('CT05 — Listar transatores do usuário', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/transactors');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Transatores encontrados.',
            'data': [
              {'id_transactor': 1, 'name': 'Supermercado X'},
              {'id_transactor': 2, 'name': 'Farmácia Y'},
            ],
          },
        );
      });

      //ACT
      final response = await api.get('/transactors', token: token);
      final transactors = response['data'] as List<dynamic>;

      //ASSERT
      expect(transactors, isNotEmpty);
      expect(
        (transactors.first as Map<String, dynamic>).keys,
        containsAll(['id_transactor', 'name']),
      );
    });

    test('CT06 — Retornar lista vazia quando não há transatores', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/transactors');

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Nenhum transator encontrado.', 'data': []},
        );
      });

      //ACT
      final response = await api.get('/transactors', token: token);
      final transactors = response['data'] as List<dynamic>;

      //ASSERT
      expect(transactors, isEmpty);
    });

    test('CT07 — Rejeitar listagem sem autenticação', () async {
      //ARRANGE
      server.enqueue((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/transactors');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.get('/transactors');

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
