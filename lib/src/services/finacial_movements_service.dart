import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';


class FinancialMovementsException implements Exception {
  final String message;
      FinancialMovementsException(this.message);

  @override
  String toString() => message;
}

class FinancialMovementsService {
  final String baseUrl;

  FinancialMovementsService({String? baseUrl})
      : baseUrl = baseUrl ?? Env.apiBaseUrl;

  Future<List<dynamic>> getFinancialMovements(
    String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/financial-movements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final Map<String, dynamic> body =
        response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    } else {
      throw FinancialMovementsException(
          'Error fetching financial movements.');
    }
  } catch (_) {
    throw FinancialMovementsException(
        'Connection error with API.');
  }
}
  
  Future<List<dynamic>> getUserFinancialMovements(
    String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user-financial-movements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        
      },
    );

    final Map<String, dynamic> body =
        response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {};

    if (response.statusCode == 200) {
      return body['data'] ?? [];
    } else {
      throw FinancialMovementsException(
          'Error fetching user financial movements.');
    }
  } catch (_) {
    throw FinancialMovementsException(
        'Connection error with API.');
  }
}
  
  Future<void> createFinancialMovement(
    String token,
    Map<String, dynamic> body) async {
    try {
      final requiredFields = [
        'type_movement_id',
        'movement_date',
        'due_date',
        'payment_date',
        'doc_num',
        'transator_id',
        'value',
        'payment_method_id',
        'situation_id',
        'account_id',
        'account_plan_id',
        'reason',
      ];

      for (final field in requiredFields) {
        if (!body.containsKey(field)) {
          throw FinancialMovementsException(
            'Missing required field: $field',
          );
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/financial-movements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
        body: jsonEncode(body),
    );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw FinancialMovementsException(
            'Error creating financial movement.');
      }
    } on FinancialMovementsException {
      rethrow;
    } catch (_) {
      throw FinancialMovementsException(
          'Connection error with API.');
    }
  }

  Future<void> updateFinancialMovement(
      String token,
      int id,
      Map<String, dynamic> body) async {
    try {
      
      final response = await http.put(
        Uri.parse('$baseUrl/financial-movements/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
      },
        body: jsonEncode(body),
    );

      if (response.statusCode != 200) {
        throw FinancialMovementsException(
            'Error updating financial movement.');
      }
    } catch (_) {
      throw FinancialMovementsException(
          'Connection error with API.');
    }
  }

  Future<void> deleteFinancialMovement(
      String token,
      int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/financial-movements/$id'),
        headers: {
          'Authorization': 'Bearer $token',
       },
    );

      if (response.statusCode != 200) {
        throw FinancialMovementsException(
            'Error deleting financial movement.');
      }
    } catch (_) {
      throw FinancialMovementsException(
          'Connection error with API.');
    }
  }
}