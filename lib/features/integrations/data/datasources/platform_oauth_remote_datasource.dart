import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/platform_oauth_session.dart';
import '../../../../core/constants/ride_platforms.dart';

class PlatformOAuthRemoteDataSource {
  PlatformOAuthRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<PlatformOAuthSession> startOAuth({
    required RidePlatform platform,
    required String redirectUri,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'platform-oauth-start',
        body: {
          'platform': platform.value,
          'redirect_uri': redirectUri,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final message = data is Map<String, dynamic>
            ? data['error'] as String? ?? 'Falha ao iniciar OAuth.'
            : 'Falha ao iniciar OAuth.';
        throw ServerFailure(message: message);
      }

      final data = response.data as Map<String, dynamic>;
      return PlatformOAuthSession(
        platform: platform,
        authorizationUrl: data['authorization_url'] as String,
        stateToken: data['state_token'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map
          ? (details['error'] as String?) ??
              e.reasonPhrase ??
              'Falha ao iniciar OAuth.'
          : e.reasonPhrase ?? 'Falha ao iniciar OAuth.';
      throw ServerFailure(message: message, cause: e);
    }
  }
}
