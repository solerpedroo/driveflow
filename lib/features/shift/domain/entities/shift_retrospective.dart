import '../../../../core/constants/ride_platforms.dart';
import 'shift_block_outcome.dart';
import 'shift_history_entry.dart';

/// Retrospectiva detalhada de um turno encerrado.
class ShiftRetrospective {
  const ShiftRetrospective({
    required this.entry,
    required this.platformBreakdown,
    required this.blockOutcomes,
    required this.insight,
  });

  final ShiftHistoryEntry entry;
  final List<ShiftPlatformSlice> platformBreakdown;
  final List<ShiftBlockOutcome> blockOutcomes;
  final String insight;
}

class ShiftPlatformSlice {
  const ShiftPlatformSlice({
    required this.platform,
    required this.revenue,
    required this.share,
  });

  final RidePlatform platform;
  final double revenue;
  final double share;
}
