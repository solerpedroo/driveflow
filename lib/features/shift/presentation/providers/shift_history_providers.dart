import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../../core/presentation/providers/sync_providers.dart';
import '../../data/repositories/shift_history_repository_impl.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../../domain/entities/shift_retrospective.dart';
import '../../domain/repositories/shift_history_repository.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/services/shift_history_exporter.dart';
import '../../domain/services/shift_retrospective_exporter.dart';
import '../../domain/services/shift_retrospective_builder.dart';

final shiftHistoryRepositoryProvider = Provider<ShiftHistoryRepository>((ref) {
  return ShiftHistoryRepositoryImpl(
    cache: ref.watch(localEntityCacheProvider),
    syncQueue: ref.watch(pendingSyncQueueProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    syncWorker: ref.watch(syncWorkerProvider),
  );
});

final shiftHistoryStreamProvider =
    StreamProvider.autoDispose<List<ShiftHistoryEntry>>((ref) {
  final watch = ref.watch(shiftHistoryRepositoryProvider).watchHistory();
  return watch;
});

final shiftHistoryDetailProvider =
    FutureProvider.autoDispose.family<ShiftHistoryEntry?, String>((ref, id) async {
  final history = ref.watch(shiftHistoryStreamProvider).valueOrNull;
  if (history != null) {
    for (final entry in history) {
      if (entry.id == id) return entry;
    }
  }
  return ref.read(shiftHistoryRepositoryProvider).readById(id);
});

final shiftRetrospectiveProvider =
    Provider.autoDispose.family<AsyncValue<ShiftRetrospective?>, String>(
        (ref, id) {
  final detailAsync = ref.watch(shiftHistoryDetailProvider(id));
  return detailAsync.when(
    loading: () => const AsyncLoading(),
    error: (error, stackTrace) => AsyncError(error, stackTrace),
    data: (entry) {
      if (entry == null) return const AsyncData(null);
      final earnings =
          ref.watch(earningsStreamProvider).valueOrNull ?? const [];
      return AsyncData(
        ShiftRetrospectiveBuilder.build(entry: entry, earnings: earnings),
      );
    },
  );
});

final shiftHistoryWeekStatsProvider = Provider<ShiftHistoryWeekStats>((ref) {
  final history = ref.watch(shiftHistoryStreamProvider).valueOrNull ?? const [];
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  final recent = history
      .where((entry) => !entry.startedAt.isBefore(cutoff))
      .toList(growable: false);

  if (recent.isEmpty) return ShiftHistoryWeekStats.empty;

  final revenue = recent.fold<double>(0, (sum, e) => sum + e.revenue);
  final rides = recent.fold<int>(0, (sum, e) => sum + e.rides);
  final adherence = recent.fold<double>(0, (sum, e) => sum + e.adherenceScore) /
      recent.length;

  return ShiftHistoryWeekStats(
    shiftCount: recent.length,
    revenue: revenue,
    rides: rides,
    avgAdherence: adherence,
  );
});

class ShiftHistoryWeekStats {
  const ShiftHistoryWeekStats({
    required this.shiftCount,
    required this.revenue,
    required this.rides,
    required this.avgAdherence,
  });

  final int shiftCount;
  final double revenue;
  final int rides;
  final double avgAdherence;

  static const empty = ShiftHistoryWeekStats(
    shiftCount: 0,
    revenue: 0,
    rides: 0,
    avgAdherence: 0,
  );
}

class ShiftHistoryExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> exportCsv() async {
    state = const AsyncLoading();
    String? csv;
    state = await AsyncValue.guard(() async {
      final history =
          await ref.read(shiftHistoryRepositoryProvider).fetchHistory();
      csv = ShiftHistoryExporter.buildCsv(history);
    });
    if (state.hasError) return null;
    return csv;
  }
}

final shiftHistoryExportControllerProvider =
    NotifierProvider<ShiftHistoryExportController, AsyncValue<void>>(
  ShiftHistoryExportController.new,
);

class ShiftRetrospectiveExportController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> exportPdf(ShiftRetrospective retrospective) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ShiftRetrospectiveExporter.sharePdf(retrospective);
      DriveFlowAnalytics.logEvent('shift_retrospective_exported', {'format': 'pdf'});
    });
    return !state.hasError;
  }
}

final shiftRetrospectiveExportControllerProvider =
    NotifierProvider<ShiftRetrospectiveExportController, AsyncValue<void>>(
  ShiftRetrospectiveExportController.new,
);
