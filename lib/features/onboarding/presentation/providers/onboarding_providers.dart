import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/driver_type.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

/// Tipo operacional do usuário logado.
final driverTypeProvider = Provider<DriverType>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.driverType ?? DriverType.rideShare;
});

final isTaxiDriverProvider = Provider<bool>((ref) {
  return ref.watch(driverTypeProvider).isTaxi;
});

final isRideShareDriverProvider = Provider<bool>((ref) {
  return ref.watch(driverTypeProvider).isRideShare;
});

/// Perfil ainda não escolheu motorista de app vs taxista (ex.: Google OAuth).
final needsDriverTypeSelectionProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile != null && profile.driverType == null;
});

/// Onboarding editorial de boas-vindas ainda não concluído.
final needsWelcomeOnboardingProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return false;
  if (profile.driverType == null) return false;
  return profile.onboardingCompletedAt == null;
});

extension UserEntityDriverX on UserEntity? {
  DriverType get resolvedDriverType => this?.driverType ?? DriverType.rideShare;
}
