import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class TransactorsException implements Exception {
  final String message;

  TransactorsException(this.message);

  @override
  String toString() => message;
}

class TransactorsService {
  final String baseUrl;

  TransactorsService({String? baseUrl})
      : baseUrl = baseUrl ?? Env.apiBaseUrl;

  Future<List<dynamic>> getTransactors() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/transactors'));

      final Map<String, dynamic> body =
          response.body.isNotEmpty
              ? jsonDecode(response.body)
              : {};

      if (response.statusCode == 200) {
        return body['data'] ?? [];
      } else {
        throw TransactorsException(
            'Error fetching transactors.');
      }
    } catch (_) {
      throw TransactorsException(
          'Connection error with API.');
    }
  }
    
    Future<List<dynamic>> getUserTransactors(
      String token)  async {
      try {
      final response = await http.get(
          Uri.parse('$baseUrl/user-transactors'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            }
          );

      final Map<String, dynamic> body =
          response.body.isNotEmpty
              ? jsonDecode(response.body)
              : {};

      if (response.statusCode == 200) {
        return body['data'] ?? [];
      } else {
        throw TransactorsException(
          'Error fetching transactors.');        
      }
    } catch (_) {
      throw TransactorsException(
        'Connection error with API');
    }
      }

    Future<void> createTransactor(
      String token,
      Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw TransactorsException(
          'Error creating transactor.',
        );
      }
    } on TransactorsException {
      rethrow;
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }
    Future<void> updateTransactor(
      String token,
      int id,
      Map<String, dynamic> body,
    ) async {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/transactors/$id'),
          headers: {
            'Content-Type' : 'application/json',
            'Authorization' : 'Bearer $token',
          },
          body: jsonEncode(body),
        );
        if (response.statusCode !=200) {
          throw TransactorsException(
            'Error updating transactor.',
          );
        }
      } catch (_) {
        throw TransactorsException(
          'Connection error with API.',
        );
      }
    }
      Future<void> deleteTransactor(
    String token,
    int id,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transactors/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw TransactorsException(
          'Error deleting transactor.',
        );
      }
    } catch (_) {
      throw TransactorsException(
        'Connection error with API.',
      );
    }
  }
}
      
