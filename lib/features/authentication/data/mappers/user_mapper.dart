import '../../../../core/constants/driver_type.dart';
import '../../domain/entities/user_entity.dart';
import '../schema/profile_schema.dart';

/// Converte linhas Supabase e [User] auth em [UserEntity].
abstract final class UserMapper {
  static UserEntity fromAuthUser({
    required String id,
    String? email,
    String? name,
    String? photoUrl,
    DriverType? driverType,
    DateTime? onboardingCompletedAt,
  }) {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      driverType: driverType,
      onboardingCompletedAt: onboardingCompletedAt,
    );
  }

  static UserEntity fromProfileRow(Map<String, dynamic> row) {
    final onboardingRaw = row[ProfileSchema.onboardingCompletedAt];
    return UserEntity(
      id: row[ProfileSchema.id] as String,
      email: row[ProfileSchema.email] as String?,
      name: row[ProfileSchema.name] as String?,
      photoUrl: row[ProfileSchema.photo] as String?,
      driverType: _parseDriverType(row[ProfileSchema.driverType] as String?),
      onboardingCompletedAt: onboardingRaw == null
          ? null
          : DateTime.parse(onboardingRaw as String).toUtc(),
    );
  }

  static Map<String, dynamic> toProfileUpsert({
    required String id,
    String? email,
    String? name,
    String? photoUrl,
    DriverType? driverType,
    DateTime? onboardingCompletedAt,
  }) {
    return {
      ProfileSchema.id: id,
      if (email != null) ProfileSchema.email: email,
      if (name != null) ProfileSchema.name: name,
      if (photoUrl != null) ProfileSchema.photo: photoUrl,
      if (driverType != null) ProfileSchema.driverType: driverType.value,
      if (onboardingCompletedAt != null)
        ProfileSchema.onboardingCompletedAt:
            onboardingCompletedAt.toUtc().toIso8601String(),
    };
  }

  static DriverType? _parseDriverType(String? value) {
    if (value == null || value.isEmpty) return null;
    return DriverType.fromValue(value);
  }
}
