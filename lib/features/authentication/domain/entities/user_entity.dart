import '../../../../core/constants/driver_type.dart';

/// Usuário autenticado — entidade de domínio imutável.
class UserEntity {
  const UserEntity({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
    this.driverType,
    this.onboardingCompletedAt,
  });

  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final DriverType? driverType;
  final DateTime? onboardingCompletedAt;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (email != null && email!.contains('@')) return email!.split('@').first;
    return driverType?.roleLabel ?? 'Motorista';
  }

  String get roleBadgeLabel => driverType?.label ?? 'Motorista de aplicativo';

  bool get hasSelectedDriverType => driverType != null;

  bool get hasCompletedWelcomeOnboarding => onboardingCompletedAt != null;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DriverType? driverType,
    DateTime? onboardingCompletedAt,
    bool clearDriverType = false,
    bool clearOnboardingCompletedAt = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      driverType: clearDriverType ? null : (driverType ?? this.driverType),
      onboardingCompletedAt: clearOnboardingCompletedAt
          ? null
          : (onboardingCompletedAt ?? this.onboardingCompletedAt),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          photoUrl == other.photoUrl &&
          driverType == other.driverType &&
          onboardingCompletedAt == other.onboardingCompletedAt;

  @override
  int get hashCode => Object.hash(
        id,
        email,
        name,
        photoUrl,
        driverType,
        onboardingCompletedAt,
      );
}
