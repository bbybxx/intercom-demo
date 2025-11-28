import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AuthService extends ChangeNotifier {
  String? _userId;
  String? _phone;
  String? _apartmentNumber;
  bool _isAuthenticated = false;

  String? get userId => _userId;
  String? get phone => _phone;
  String? get apartmentNumber => _apartmentNumber;
  bool get isAuthenticated => _isAuthenticated;

  // GraphQL Mutation for Login
  static const String loginMutation = r'''
    mutation Login($phone: String!, $password: String!) {
      login(phone: $phone, password: $password) {
        token
        user {
          id
          phone
          apartment_number
        }
      }
    }
  ''';

  Future<Map<String, dynamic>> login(
    GraphQLClient client,
    String phone,
    String password,
  ) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(loginMutation),
        variables: {
          'phone': phone,
          'password': password,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        return {
          'success': false,
          'message': result.exception?.graphqlErrors.isNotEmpty == true
              ? result.exception!.graphqlErrors.first.message
              : 'Ошибка подключения к серверу',
        };
      }

      if (result.data != null && result.data!['login'] != null) {
        final loginData = result.data!['login'];
        final token = loginData['token'];
        final user = loginData['user'];

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', user['id']);
        await prefs.setString('phone', user['phone']);
        await prefs.setString('apartment_number', user['apartment_number']);

        _userId = user['id'];
        _phone = user['phone'];
        _apartmentNumber = user['apartment_number'];
        _isAuthenticated = true;
        
        notifyListeners();

        return {
          'success': true,
          'message': 'Успешный вход',
        };
      }

      return {
        'success': false,
        'message': 'Неверные учетные данные',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ошибка: ${e.toString()}',
      };
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
