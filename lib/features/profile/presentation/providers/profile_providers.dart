import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/data/datasources/supabase_auth_datasource.dart';
import '../../../authentication/data/mappers/user_mapper.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../../core/constants/driver_type.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<UserEntity?> updateName(String name) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncLoading();
    UserEntity? updated;
    state = await AsyncValue.guard(() async {
      updated = await ref.read(profileRepositoryProvider).updateName(
            userId: user.id,
            name: name,
          );
    });
    if (state.hasError) return null;
    ref.invalidate(userProfileProvider);
    return updated;
  }

  Future<UserEntity?> updateDriverType(DriverType driverType) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncLoading();
    UserEntity? updated;
    state = await AsyncValue.guard(() async {
      updated = await ref.read(profileRepositoryProvider).updateDriverType(
            userId: user.id,
            driverType: driverType,
          );
    });
    if (state.hasError) return null;
    ref.invalidate(userProfileProvider);
    return updated;
  }

  Future<UserEntity?> completeWelcomeOnboarding() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncLoading();
    UserEntity? updated;
    state = await AsyncValue.guard(() async {
      updated =
          await ref.read(profileRepositoryProvider).completeWelcomeOnboarding(
                userId: user.id,
              );
    });
    if (state.hasError) return null;
    ref.invalidate(userProfileProvider);
    return updated;
  }

  Future<UserEntity?> uploadAvatar(File file) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return null;

    state = const AsyncLoading();
    UserEntity? updated;
    state = await AsyncValue.guard(() async {
      updated = await ref.read(profileRepositoryProvider).uploadAvatar(
            userId: user.id,
            imageFile: file,
          );
    });
    if (state.hasError) return null;
    ref.invalidate(userProfileProvider);
    return updated;
  }

  void clearError() => state = const AsyncData(null);
}

final profileControllerProvider =
    NotifierProvider<ProfileController, AsyncValue<void>>(ProfileController.new);

/// Perfil atualizado do Supabase (nome/foto/tipo), complementa auth metadata.
///
/// Faz retries curtos após login — o row pode atrasar um instante após o auth.
final userProfileProvider = FutureProvider<UserEntity?>((ref) async {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return null;

  final remote = ProfileRemoteDataSource();
  Map<String, dynamic>? row;
  for (var attempt = 0; attempt < 3; attempt++) {
    row = await remote.fetchProfile(authUser.id);
    if (row != null) break;
    await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
  }

  if (row == null) return authUser;
  return UserMapper.fromProfileRow(row);
});
