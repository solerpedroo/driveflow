import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/features/authentication/data/mappers/user_mapper.dart';
import 'package:driveflow/features/authentication/data/schema/profile_schema.dart';
import 'package:driveflow/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('UserMapper', () {
    test('fromProfileRow maps all fields', () {
      final entity = UserMapper.fromProfileRow({
        ProfileSchema.id: 'uuid-1',
        ProfileSchema.email: 'driver@test.com',
        ProfileSchema.name: 'João Motorista',
        ProfileSchema.photo: 'https://photo.url',
      });

      expect(entity.id, 'uuid-1');
      expect(entity.email, 'driver@test.com');
      expect(entity.name, 'João Motorista');
      expect(entity.photoUrl, 'https://photo.url');
      expect(entity.displayName, 'João Motorista');
    });

    test('fromAuthUser uses email prefix as displayName fallback', () {
      final entity = UserMapper.fromAuthUser(
        id: 'uuid-2',
        email: 'maria@test.com',
      );

      expect(entity.displayName, 'maria');
    });

    test('toProfileUpsert builds upsert payload', () {
      final map = UserMapper.toProfileUpsert(
        id: 'uuid-3',
        email: 'a@b.com',
        name: 'Ana',
      );

      expect(map[ProfileSchema.id], 'uuid-3');
      expect(map[ProfileSchema.email], 'a@b.com');
      expect(map[ProfileSchema.name], 'Ana');
      expect(map.containsKey(ProfileSchema.photo), isFalse);
    });
  });

  group('UserEntity', () {
    test('copyWith preserves unchanged fields', () {
      const original = UserEntity(
        id: '1',
        email: 'x@y.com',
        name: 'Nome',
      );
      final copy = original.copyWith(name: 'Novo');

      expect(copy.id, original.id);
      expect(copy.email, original.email);
      expect(copy.name, 'Novo');
    });
  });
}
