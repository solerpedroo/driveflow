import '../entities/user_entity.dart';
import '../../../../core/constants/driver_type.dart';

/// Contrato de autenticação — isolado do Supabase.
abstract interface class AuthRepository {
  Stream<UserEntity?> watchAuthState();

  UserEntity? get currentUser;

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required DriverType driverType,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<void> syncProfile();
}
