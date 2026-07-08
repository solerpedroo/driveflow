import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/date_range_period.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../../../core/utils/transaction_filters.dart';
import '../../data/repositories/earnings_repository_impl.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../../domain/usecases/earnings_usecases.dart';

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepositoryImpl();
});

final earningsStreamProvider = StreamProvider<List<EarningEntity>>((ref) {
  final watch = WatchEarnings(ref.watch(earningsRepositoryProvider));
  return watch();
});

final earningsPeriodProvider =
    StateProvider<DateRangePeriod>((ref) => DateRangePeriod.month);

final earningsPlatformFilterProvider =
    StateProvider<RidePlatform?>((ref) => null);

final earningsListProvider = Provider<AsyncValue<List<EarningEntity>>>((ref) {
  final stream = ref.watch(earningsStreamProvider);
  final period = ref.watch(earningsPeriodProvider);
  final platform = ref.watch(earningsPlatformFilterProvider);
  final range = dateRangeForPeriod(period);

  return stream.whenData((items) {
    var filtered = TransactionFilters.byDateRange(
      items,
      range,
      (e) => e.date,
    );
    if (platform != null) {
      filtered = filtered.where((e) => e.platform == platform).toList();
    }
    return filtered;
  });
});

final earningsTotalProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(earningsListProvider).whenData(
        (items) => TransactionFilters.sumAmounts(items, (e) => e.amount),
      );
});

final createEarningProvider = Provider<CreateEarning>((ref) {
  return CreateEarning(ref.watch(earningsRepositoryProvider));
});

final updateEarningProvider = Provider<UpdateEarning>((ref) {
  return UpdateEarning(ref.watch(earningsRepositoryProvider));
});

final deleteEarningProvider = Provider<DeleteEarning>((ref) {
  return DeleteEarning(ref.watch(earningsRepositoryProvider));
});

class EarningsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<EarningEntity?> save({
    String? earningId,
    required EarningDraft draft,
  }) async {
    state = const AsyncLoading();
    EarningEntity? saved;
    state = await AsyncValue.guard(() async {
      if (earningId == null) {
        saved = await ref.read(createEarningProvider)(draft);
      } else {
        saved = await ref.read(updateEarningProvider)(
          id: earningId,
          draft: draft,
        );
      }
    });
    if (state.hasError) return null;
    return saved;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteEarningProvider)(id);
    });
    return !state.hasError;
  }

  void clearError() => state = const AsyncData(null);
}

final earningsControllerProvider =
    NotifierProvider<EarningsController, AsyncValue<void>>(EarningsController.new);
