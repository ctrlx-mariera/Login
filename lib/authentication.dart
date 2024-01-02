import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Authentication with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _accessToken;
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Authentication() {
    _loadAccessToken();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;

  Future<void> login(String token) async {
    try {
      if (token == 'invalid_token') {
        throw Exception('Invalid token');
      }

      _isLoggedIn = true;
      _accessToken = token;
      notifyListeners();
      await _secureStorage.write(key: 'access_token', value: token);
      _logger.i('User is logged in: $_isLoggedIn');
    } catch (e) {
      _logger.e('Login error: $e');
    }
  }

  set accessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  Future<void> _loadAccessToken() async {
    final storedToken = await _secureStorage.read(key: 'access_token');
    if (storedToken != null) {
      _accessToken = storedToken;
      _isLoggedIn = true;
      notifyListeners();
    }
  }
}
