import 'package:graphql_flutter/graphql_flutter.dart';

class DoorService {
  /// Insert a door log via Supabase REST (PostgREST)
  Future<Map<String, dynamic>> openDoor(
    dynamic /*GraphQLClient*/ client,
    String userId,
  ) async {
    try {
      final uri = Uri.parse('${Config.supabaseRestUrl}/door_logs');
      final body = jsonEncode({
        'user_id': userId,
        'action': 'door_opened',
      });

      final response = await http.post(
        uri,
        headers: {
          'apikey': Config.supabaseAnonKey,
          'Authorization': 'Bearer ${Config.supabaseAnonKey}',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': 'Дверь открыта', 'data': data};
      }

      return {
        'success': false,
        'message': 'Ошибка при открытии двери (${response.statusCode})'
      };
    } catch (e) {
      return {'success': false, 'message': 'Ошибка: ${e.toString()}'};
    }
  }

  /// Fetch door logs for a user via Supabase REST
  Future<List<Map<String, dynamic>>> getDoorLogs(
    dynamic /*GraphQLClient*/ client,
    String userId, {
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(
          '${Config.supabaseRestUrl}/door_logs?user_id=eq.$userId&order=timestamp.desc&limit=$limit');

      final response = await http.get(uri, headers: {
        'apikey': Config.supabaseAnonKey,
        'Authorization': 'Bearer ${Config.supabaseAnonKey}',
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200) return [];

      final List data = jsonDecode(response.body) as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
}
