import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/remote_data_source_errors.dart';
import '../../domain/entities/fuel_log_entity.dart';
import '../mappers/fuel_log_mapper.dart';
import '../schema/fuel_log_schema.dart';

class FuelRemoteDataSource {
  FuelRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchFuelLogs() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(FuelLogSchema.table)
        .stream(primaryKey: [FuelLogSchema.id])
        .eq(FuelLogSchema.userId, userId)
        .order(FuelLogSchema.createdAt, ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchFuelLogs({
    required String vehicleId,
  }) async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(FuelLogSchema.table)
        .select()
        .eq(FuelLogSchema.userId, userId)
        .eq(FuelLogSchema.vehicleId, vehicleId)
        .order(FuelLogSchema.createdAt, ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> fetchFuelLogById(String id) async {
    final userId = _userId;
    if (userId == null) return null;

    return _client
        .from(FuelLogSchema.table)
        .select()
        .eq(FuelLogSchema.id, id)
        .eq(FuelLogSchema.userId, userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> createFuelLog({
    required FuelLogDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(FuelLogSchema.table)
          .insert(FuelLogMapper.toInsert(userId: userId, draft: draft))
          .select()
          .single();
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }

  Future<Map<String, dynamic>> updateFuelLog({
    required String id,
    required FuelLogDraft draft,
  }) async {
    try {
      return await _client
          .from(FuelLogSchema.table)
          .update(FuelLogMapper.toUpdate(draft))
          .eq(FuelLogSchema.id, id)
          .select()
          .single();
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }

  Future<void> deleteFuelLog(String id) async {
    try {
      await _client.from(FuelLogSchema.table).delete().eq(FuelLogSchema.id, id);
    } on PostgrestException catch (e) {
      RemoteDataSourceErrors.rethrowPostgrest(e);
    }
  }
}
