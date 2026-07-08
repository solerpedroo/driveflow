import '../../domain/entities/user_entity.dart';
import '../schema/profile_schema.dart';

/// Converte linhas Supabase e [User] auth em [UserEntity].
abstract final class UserMapper {
  static UserEntity fromAuthUser({
    required String id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
  }

  static UserEntity fromProfileRow(Map<String, dynamic> row) {
    return UserEntity(
      id: row[ProfileSchema.id] as String,
      email: row[ProfileSchema.email] as String?,
      name: row[ProfileSchema.name] as String?,
      photoUrl: row[ProfileSchema.photo] as String?,
    );
  }

  static Map<String, dynamic> toProfileUpsert({
    required String id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return {
      ProfileSchema.id: id,
      if (email != null) ProfileSchema.email: email,
      if (name != null) ProfileSchema.name: name,
      if (photoUrl != null) ProfileSchema.photo: photoUrl,
    };
  }
}
