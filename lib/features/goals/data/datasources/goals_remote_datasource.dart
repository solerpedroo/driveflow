import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/remote_data_source_errors.dart';
import '../../domain/entities/goal_entity.dart';
import '../mappers/goals_mapper.dart';
import '../schema/goals_schema.dart';

class GoalsRemoteDataSource {
  GoalsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<Map<String, dynamic>?> watchGoalsRow() {
    final userId = _userId;
    if (userId == null) return Stream.value(null);

    return _client
        .from(GoalsSchema.table)
        .stream(primaryKey: [GoalsSchema.id])
        .eq(GoalsSchema.userId, userId)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<Map<String, dynamic>?> fetchGoalsRow() async {
    final userId = _userId;
    if (userId == null) return null;

    return _client
        .from(GoalsSchema.table)
        .select()
        .eq(GoalsSchema.userId, userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> upsertGoals({required GoalDraft draft}) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(GoalsSchema.table)
          .upsert(
            GoalsMapper.toUpsert(userId: userId, draft: draft),
            onConflict: GoalsSchema.userId,
          )
          .select()
          .single();
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }
}
