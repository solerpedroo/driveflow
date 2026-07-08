import 'package:flutter_test/flutter_test.dart';

import 'package:driveflow/core/constants/date_range_period.dart';
import 'package:driveflow/core/constants/ride_platforms.dart';
import 'package:driveflow/core/utils/transaction_filters.dart';
import 'package:driveflow/features/earnings/data/mappers/earnings_mapper.dart';
import 'package:driveflow/features/earnings/domain/entities/earning_entity.dart';

void main() {
  group('EarningsMapper', () {
    test('fromRow maps Supabase row to entity', () {
      final entity = EarningsMapper.fromRow({
        'id': 'e1',
        'user_id': 'u1',
        'platform': 'uber',
        'amount': 248.50,
        'rides': 12,
        'worked_hours': 6.5,
        'note': 'Turno noturno',
        'date': '2026-07-08T12:00:00Z',
      });

      expect(entity.platform, RidePlatform.uber);
      expect(entity.amount, 248.50);
      expect(entity.rides, 12);
      expect(entity.workedHours, 6.5);
    });

    test('toInsert serializa draft corretamente', () {
      final map = EarningsMapper.toInsert(
        userId: 'u1',
        draft: EarningDraft(
          platform: RidePlatform.ninetyNine,
          amount: 100,
          rides: 5,
          workedHours: 4,
          date: DateTime(2026, 7, 8),
          note: '  ',
        ),
      );

      expect(map['platform'], '99');
      expect(map['note'], isNull);
    });
  });

  group('TransactionFilters', () {
    test('byDateRange filtra ganhos do mês', () {
      final range = dateRangeForPeriod(
        DateRangePeriod.month,
        DateTime(2026, 7, 15),
      );
      final items = [
        EarningEntity(
          id: '1',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 100,
          rides: 1,
          workedHours: 1,
          date: DateTime(2026, 7, 10),
        ),
        EarningEntity(
          id: '2',
          userId: 'u1',
          platform: RidePlatform.uber,
          amount: 50,
          rides: 1,
          workedHours: 1,
          date: DateTime(2026, 6, 10),
        ),
      ];

      final filtered = TransactionFilters.byDateRange(
        items,
        range,
        (e) => e.date,
      );

      expect(filtered, hasLength(1));
      expect(filtered.first.amount, 100);
    });

    test('sumAmounts totaliza valores', () {
      final total = TransactionFilters.sumAmounts<double>(
        [100.0, 50.25],
        (v) => v,
      );
      expect(total, 150.25);
    });
  });
}
