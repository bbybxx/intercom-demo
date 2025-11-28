import 'package:graphql_flutter/graphql_flutter.dart';

class DoorService {
  // GraphQL Mutation for opening door
  static const String openDoorMutation = r'''
    mutation OpenDoor($userId: String!, $action: String!) {
      insert_door_logs_one(object: {
        user_id: $userId,
        action: $action,
        timestamp: "now()"
      }) {
        id
        action
        timestamp
      }
    }
  ''';

  // GraphQL Query to fetch door logs
  static const String getDoorLogsQuery = r'''
    query GetDoorLogs($userId: String!, $limit: Int!) {
      door_logs(
        where: {user_id: {_eq: $userId}},
        order_by: {timestamp: desc},
        limit: $limit
      ) {
        id
        action
        timestamp
      }
    }
  ''';

  Future<Map<String, dynamic>> openDoor(
    GraphQLClient client,
    String userId,
  ) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(openDoorMutation),
        variables: {
          'userId': userId,
          'action': 'door_opened',
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        return {
          'success': false,
          'message': result.exception?.graphqlErrors.isNotEmpty == true
              ? result.exception!.graphqlErrors.first.message
              : 'Ошибка при открытии двери',
        };
      }

      if (result.data != null) {
        return {
          'success': true,
          'message': 'Дверь открыта',
          'data': result.data!['insert_door_logs_one'],
        };
      }

      return {
        'success': false,
        'message': 'Неизвестная ошибка',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ошибка: ${e.toString()}',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getDoorLogs(
    GraphQLClient client,
    String userId, {
    int limit = 10,
  }) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(getDoorLogsQuery),
        variables: {
          'userId': userId,
          'limit': limit,
        },
      );

      final QueryResult result = await client.query(options);

      if (result.hasException || result.data == null) {
        return [];
      }

      final logs = result.data!['door_logs'] as List;
      return logs.map((log) => log as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
}
