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

  group('User — Login', () {
    test('CT01 — Realizar login com credenciais válidas', () async {
      //ARRANGE
      final body = {
        'email': 'maria@teste.com',
        'password_hash': '12345678',
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/login');
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
      final response = await api.post('/login', body: body);

      //ASSERT
      expect(response['message'], isA<String>());
      expect(response['token'], token);
    });

    test('CT02 — Rejeitar login com senha incorreta', () async {
      //ARRANGE
      final body = {
        'email': 'maria@teste.com',
        'password_hash': 'senhaerrada',
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/login');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'E-mail ou senha inválidos.'},
        );
      });

      //ACT
      final result = api.post('/login', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT03 — Rejeitar login com usuário inexistente', () async {
      //ARRANGE
      final body = {
        'email': 'naoexiste@teste.com',
        'password_hash': '12345678',
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/login');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'E-mail ou senha inválidos.'},
        );
      });

      //ACT
      final result = api.post('/login', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT04 — Rejeitar login com campos vazios', () async {
      //ARRANGE
      final body = {
        'email': '',
        'password_hash': '',
      };

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/login');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Preencha e-mail e senha.'},
        );
      });

      //ACT
      final result = api.post('/login', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('e-mail')),
        ),
      );
    });

    test('CT05 — Rejeitar login com e-mail ausente no body', () async {
      //ARRANGE
      final body = {'password_hash': '12345678'};

      server.enqueue((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/login');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Campo obrigatório ausente: email.'},
        );
      });

      //ACT
      final result = api.post('/login', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', contains('email')),
        ),
      );
    });

    test('CT06 — Verificar que resposta de login contém token', () async {
      //ARRANGE
      final body = {
        'email': 'maria@teste.com',
        'password_hash': '12345678',
      };

      server.enqueue((request) async {
        await request.respondJson(
          HttpStatus.ok,
          {
            'message': 'Login realizado com sucesso.',
            'token': token,
          },
        );
      });

      //ACT
      final response = await api.post('/login', body: body);

      //ASSERT
      expect(response.keys, containsAll(['message', 'token']));
      expect(response['token'], isA<String>());
      expect(response['token'], isNotEmpty);
    });
  });
}
