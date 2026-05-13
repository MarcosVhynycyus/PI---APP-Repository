import 'dart:convert';

class AiResponseModel {
  final String advice;

  const AiResponseModel({
    required this.advice,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('AI_response')) {
      throw const FormatException('AI_response is missing.');
    }

    final advice = _parseAdvice(json['AI_response']);

    if (advice.isEmpty) {
      throw const FormatException('AI_response is empty.');
    }

    return AiResponseModel(advice: advice);
  }

  static String _parseAdvice(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return value.trim();
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value).trim();
    }

    return value.toString().trim();
  }
}
