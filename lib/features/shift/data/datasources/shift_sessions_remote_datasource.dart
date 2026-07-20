import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/remote_data_source_errors.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../mappers/shift_sessions_mapper.dart';
import '../schema/shift_sessions_schema.dart';

class ShiftSessionsRemoteDataSource {
  ShiftSessionsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchHistory() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(ShiftSessionsSchema.table)
        .stream(primaryKey: [ShiftSessionsSchema.id])
        .eq(ShiftSessionsSchema.userId, userId)
        .order(ShiftSessionsSchema.startedAt, ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(ShiftSessionsSchema.table)
        .select()
        .eq(ShiftSessionsSchema.userId, userId)
        .order(ShiftSessionsSchema.startedAt, ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> createCompleted({
    required ShiftHistoryEntry entry,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(ShiftSessionsSchema.table)
          .insert(ShiftSessionsMapper.toInsert(entry))
          .select()
          .single();
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }
}
