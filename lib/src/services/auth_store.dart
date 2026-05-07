import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthUserProfile {
  const AuthUserProfile({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  String get initial {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final source = trimmedName.isNotEmpty ? trimmedName : trimmedEmail;

    if (source.isEmpty) return '';

    return source.substring(0, 1).toUpperCase();
  }
}

class AuthStore {
  // Instância privada do storage seguro
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyUserName = 'auth_user_name';
  static const _keyUserEmail = 'auth_user_email';

  // Salva no disco de forma segura
  static Future<void> setToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);

    final profile = _profileFromToken(token);
    await setUserProfile(
      name: profile.name,
      email: profile.email,
    );
  }

  // Recupera do disco (assíncrono)
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> setUserProfile({
    String? name,
    String? email,
  }) async {
    final trimmedName = name?.trim();
    final trimmedEmail = email?.trim();

    if (trimmedName != null) {
      if (trimmedName.isEmpty) {
        await _storage.delete(key: _keyUserName);
      } else {
        await _storage.write(key: _keyUserName, value: trimmedName);
      }
    }

    if (trimmedEmail != null) {
      if (trimmedEmail.isEmpty) {
        await _storage.delete(key: _keyUserEmail);
      } else {
        await _storage.write(key: _keyUserEmail, value: trimmedEmail);
      }
    }
  }

  static Future<AuthUserProfile> getUserProfile() async {
    final token = await getToken();
    final tokenProfile = _profileFromToken(token);
    final storedName = await _storage.read(key: _keyUserName);
    final storedEmail = await _storage.read(key: _keyUserEmail);

    return AuthUserProfile(
      name: tokenProfile.name.isNotEmpty
          ? tokenProfile.name
          : storedName?.trim() ?? '',
      email: tokenProfile.email.isNotEmpty
          ? tokenProfile.email
          : storedEmail?.trim() ?? '',
    );
  }

  // Deleta para o logout
  static Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);
  }

  // Alias semantico para o fluxo de logout
  static Future<void> logout() async {
    await clear();
  }

  static AuthUserProfile _profileFromToken(String? token) {
    if (token == null || token.trim().isEmpty) {
      return const AuthUserProfile(name: '', email: '');
    }

    final claims = _decodeJwtPayload(token);
    if (claims.isEmpty) {
      return const AuthUserProfile(name: '', email: '');
    }

    return AuthUserProfile(
      name: _findStringClaim(
        claims,
        const ['name', 'nome', 'username', 'user_name'],
      ),
      email: _findStringClaim(
        claims,
        const ['email', 'mail'],
      ),
    );
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};

      final normalizedPayload = base64Url.normalize(parts[1]);
      final decodedPayload = utf8.decode(
        base64Url.decode(normalizedPayload),
      );
      final payload = jsonDecode(decodedPayload);

      if (payload is Map<String, dynamic>) return payload;
      if (payload is Map) return Map<String, dynamic>.from(payload);

      return {};
    } catch (_) {
      return {};
    }
  }

  static String _findStringClaim(
    Map<String, dynamic> claims,
    List<String> keys,
  ) {
    for (final source in _claimSources(claims)) {
      for (final key in keys) {
        final value = source[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    return '';
  }

  static List<Map<String, dynamic>> _claimSources(
    Map<String, dynamic> claims,
  ) {
    final sources = <Map<String, dynamic>>[claims];

    for (final key in const ['user', 'data', 'payload', 'userData']) {
      final nestedValue = claims[key];

      if (nestedValue is Map<String, dynamic>) {
        sources.add(nestedValue);
      } else if (nestedValue is Map) {
        sources.add(Map<String, dynamic>.from(nestedValue));
      }
    }

    return sources;
  }
}
