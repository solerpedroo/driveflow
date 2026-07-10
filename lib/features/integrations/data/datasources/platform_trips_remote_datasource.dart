import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../schema/platform_trips_schema.dart';

class PlatformTripsRemoteDataSource {
  PlatformTripsRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Stream<List<Map<String, dynamic>>> watchTrips({int limit = 500}) {
    final userId = _userId;
    if (userId == null) return Stream.value(const []);

    return _client
        .from(PlatformTripsSchema.table)
        .stream(primaryKey: [PlatformTripsSchema.id])
        .eq(PlatformTripsSchema.userId, userId)
        .order(PlatformTripsSchema.startedAt, ascending: false)
        .limit(limit);
  }

  Future<List<Map<String, dynamic>>> fetchTrips({
    RidePlatform? platform,
    int limit = 200,
  }) async {
    final userId = _userId;
    if (userId == null) return const [];

    var builder = _client
        .from(PlatformTripsSchema.table)
        .select()
        .eq(PlatformTripsSchema.userId, userId);

    if (platform != null) {
      builder = builder.eq(PlatformTripsSchema.platform, platform.value);
    }

    final rows = await builder
        .order(PlatformTripsSchema.startedAt, ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }
}
