import '../../../../core/constants/ride_platforms.dart';

/// Atalho de ganho rápido usado para sugestões na captura zero-fricção.
class QuickEarningEntry {
  const QuickEarningEntry({
    required this.platform,
    required this.amount,
    required this.usedAt,
  });

  final RidePlatform platform;
  final double amount;
  final DateTime usedAt;

  Map<String, dynamic> toJson() => {
        'platform': platform.value,
        'amount': amount,
        'usedAt': usedAt.toIso8601String(),
      };

  factory QuickEarningEntry.fromJson(Map<String, dynamic> json) {
    return QuickEarningEntry(
      platform: RidePlatform.fromValue(json['platform'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      usedAt: DateTime.tryParse(json['usedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
