import '../../../../core/constants/ride_platforms.dart';

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
    this.note,
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
  final String? note;
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
    String? note,
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
      note: note ?? this.note,
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
    this.note,
  });

  final RidePlatform platform;
  final double amount;
  final int rides;
  final double workedHours;
  final DateTime date;
  final String? note;
}
