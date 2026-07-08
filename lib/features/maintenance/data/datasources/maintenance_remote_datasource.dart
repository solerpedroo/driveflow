import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/maintenance_entity.dart';
import '../mappers/maintenance_mapper.dart';
import '../schema/maintenance_schema.dart';

class MaintenanceRemoteDataSource {
  MaintenanceRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchMaintenance() {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(MaintenanceSchema.table)
        .stream(primaryKey: [MaintenanceSchema.id])
        .eq(MaintenanceSchema.userId, userId)
        .order(MaintenanceSchema.serviceDate, ascending: false);
  }

  Future<List<Map<String, dynamic>>> fetchMaintenance({
    required String vehicleId,
  }) async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(MaintenanceSchema.table)
        .select()
        .eq(MaintenanceSchema.userId, userId)
        .eq(MaintenanceSchema.vehicleId, vehicleId)
        .order(MaintenanceSchema.serviceDate, ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>?> fetchMaintenanceById(String id) async {
    final userId = _userId;
    if (userId == null) return null;

    return _client
        .from(MaintenanceSchema.table)
        .select()
        .eq(MaintenanceSchema.id, id)
        .eq(MaintenanceSchema.userId, userId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> createMaintenance({
    required MaintenanceDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      return await _client
          .from(MaintenanceSchema.table)
          .insert(MaintenanceMapper.toInsert(userId: userId, draft: draft))
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> updateMaintenance({
    required String id,
    required MaintenanceDraft draft,
  }) async {
    try {
      return await _client
          .from(MaintenanceSchema.table)
          .update(MaintenanceMapper.toUpdate(draft))
          .eq(MaintenanceSchema.id, id)
          .select()
          .single();
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<void> deleteMaintenance(String id) async {
    try {
      await _client
          .from(MaintenanceSchema.table)
          .delete()
          .eq(MaintenanceSchema.id, id);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }
}
