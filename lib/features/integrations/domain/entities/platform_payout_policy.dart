import '../../../../core/constants/ride_platforms.dart';

/// Origem da política de repasse.
enum PayoutPolicySource {
  catalog('Catálogo padrão'),
  partnerApi('API parceiro');

  const PayoutPolicySource(this.label);
  final String label;
}

/// Política de liquidação D+N por plataforma.
class PlatformPayoutPolicy {
  const PlatformPayoutPolicy({
    required this.platform,
    required this.settlementDays,
    required this.cycleLabel,
    this.source = PayoutPolicySource.catalog,
  });

  final RidePlatform platform;
  final int settlementDays;
  final String cycleLabel;
  final PayoutPolicySource source;
}
