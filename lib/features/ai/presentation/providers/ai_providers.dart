import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/vehicle_scope_filter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../insights/domain/services/earnings_heatmap_builder.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../integrations/presentation/providers/platform_trips_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/entities/ai_forecast_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/services/ai_context_builder.dart';
import '../../domain/usecases/ai_usecases.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

final aiHistoryStreamProvider =
    StreamProvider.autoDispose<List<AiMessageEntity>>((ref) {
  final watch = WatchAiHistory(ref.watch(aiRepositoryProvider));
  return watch();
});

final aiContextPreviewProvider = Provider<AiContextSnapshot>((ref) {
  final vehicleId = ref.watch(scopedVehicleIdProvider);
  final earnings = _scoped(
    items: ref.watch(earningsStreamProvider).valueOrNull ?? const <EarningEntity>[],
    vehicleId: vehicleId,
    vehicleIdOf: (EarningEntity e) => e.vehicleId,
  );
  final expenses = _scoped(
    items: ref.watch(expensesStreamProvider).valueOrNull ?? const <ExpenseEntity>[],
    vehicleId: vehicleId,
    vehicleIdOf: (ExpenseEntity e) => e.vehicleId,
  );
  final fuelLogs = ref.watch(activeVehicleFuelLogsProvider).valueOrNull ?? const [];
  final maintenance =
      ref.watch(activeVehicleMaintenanceProvider).valueOrNull ?? const [];
  final goals = ref.watch(goalsStreamProvider).valueOrNull;
  final odometer = ref.watch(activeVehicleProvider).valueOrNull?.odometerKm;
  final topSlots = EarningsHeatmapBuilder.topSlots(earnings: earnings);
  final trips = ref.watch(platformScopedTripsProvider);

  return AiContextBuilder.build(
    earnings: earnings,
    expenses: expenses,
    fuelLogs: fuelLogs,
    maintenanceRecords: maintenance,
    goals: goals,
    currentOdometerKm: odometer,
    topEarningSlots: topSlots,
    platformTrips: trips,
  );
});

List<T> _scoped<T>({
  required List<T> items,
  required String? vehicleId,
  required String? Function(T item) vehicleIdOf,
}) {
  return VehicleScopeFilter.byVehicle(
    items: items,
    vehicleId: vehicleId,
    vehicleIdOf: vehicleIdOf,
  );
}

final askAiProvider = Provider<AskAiAssistant>((ref) {
  return AskAiAssistant(ref.watch(aiRepositoryProvider));
});

class AiForecastController extends Notifier<AsyncValue<AiForecastMessage?>> {
  @override
  AsyncValue<AiForecastMessage?> build() => const AsyncData(null);

  Future<AiForecastMessage?> generate() async {
    state = const AsyncLoading();
    AiForecastMessage? message;
    state = await AsyncValue.guard(() async {
      message = await ref.read(aiRepositoryProvider).forecast();
    });
    if (state.hasError) return null;
    return message;
  }
}

final aiForecastControllerProvider =
    NotifierProvider<AiForecastController, AsyncValue<AiForecastMessage?>>(
  AiForecastController.new,
);

class AiChatController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<AiMessageEntity?> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return null;

    state = const AsyncLoading();
    AiMessageEntity? message;
    state = await AsyncValue.guard(() async {
      message = await ref.read(askAiProvider)(trimmed);
      DriveFlowAnalytics.logEvent('ai_question');
    });
    if (state.hasError) return null;
    return message;
  }

  void clearError() => state = const AsyncData(null);
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AsyncValue<void>>(AiChatController.new);
