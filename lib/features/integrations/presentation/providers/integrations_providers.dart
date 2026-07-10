import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../data/repositories/platform_integration_repository_impl.dart';
import '../../domain/entities/integration_status.dart';
import '../../domain/entities/platform_connection_entity.dart';
import '../../domain/entities/platform_performance_snapshot.dart';
import '../../domain/entities/platform_shift_recommendation.dart';
import '../../domain/entities/platform_oauth_session.dart';
import '../../domain/repositories/platform_integration_repository.dart';
import '../../domain/services/platform_performance_analyzer.dart';
import '../../domain/services/platform_shift_advisor.dart';

final platformIntegrationRepositoryProvider =
    Provider<PlatformIntegrationRepository>((ref) {
  return PlatformIntegrationRepositoryImpl();
});

final platformConnectionsStreamProvider =
    StreamProvider<List<PlatformConnectionEntity>>((ref) {
  return ref.watch(platformIntegrationRepositoryProvider).watchConnections();
});

final platformConnectionsProvider =
    Provider<AsyncValue<List<PlatformConnectionEntity>>>((ref) {
  return ref.watch(platformConnectionsStreamProvider);
});

final platformConnectionForProvider =
    Provider.family<PlatformConnectionEntity?, RidePlatform>((ref, platform) {
  final connections = ref.watch(platformConnectionsProvider).valueOrNull;
  if (connections == null) return null;

  for (final connection in connections) {
    if (connection.platform == platform) return connection;
  }
  return null;
});

final connectedPlatformsProvider = Provider<Set<RidePlatform>>((ref) {
  final connections = ref.watch(platformConnectionsProvider).valueOrNull ?? [];
  return connections
      .where((c) => c.status.canSync)
      .map((c) => c.platform)
      .toSet();
});

final platformPerformanceProvider =
    Provider<AsyncValue<List<PlatformPerformanceSnapshot>>>((ref) {
  final earnings = ref.watch(earningsStreamProvider);
  return earnings.whenData(PlatformPerformanceAnalyzer.analyze);
});

final platformShiftRecommendationProvider =
    Provider<AsyncValue<PlatformShiftRecommendation?>>((ref) {
  final earnings = ref.watch(earningsStreamProvider);
  return earnings.whenData(
    (items) => PlatformShiftAdvisor.recommend(earnings: items),
  );
});

final missingSyncPlatformsProvider = Provider<List<RidePlatform>>((ref) {
  final earnings = ref.watch(earningsStreamProvider).valueOrNull ?? [];
  final connected = ref.watch(connectedPlatformsProvider);
  return PlatformShiftAdvisor.missingSyncPlatforms(
    earnings: earnings,
    connected: connected,
  );
});

class PlatformIntegrationController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  PlatformIntegrationRepository get _repo =>
      ref.read(platformIntegrationRepositoryProvider);

  Future<PlatformOAuthSession?> startOAuth(RidePlatform platform) async {
    state = const AsyncLoading();
    PlatformOAuthSession? result;
    state = await AsyncValue.guard(() async {
      result = await _repo.startOAuth(platform);
    });
    return state.hasError ? null : result;
  }

  Future<PlatformConnectionEntity?> connect(RidePlatform platform) async {
    state = const AsyncLoading();
    PlatformConnectionEntity? result;
    state = await AsyncValue.guard(() async {
      result = await _repo.connectPlatform(platform);
    });
    return state.hasError ? null : result;
  }

  Future<PlatformConnectionEntity?> disconnect(RidePlatform platform) async {
    state = const AsyncLoading();
    PlatformConnectionEntity? result;
    state = await AsyncValue.guard(() async {
      result = await _repo.disconnectPlatform(platform);
    });
    return state.hasError ? null : result;
  }

  Future<PlatformSyncResult?> sync(RidePlatform platform) async {
    state = const AsyncLoading();
    PlatformSyncResult? result;
    state = await AsyncValue.guard(() async {
      result = await _repo.syncPlatform(platform);
    });
    return state.hasError ? null : result;
  }

  Future<PlatformSyncResult?> syncAll() async {
    state = const AsyncLoading();
    PlatformSyncResult? result;
    state = await AsyncValue.guard(() async {
      result = await _repo.syncAllConnected();
    });
    return state.hasError ? null : result;
  }
}

final platformIntegrationControllerProvider =
    NotifierProvider<PlatformIntegrationController, AsyncValue<void>>(
  PlatformIntegrationController.new,
);

/// Resolve status efetivo: conexão salva ou desconectado por padrão.
IntegrationStatus effectiveStatus(
  RidePlatform platform,
  List<PlatformConnectionEntity>? connections,
) {
  if (connections == null) return IntegrationStatus.disconnected;
  for (final connection in connections) {
    if (connection.platform == platform) return connection.status;
  }
  return IntegrationStatus.disconnected;
}
