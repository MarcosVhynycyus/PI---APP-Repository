import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? Env.apiBaseUrl;

  // =========================
  // HEADERS PADRAO
  // =========================
  Map<String, String> _buildHeaders({
    String? token,
    bool includeJsonContentType = false,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // =========================
  // GET
  // =========================
  Future<dynamic> get(String path, {String? token}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _buildHeaders(token: token),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Tempo de resposta da API esgotado.');
    } on http.ClientException {
      throw ApiException('Erro de conexao com o servidor.');
    } catch (_) {
      throw ApiException('Erro de conexao com o servidor.');
    }
  }

  // =========================
  // POST
  // =========================
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _buildHeaders(
              token: token,
              includeJsonContentType: true,
            ),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Tempo de resposta da API esgotado.');
    } on http.ClientException {
      throw ApiException('Erro de conexao com o servidor.');
    } catch (_) {
      throw ApiException('Erro de conexao com o servidor.');
    }
  }

  // =========================
  // PUT
  // =========================
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: _buildHeaders(
              token: token,
              includeJsonContentType: true,
            ),
            body: jsonEncode(body ?? {}),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Tempo de resposta da API esgotado.');
    } on http.ClientException {
      throw ApiException('Erro de conexao com o servidor.');
    } catch (_) {
      throw ApiException('Erro de conexao com o servidor.');
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<dynamic> delete(String path, {String? token}) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: _buildHeaders(token: token),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Tempo de resposta da API esgotado.');
    } on http.ClientException {
      throw ApiException('Erro de conexao com o servidor.');
    } catch (_) {
      throw ApiException('Erro de conexao com o servidor.');
    }
  }

  // =========================
  // TRATAMENTO DE RESPOSTA
  // =========================
  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody = {};

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        // Compatibilidade para respostas textuais.
        decodedBody = {'message': response.body};
      }
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return decodedBody;

      case 204:
        return null;

      case 400:
      case 401:
      case 403:
      case 404:
      case 409:
      case 422:
      case 500:
        final message = decodedBody is Map
            ? decodedBody['message']?.toString() ?? 'Erro desconhecido.'
            : 'Erro desconhecido.';
        throw ApiException(message, statusCode: response.statusCode);

      default:
        throw ApiException(
          'Erro inesperado (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }
}
