import '../../../../core/constants/ride_platforms.dart';

/// Regras de repasse D+N por plataforma.
abstract final class PlatformPayoutRules {
  static int settlementDays(RidePlatform platform) {
    return switch (platform) {
      RidePlatform.uber => 7,
      RidePlatform.ninetyNine => 3,
      RidePlatform.inDrive => 5,
      _ => 7,
    };
  }
}
