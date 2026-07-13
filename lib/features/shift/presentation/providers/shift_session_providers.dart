import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../integrations/domain/entities/platform_shift_plan.dart';
import '../../../integrations/presentation/providers/integrations_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/datasources/shift_session_storage.dart';
import '../../data/repositories/shift_session_repository_impl.dart';
import '../../domain/entities/shift_plan_adherence.dart';
import '../../../../core/constants/ride_platforms.dart';
import '../../domain/entities/shift_history_entry.dart';
import '../../domain/entities/shift_session_entity.dart';
import '../../domain/entities/shift_session_plan_block.dart';
import '../../domain/entities/shift_session_status.dart';
import '../../domain/entities/shift_session_summary.dart';
import '../../domain/repositories/shift_session_repository.dart';
import '../../domain/services/shift_adherence_analyzer.dart';
import '../../domain/services/shift_plan_tracker.dart';
import '../../domain/services/shift_retrospective_builder.dart';
import '../../domain/services/shift_session_aggregator.dart';
import 'shift_history_providers.dart';

final shiftSessionRepositoryProvider = Provider<ShiftSessionRepository>((ref) {
  return ShiftSessionRepositoryImpl();
});

final activeShiftSessionProvider = StreamProvider<ShiftSessionEntity?>((ref) {
  final repository = ref.watch(shiftSessionRepositoryProvider);
  final initial = repository.readActive();
  return repository.watchActive().map((session) {
    return session ?? repository.readActive();
  }).startWith(initial);
});

final shiftSessionSummaryProvider = Provider<ShiftSessionSummary?>((ref) {
  final session = ref.watch(activeShiftSessionProvider).valueOrNull;
  if (session == null) return null;

  final earnings = ref.watch(earningsStreamProvider).valueOrNull ?? const [];
  final goals = ref.watch(goalsStreamProvider).valueOrNull;
  final dailyGoal = goals?.daily ?? 0;

  return ShiftSessionAggregator.summarize(
    session: session,
    earnings: earnings,
    now: DateTime.now(),
    dailyGoal: dailyGoal,
    vehicleId: session.vehicleId,
  );
});

final shiftPlanAdherenceProvider = Provider<ShiftPlanAdherence>((ref) {
  final session = ref.watch(activeShiftSessionProvider).valueOrNull;
  if (session == null) return ShiftPlanAdherence.none;

  final recommendation = ref.watch(platformShiftRecommendationProvider).valueOrNull;
  return ShiftPlanTracker.evaluate(
    session: session,
    now: DateTime.now(),
    recommendation: recommendation,
  );
});

class ShiftSessionController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  ShiftSessionRepository get _repository =>
      ref.read(shiftSessionRepositoryProvider);

  Future<ShiftSessionEntity?> start({
    PlatformShiftPlan? plan,
    required bool isTaxiMode,
  }) async {
    state = const AsyncLoading();
    ShiftSessionEntity? created;
    state = await AsyncValue.guard(() async {
      final existing = _repository.readActive();
      if (existing != null) {
        created = existing;
        return;
      }

      final vehicleId = ref.read(scopedVehicleIdProvider) ??
          ref.read(activeVehicleProvider).valueOrNull?.id;
      final blocks = plan?.blocks
              .map(ShiftSessionPlanBlock.fromPlatform)
              .toList(growable: false) ??
          const <ShiftSessionPlanBlock>[];

      created = await _repository.saveActive(
        ShiftSessionEntity(
          id: 'shift_${DateTime.now().millisecondsSinceEpoch}',
          startedAt: DateTime.now(),
          status: ShiftSessionStatus.active,
          planBlocks: blocks,
          isTaxiMode: isTaxiMode,
          vehicleId: vehicleId,
        ),
      );
    });
    if (state.hasError) return null;
    ShiftSessionStorage.emitCurrent();
    return created;
  }

  Future<bool> pause() => _transition((session) {
        final now = DateTime.now();
        return session.copyWith(
          status: ShiftSessionStatus.paused,
          pausedAt: now,
        );
      });

  Future<bool> resume() => _transition((session) {
        final now = DateTime.now();
        final extraPause = session.pausedAt == null
            ? Duration.zero
            : now.difference(session.pausedAt!);
        return session.copyWith(
          status: ShiftSessionStatus.active,
          accumulatedPause: session.accumulatedPause + extraPause,
          clearPausedAt: true,
        );
      });

  Future<ShiftHistoryEntry?> end() async {
    state = const AsyncLoading();
    ShiftHistoryEntry? archived;
    state = await AsyncValue.guard(() async {
      final active = _repository.readActive();
      if (active == null) return;

      final endedAt = DateTime.now();
      final completed = active.copyWith(
        status: ShiftSessionStatus.completed,
        endedAt: endedAt,
        clearPausedAt: true,
      );

      final earnings = ref.read(earningsStreamProvider).valueOrNull ?? const [];
      final goals = ref.read(goalsStreamProvider).valueOrNull;
      final summary = ShiftSessionAggregator.summarize(
        session: completed,
        earnings: earnings,
        now: endedAt,
        dailyGoal: goals?.daily ?? 0,
        vehicleId: completed.vehicleId,
      );
      final adherence = ShiftAdherenceAnalyzer.analyze(
        session: completed,
        earnings: earnings,
      );

      final scoped = ShiftSessionAggregator.earningsInSession(
        session: completed,
        earnings: earnings,
        vehicleId: completed.vehicleId,
      );
      final revenueByPlatform = <RidePlatform, double>{};
      for (final earning in scoped) {
        revenueByPlatform[earning.platform] =
            (revenueByPlatform[earning.platform] ?? 0) + earning.amount;
      }

      final blockOutcomes = ShiftRetrospectiveBuilder.computeBlockOutcomesForSession(
        session: completed,
        earnings: earnings,
        vehicleId: completed.vehicleId,
      );

      final userId = ref.read(authStateProvider).valueOrNull?.id ?? '';
      archived = await ref.read(shiftHistoryRepositoryProvider).archiveCompleted(
            session: completed,
            userId: userId,
            revenue: summary.revenue,
            rides: summary.rides,
            revenuePerHour: summary.revenuePerHour,
            adherenceScore: adherence.score,
            matchedPlanBlocks: adherence.matchedBlocks,
            totalPlanBlocks: adherence.totalBlocks,
            revenueByPlatform: revenueByPlatform,
            blockOutcomes: blockOutcomes,
          );

      await _repository.archiveCompleted(completed);
    });
    if (state.hasError) return null;
    ShiftSessionStorage.emitCurrent();
    return archived;
  }

  Future<bool> _transition(
    ShiftSessionEntity Function(ShiftSessionEntity session) transform,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final active = _repository.readActive();
      if (active == null) return;
      await _repository.saveActive(transform(active));
    });
    if (state.hasError) return false;
    ShiftSessionStorage.emitCurrent();
    return true;
  }
}

final shiftSessionControllerProvider =
    NotifierProvider<ShiftSessionController, AsyncValue<void>>(
  ShiftSessionController.new,
);

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
