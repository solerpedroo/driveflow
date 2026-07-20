import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/remote_data_source_errors.dart';
import '../../domain/entities/earning_entity.dart';
import '../mappers/earnings_mapper.dart';
import '../schema/earnings_schema.dart';

class EarningsRemoteDataSource {
  EarningsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  String? get currentUserId => _userId;

  Stream<List<Map<String, dynamic>>> watchEarnings() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(EarningsSchema.table)
        .stream(primaryKey: [EarningsSchema.id])
        .eq(EarningsSchema.userId, userId)
        .order(EarningsSchema.date, ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchEarnings() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(EarningsSchema.table)
        .select()
        .eq(EarningsSchema.userId, userId)
        .order(EarningsSchema.date, ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> createEarning({
    required EarningDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(EarningsSchema.table)
          .insert(EarningsMapper.toInsert(userId: userId, draft: draft))
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }

  Future<Map<String, dynamic>> updateEarning({
    required String id,
    required EarningDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(EarningsSchema.table)
          .update(EarningsMapper.toUpdate(draft))
          .eq(EarningsSchema.id, id)
          .eq(EarningsSchema.userId, userId)
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }

  Future<void> deleteEarning(String id) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      await _client
          .from(EarningsSchema.table)
          .delete()
          .eq(EarningsSchema.id, id)
          .eq(EarningsSchema.userId, userId);
    } on PostgrestException catch (e) {
      throw RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }
}
