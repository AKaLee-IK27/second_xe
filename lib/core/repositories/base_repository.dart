import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

abstract class BaseRepository {
  final SupabaseClient _client = SupabaseService.client;

  String get tableName;

  // Protected getter for subclasses to access the client
  SupabaseClient get client => _client;

  // Generic CRUD operations
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await _client.from(tableName).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch data from $tableName: $e');
    }
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response =
          await _client.from(tableName).select().eq('id', id).maybeSingle();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch item from $tableName: $e');
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from(tableName).insert(data).select().single();
      return response;
    } catch (e) {
      throw Exception('Failed to create item in $tableName: $e');
    }
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await _client
              .from(tableName)
              .update(data)
              .eq('id', id)
              .select()
              .single();
      return response;
    } catch (e) {
      throw Exception('Failed to update item in $tableName: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete item from $tableName: $e');
    }
  }

  // Real-time subscription
  RealtimeChannel subscribeToChanges({
    required Function(PostgresChangePayload) onInsert,
    required Function(PostgresChangePayload) onUpdate,
    required Function(PostgresChangePayload) onDelete,
  }) {
    return _client
        .channel('public:$tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: tableName,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: tableName,
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: tableName,
          callback: onDelete,
        )
        .subscribe();
  }
}
