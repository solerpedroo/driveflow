import '../../../../core/constants/ride_platforms.dart';

/// Sessão OAuth iniciada para conectar uma plataforma.
class PlatformOAuthSession {
  const PlatformOAuthSession({
    required this.platform,
    required this.authorizationUrl,
    required this.stateToken,
    required this.expiresAt,
  });

  final RidePlatform platform;
  final String authorizationUrl;
  final String stateToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
