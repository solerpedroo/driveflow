import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../authentication/data/datasources/supabase_auth_datasource.dart';
import '../../../authentication/data/mappers/user_mapper.dart';
import '../../../authentication/data/schema/profile_schema.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../../core/constants/driver_type.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/storage/supabase_storage_urls.dart';

/// Atualização de perfil e avatar.
class ProfileRepository {
  ProfileRepository({
    ProfileRemoteDataSource? profileDataSource,
    SupabaseClient? client,
  })  : _profiles = profileDataSource ?? ProfileRemoteDataSource(),
        _client = client ?? Supabase.instance.client;

  final ProfileRemoteDataSource _profiles;
  final SupabaseClient _client;

  static const _avatarBucket = 'avatars';

  Future<UserEntity> updateName({
    required String userId,
    required String name,
  }) async {
    await _profiles.upsertProfile(id: userId, name: name.trim());
    final row = await _profiles.fetchProfile(userId);
    if (row == null) {
      throw const ServerFailure(message: 'Perfil não encontrado.');
    }
    return UserMapper.fromProfileRow(row);
  }

  Future<UserEntity> updateDriverType({
    required String userId,
    required DriverType driverType,
  }) async {
    await _profiles.updateDriverType(userId: userId, driverType: driverType);
    final row = await _profiles.fetchProfile(userId);
    if (row == null) {
      throw const ServerFailure(message: 'Perfil não encontrado.');
    }
    return UserMapper.fromProfileRow(row);
  }

  Future<UserEntity> completeWelcomeOnboarding({
    required String userId,
  }) async {
    await _profiles.markWelcomeOnboardingComplete(userId);
    final row = await _profiles.fetchProfile(userId);
    if (row == null) {
      throw const ServerFailure(message: 'Perfil não encontrado.');
    }
    return UserMapper.fromProfileRow(row);
  }

  Future<UserEntity> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final objectPath = '$userId/avatar.$extension';

    try {
      await _client.storage.from(_avatarBucket).upload(
            objectPath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      await _client.from(ProfileSchema.table).update({
        ProfileSchema.photo: objectPath,
      }).eq(ProfileSchema.id, userId);

      final row = await _profiles.fetchProfile(userId);
      if (row == null) {
        throw const ServerFailure(message: 'Perfil não encontrado.');
      }
      final photo = row[ProfileSchema.photo] as String?;
      if (photo != null && !SupabaseStorageUrls.isRemoteUrl(photo)) {
        final signed = await SupabaseStorageUrls.resolveAvatarUrl(photo);
        if (signed != null) {
          return UserMapper.fromProfileRow({
            ...row,
            ProfileSchema.photo: signed,
          });
        }
      }
      return UserMapper.fromProfileRow(row);
    } on StorageException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    } on PostgrestException catch (e) {
      throw ServerFailure(message: e.message, cause: e);
    }
  }
}
