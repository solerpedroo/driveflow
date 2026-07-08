import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../mappers/vehicle_mapper.dart';
import '../schema/vehicle_schema.dart';

/// Acesso remoto à tabela `vehicles`.
class VehicleRemoteDataSource {
  VehicleRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchVehicles() {
    final userId = _userId;
    if (userId == null) {
      return Stream.value(const []);
    }

    return _client
        .from(VehicleSchema.table)
        .stream(primaryKey: [VehicleSchema.id])
        .eq(VehicleSchema.userId, userId)
        .order(VehicleSchema.createdAt);
  }

  Future<List<Map<String, dynamic>>> fetchVehicles() async {
    final userId = _userId;
    if (userId == null) return const [];

    final rows = await _client
        .from(VehicleSchema.table)
        .select()
        .eq(VehicleSchema.userId, userId)
        .order(VehicleSchema.createdAt);

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<Map<String, dynamic>> createVehicle({
    required VehicleDraft draft,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw const AuthFailure(message: 'Sessão expirada. Entre novamente.');
    }

    try {
      final row = await _client
          .from(VehicleSchema.table)
          .insert(VehicleMapper.toInsert(userId: userId, draft: draft))
          .select()
          .single();
      return row;
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<Map<String, dynamic>> updateVehicle({
    required String id,
    required VehicleDraft draft,
  }) async {
    try {
      final row = await _client
          .from(VehicleSchema.table)
          .update(VehicleMapper.toUpdate(draft))
          .eq(VehicleSchema.id, id)
          .select()
          .single();
      return row;
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _client.from(VehicleSchema.table).delete().eq(VehicleSchema.id, id);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }
}
