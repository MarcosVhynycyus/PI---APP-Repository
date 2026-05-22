import 'dart:io';

import 'package:finansme_flutter/src/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_api_server.dart';

void main() {
  late TestApiServer server;
  late ApiClient api;

  setUp(() async {
    server = await TestApiServer.start();
    api = ApiClient(baseUrl: server.baseUrl);
  });

  tearDown(() async {
    await server.close();
  });

  group('User — Cadastro (Signin)', () {
    test('CT01 — Cadastrar usuário com dados válidos', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Silva',
        'email': 'maria@teste.com',
        'password_hash': '12345678',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.created,
          {'message': 'Usuário cadastrado com sucesso.'},
        );
      });

      //ACT
      final response = await api.post('/signin', body: body);

      //ASSERT
      expect(response['message'], isA<String>());
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
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');

        await request.respondJson(
          HttpStatus.conflict,
          {'message': 'E-mail já cadastrado.'},
        );
      });

      //ACT
      final result = api.post('/signin', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having((e) => e.message, 'message', contains('E-mail')),
        ),
      );
    });

    test('CT03 — Rejeitar cadastro com campo obrigatório ausente', () async {
      //ARRANGE
      final body = {
        'email': 'maria@teste.com',
        'password_hash': '12345678',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: name.'},
        );
      });

      //ACT
      final result = api.post('/signin', body: body);

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

    test('CT04 — Rejeitar cadastro com e-mail inválido', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Silva',
        'email': 'email-invalido',
        'password_hash': '12345678',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Formato de e-mail inválido.'},
        );
      });

      //ACT
      final result = api.post('/signin', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('CT05 — Rejeitar cadastro com senha muito curta', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Silva',
        'email': 'maria@teste.com',
        'password_hash': '123',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');

        await request.respondJson(
          HttpStatus.unprocessableEntity,
          {'message': 'A senha deve ter no mínimo 8 caracteres.'},
        );
      });

      //ACT
      final result = api.post('/signin', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422),
        ),
      );
    });

    test('CT06 — Rejeitar cadastro com body vazio', () async {
      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/signin');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Corpo da requisição inválido.'},
        );
      });

      //ACT
      final result = api.post('/signin', body: {});

      //ASSERT
      await expectLater(
        result,
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400)),
      );
    });
  });
}
