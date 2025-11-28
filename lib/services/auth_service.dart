import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService extends ChangeNotifier {
  String? _userId;
  String? _phone;
  String? _apartmentNumber;
  bool _isAuthenticated = false;

  String? get userId => _userId;
  String? get phone => _phone;
  String? get apartmentNumber => _apartmentNumber;
  bool get isAuthenticated => _isAuthenticated;

  /// Perform login against Supabase PostgREST endpoint using phone/password
  /// Returns map with {'success': bool, 'message': String}
  Future<Map<String, dynamic>> login(
    dynamic /*GraphQLClient*/ client,
    String phone,
    String password,
  ) async {
    try {
      final uri = Uri.parse(
        '${Config.supabaseRestUrl}/users?phone=eq.${Uri.encodeComponent(phone)}&password_hash=eq.${Uri.encodeComponent(password)}&select=id,phone,apartment_number',
      );

      final response = await http.get(
        uri,
        headers: {
          'apikey': Config.supabaseAnonKey,
          'Authorization': 'Bearer ${Config.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Ошибка подключения к серверу (${response.statusCode})',
        };
      }

      final List data = jsonDecode(response.body) as List;
      if (data.isEmpty) {
        return {'success': false, 'message': 'Неверные учетные данные'};
      }

      final user = data.first as Map<String, dynamic>;

      // Save token and user data (use anon key as demo token)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', Config.supabaseAnonKey);
      await prefs.setString('user_id', user['id']);
      await prefs.setString('phone', user['phone']);
      await prefs.setString('apartment_number', user['apartment_number']);

      _userId = user['id'];
      _phone = user['phone'];
      _apartmentNumber = user['apartment_number'];
      _isAuthenticated = true;
      notifyListeners();

      return {'success': true, 'message': 'Успешный вход'};
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _userId = null;
    _phone = null;
    _apartmentNumber = null;
    _isAuthenticated = false;

    notifyListeners();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _phone = prefs.getString('phone');
    _apartmentNumber = prefs.getString('apartment_number');
    _isAuthenticated = _userId != null;

    notifyListeners();
  }
}
