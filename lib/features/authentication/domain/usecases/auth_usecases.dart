import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/constants/driver_type.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}

class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
    required DriverType driverType,
  }) {
    return _repository.signUpWithEmail(
      email: email,
      password: password,
      name: name,
      driverType: driverType,
    );
  }
}

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signInWithGoogle();
}

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<UserEntity?> call() => _repository.watchAuthState();
}
