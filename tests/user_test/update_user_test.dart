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

  group('User — Atualização de dados (/alter)', () {
    test('CT01 — Atualizar usuário autenticado com sucesso', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Souza',
        'password_hash': '87654321',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/alter');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );
        expect(await request.jsonBody(), body);

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Dados atualizados com sucesso.'},
        );
      });

      //ACT
      final response = await api.put('/alter', body: body, token: token);

      //ASSERT
      expect(response['message'], isA<String>());
    });

    test('CT02 — Rejeitar atualização sem token de autenticação', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Souza',
        'password_hash': '87654321',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/alter');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token de autenticação ausente ou inválido.'},
        );
      });

      //ACT
      final result = api.put('/alter', body: body);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('CT03 — Rejeitar atualização com token expirado', () async {
      //ARRANGE
      final body = {
        'name': 'Maria Souza',
        'password_hash': '87654321',
        'active': true,
      };

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/alter');

        await request.respondJson(
          HttpStatus.unauthorized,
          {'message': 'Token expirado.'},
        );
      });

      //ACT
      final result = api.put('/alter', body: body, token: 'token-expirado');

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', contains('Token')),
        ),
      );
    });

    test('CT04 — Rejeitar atualização com dados inválidos', () async {
      //ARRANGE
      final body = {'name': '', 'password_hash': ''};

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/alter');

        await request.respondJson(
          HttpStatus.badRequest,
          {'message': 'Dados inválidos para atualização.'},
        );
      });

      //ACT
      final result = api.put('/alter', body: body, token: token);

      //ASSERT
      await expectLater(
        result,
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('CT05 — Atualizar apenas o nome do usuário', () async {
      //ARRANGE
      final body = {'name': 'Novo Nome'};

      server.enqueue((request) async {
        expect(request.method, 'PUT');
        expect(request.uri.path, '/alter');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        await request.respondJson(
          HttpStatus.ok,
          {'message': 'Dados atualizados com sucesso.'},
        );
      });

      //ACT
      final response = await api.put('/alter', body: body, token: token);

      //ASSERT
      expect(response['message'], isA<String>());
    });
  });
}
