import '../../../../core/constants/ride_platforms.dart';
import '../services/platform_catalog.dart';

/// URLs OAuth por plataforma — client usa para abrir navegador.
abstract final class PlatformOAuthService {
  static const redirectScheme = 'io.supabase.driveflow';
  static const redirectPath = 'platform-oauth';

  static String redirectUri() => '$redirectScheme://$redirectPath/';

  static String authorizationPath(RidePlatform platform) {
    final provider = PlatformCatalog.entryFor(platform).oauthProvider;
    return '/functions/v1/platform-oauth-start?platform=${platform.value}&provider=$provider';
  }
}
