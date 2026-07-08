import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/session_secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';
import '../mappers/user_mapper.dart';

/// Implementação Supabase de [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    SupabaseAuthDataSource? authDataSource,
    ProfileRemoteDataSource? profileDataSource,
    SessionSecureStorage? sessionStorage,
    String? oauthRedirectUrl,
  })  : _auth = authDataSource ?? SupabaseAuthDataSource(),
        _profiles = profileDataSource ?? ProfileRemoteDataSource(),
        _sessionStorage = sessionStorage ?? SessionSecureStorage(),
        _oauthRedirectUrl = oauthRedirectUrl ?? kOAuthRedirectUrl;

  final SupabaseAuthDataSource _auth;
  final ProfileRemoteDataSource _profiles;
  final SessionSecureStorage _sessionStorage;
  final String _oauthRedirectUrl;

  @override
  UserEntity? get currentUser => mapAuthUserToEntity(_auth.currentAuthUser);

  @override
  Stream<UserEntity?> watchAuthState() async* {
    yield currentUser;

    await for (final event in _auth.authStateChanges) {
      final session = event.session;
      if (session != null) {
        await _sessionStorage.saveRefreshToken(session.refreshToken);
        try {
          await syncProfile();
        } catch (e, st) {
          debugPrint('DriveFlow: falha ao sincronizar profile: $e\n$st');
        }
      } else {
        await _sessionStorage.clear();
      }

      yield mapAuthUserToEntity(event.session?.user);
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthFailure(message: 'Sessão inválida após login.');
    }
    await syncProfile();
    final resolved = await _resolveUser(user.id);
    return resolved ?? mapAuthUserToEntity(user)!;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      name: name,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthFailure(message: 'Não foi possível criar a conta.');
    }
    await _profiles.upsertProfile(
      id: user.id,
      email: email,
      name: name,
    );
    final resolved = await _resolveUser(user.id);
    return resolved ??
        UserMapper.fromAuthUser(id: user.id, email: email, name: name);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _auth.signInWithGoogle(redirectTo: _oauthRedirectUrl);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _sessionStorage.clear();
  }

  @override
  Future<void> syncProfile() async {
    final authUser = _auth.currentAuthUser;
    if (authUser == null) return;

    final metadata = authUser.userMetadata ?? {};
    await _profiles.upsertProfile(
      id: authUser.id,
      email: authUser.email,
      name: (metadata['name'] ?? metadata['full_name']) as String?,
      photoUrl: (metadata['avatar_url'] ?? metadata['picture']) as String?,
    );
  }

  Future<UserEntity?> _resolveUser(String id) async {
    final row = await _profiles.fetchProfile(id);
    if (row == null) return null;
    return UserMapper.fromProfileRow(row);
  }
}
