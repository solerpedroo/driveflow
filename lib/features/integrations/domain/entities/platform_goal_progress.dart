import '../../../../core/constants/ride_platforms.dart';

/// Progresso de meta diária desmembrada por app.
class PlatformGoalProgress {
  const PlatformGoalProgress({
    required this.platform,
    required this.targetAmount,
    required this.actualAmount,
    required this.progressPercent,
    required this.sharePercent,
  });

  final RidePlatform platform;
  final double targetAmount;
  final double actualAmount;
  final double progressPercent;
  final double sharePercent;
}
