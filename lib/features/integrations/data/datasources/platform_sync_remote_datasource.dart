import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/errors/failure.dart';

/// Cliente da Edge Function `platform-sync` (Uber, 99, InDrive).
class PlatformSyncRemoteDataSource {
  PlatformSyncRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>> syncPlatform({
    required RidePlatform platform,
    int lookbackDays = 30,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'platform-sync',
        body: {
          'platform': platform.value,
          'lookback_days': lookbackDays,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final message = data is Map<String, dynamic>
            ? data['error'] as String? ?? 'Não foi possível atualizar os dados.'
            : 'Não foi possível atualizar os dados.';
        throw ServerFailure(message: message);
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerFailure(
          message: 'Não foi possível atualizar os dados. Tente novamente.',
        );
      }
      return data;
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map
          ? (details['error'] as String?) ??
              e.reasonPhrase ??
              'Não foi possível atualizar os dados.'
          : e.reasonPhrase ?? 'Não foi possível atualizar os dados.';
      throw ServerFailure(message: message, cause: e);
    }
  }
}
