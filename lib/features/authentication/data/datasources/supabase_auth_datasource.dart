import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/driver_type.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../mappers/user_mapper.dart';
import '../schema/profile_schema.dart';

/// Acesso direto ao Supabase Auth.
class SupabaseAuthDataSource {
  SupabaseAuthDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;

  User? get currentAuthUser => _auth.currentUser;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e));
    } catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e), cause: e);
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required DriverType driverType,
  }) async {
    try {
      return await _auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'full_name': name,
          'driver_type': driverType.value,
        },
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e));
    } catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e), cause: e);
    }
  }

  Future<void> signInWithGoogle({required String redirectTo}) async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e));
    } catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e), cause: e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(message: AuthFailure.messageForError(e));
    }
  }
}

/// CRUD de perfil em `profiles`.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final response = await _client
        .from(ProfileSchema.table)
        .select()
        .eq(ProfileSchema.id, userId)
        .maybeSingle();
    return response;
  }

  Future<void> upsertProfile({
    required String id,
    String? email,
    String? name,
    String? photoUrl,
    DriverType? driverType,
    DateTime? onboardingCompletedAt,
  }) async {
    await _client.from(ProfileSchema.table).upsert(
          UserMapper.toProfileUpsert(
            id: id,
            email: email,
            name: name,
            photoUrl: photoUrl,
            driverType: driverType,
            onboardingCompletedAt: onboardingCompletedAt,
          ),
        );
  }

  Future<void> updateDriverType({
    required String userId,
    required DriverType driverType,
  }) async {
    await _client.from(ProfileSchema.table).update({
      ProfileSchema.driverType: driverType.value,
    }).eq(ProfileSchema.id, userId);
  }

  Future<void> markWelcomeOnboardingComplete(String userId) async {
    await _client.from(ProfileSchema.table).update({
      ProfileSchema.onboardingCompletedAt:
          DateTime.now().toUtc().toIso8601String(),
    }).eq(ProfileSchema.id, userId);
  }

  Future<void> grantAiDataConsent(String userId) async {
    await _client.from(ProfileSchema.table).update({
      ProfileSchema.aiDataConsentAt:
          DateTime.now().toUtc().toIso8601String(),
    }).eq(ProfileSchema.id, userId);
  }
}

UserEntity? mapAuthUserToEntity(User? user) {
  if (user == null) return null;
  final metadata = user.userMetadata ?? {};
  return UserMapper.fromAuthUser(
    id: user.id,
    email: user.email,
    name: (metadata['name'] ?? metadata['full_name']) as String?,
    photoUrl: (metadata['avatar_url'] ?? metadata['picture']) as String?,
  );
}
