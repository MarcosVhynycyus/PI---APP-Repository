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

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? Env.apiBaseUrl;

  // =========================
  // HEADERS PADRÃO
  // =========================
  Map<String, String> _buildHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

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
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _buildHeaders(token: token),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão com o servidor.');
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
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _buildHeaders(token: token),
        body: jsonEncode(body ?? {}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão com o servidor.');
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
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _buildHeaders(token: token),
        body: jsonEncode(body ?? {}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão com o servidor.');
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<dynamic> delete(String path, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _buildHeaders(token: token),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erro de conexão com o servidor.');
    }
  }

  // =========================
  // TRATAMENTO DE RESPOSTA
  // =========================
  dynamic _handleResponse(http.Response response) {
    dynamic decodedBody;

    try {
      decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      throw ApiException('Erro ao processar resposta do servidor.');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return decodedBody;

      case 204:
        return null;

      case 400:
      case 404:
      case 409:
      case 500:
        final message =
            decodedBody['message'] ?? 'Erro desconhecido.';
        throw ApiException(message, statusCode: response.statusCode);

      default:
        throw ApiException(
          'Erro inesperado (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }
}