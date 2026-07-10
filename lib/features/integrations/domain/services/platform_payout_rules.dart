import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_connection_entity.dart';
import '../entities/platform_payout_policy.dart';

/// Resolve políticas de repasse — catálogo padrão ou override da API parceira.
abstract final class PlatformPayoutRules {
  static const metadataSettlementDaysKey = 'settlement_days';

  static const catalog = <RidePlatform, PlatformPayoutPolicy>{
    RidePlatform.uber: PlatformPayoutPolicy(
      platform: RidePlatform.uber,
      settlementDays: 7,
      cycleLabel: 'Semanal (D+7)',
    ),
    RidePlatform.ninetyNine: PlatformPayoutPolicy(
      platform: RidePlatform.ninetyNine,
      settlementDays: 3,
      cycleLabel: 'Repasse rápido (D+3)',
    ),
    RidePlatform.inDrive: PlatformPayoutPolicy(
      platform: RidePlatform.inDrive,
      settlementDays: 5,
      cycleLabel: 'Semanal (D+5)',
    ),
  };

  static PlatformPayoutPolicy resolve(
    RidePlatform platform, {
    Map<RidePlatform, int>? partnerOverrides,
  }) {
    final overrideDays = partnerOverrides?[platform];
    if (overrideDays != null && overrideDays > 0) {
      return PlatformPayoutPolicy(
        platform: platform,
        settlementDays: overrideDays,
        cycleLabel: 'Parceiro (D+$overrideDays)',
        source: PayoutPolicySource.partnerApi,
      );
    }

    return catalog[platform] ??
        PlatformPayoutPolicy(
          platform: platform,
          settlementDays: 7,
          cycleLabel: 'Padrão (D+7)',
        );
  }

  /// Lê `metadata.settlement_days` gravado pelo adapter OAuth/sync.
  static Map<RidePlatform, int> overridesFromConnections(
    List<PlatformConnectionEntity> connections,
  ) {
    final overrides = <RidePlatform, int>{};
    for (final connection in connections) {
      final days = connection.metadata[metadataSettlementDaysKey];
      if (days is int && days > 0) {
        overrides[connection.platform] = days;
      } else if (days is num && days > 0) {
        overrides[connection.platform] = days.round();
      }
    }
    return overrides;
  }
}
