import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/utils/local_id_generator.dart';
import 'package:driveflow/features/earnings/data/mappers/earnings_mapper.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';

void main() {
  test('LocalIdGenerator creates ids with local_ prefix', () {
    final id = LocalIdGenerator.create();
    expect(LocalIdGenerator.isLocal(id), isTrue);
    expect(id.startsWith('local_'), isTrue);
  });

  test('EarningsMapper draft round-trip via JSON', () {
    final draft = EarningDraft(
      platform: RidePlatform.uber,
      amount: 200,
      rides: 8,
      workedHours: 5.5,
      date: DateTime(2026, 7, 8, 14),
      note: 'Almoço incluso',
    );

    final restored = EarningsMapper.draftFromJson(EarningsMapper.draftToJson(draft));

    expect(restored.platform, draft.platform);
    expect(restored.amount, draft.amount);
    expect(restored.rides, draft.rides);
    expect(restored.workedHours, draft.workedHours);
    expect(restored.note, draft.note);
  });

  test('EarningsMapper toRow preserves entity fields', () {
    final entity = EarningEntity(
      id: 'e1',
      userId: 'u1',
      platform: RidePlatform.other,
      amount: 99.9,
      rides: 3,
      workedHours: 2,
      date: DateTime(2026, 7, 8),
    );

    final row = EarningsMapper.toRow(entity);
    final restored = EarningsMapper.fromRow(row);

    expect(restored.id, entity.id);
    expect(restored.platform, entity.platform);
    expect(restored.amount, entity.amount);
  });
}
