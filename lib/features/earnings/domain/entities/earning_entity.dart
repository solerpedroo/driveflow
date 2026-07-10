import '../../../../core/constants/ride_platforms.dart';
import '../../../integrations/domain/entities/earning_source.dart';

/// Ganho registrado pelo motorista.
class EarningEntity {
  const EarningEntity({
    required this.id,
    required this.userId,
    required this.platform,
    required this.amount,
    required this.rides,
    required this.workedHours,
    required this.date,
    this.vehicleId,
    this.note,
    this.source = EarningSource.manual,
    this.externalId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final RidePlatform platform;
  final double amount;
  final int rides;
  final double workedHours;
  final DateTime date;
  final String? vehicleId;
  final String? note;
  final EarningSource source;
  final String? externalId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EarningEntity copyWith({
    String? id,
    String? userId,
    RidePlatform? platform,
    double? amount,
    int? rides,
    double? workedHours,
    DateTime? date,
    String? vehicleId,
    String? note,
    EarningSource? source,
    String? externalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EarningEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      amount: amount ?? this.amount,
      rides: rides ?? this.rides,
      workedHours: workedHours ?? this.workedHours,
      date: date ?? this.date,
      vehicleId: vehicleId ?? this.vehicleId,
      note: note ?? this.note,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Dados para criar ou atualizar um ganho.
class EarningDraft {
  const EarningDraft({
    required this.platform,
    required this.amount,
    required this.rides,
    required this.workedHours,
    required this.date,
    this.vehicleId,
    this.note,
    this.source = EarningSource.manual,
    this.externalId,
  });

  final RidePlatform platform;
  final double amount;
  final int rides;
  final double workedHours;
  final DateTime date;
  final String? vehicleId;
  final String? note;
  final EarningSource source;
  final String? externalId;
}
