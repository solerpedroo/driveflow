import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../fuel/presentation/providers/fuel_providers.dart';
import '../../../goals/presentation/providers/goals_providers.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../vehicle/presentation/providers/vehicle_providers.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/services/ai_context_builder.dart';
import '../../domain/usecases/ai_usecases.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl();
});

final aiHistoryStreamProvider = StreamProvider<List<AiMessageEntity>>((ref) {
  final watch = WatchAiHistory(ref.watch(aiRepositoryProvider));
  return watch();
});

final aiContextPreviewProvider = Provider<AiContextSnapshot>((ref) {
  final earnings = ref.watch(earningsStreamProvider).valueOrNull ?? const [];
  final expenses = ref.watch(expensesStreamProvider).valueOrNull ?? const [];
  final fuelLogs = ref.watch(activeVehicleFuelLogsProvider).valueOrNull ?? const [];
  final maintenance =
      ref.watch(activeVehicleMaintenanceProvider).valueOrNull ?? const [];
  final goals = ref.watch(goalsStreamProvider).valueOrNull;
  final odometer = ref.watch(activeVehicleProvider).valueOrNull?.odometerKm;

  return AiContextBuilder.build(
    earnings: earnings,
    expenses: expenses,
    fuelLogs: fuelLogs,
    maintenanceRecords: maintenance,
    goals: goals,
    currentOdometerKm: odometer,
  );
});

final askAiProvider = Provider<AskAiAssistant>((ref) {
  return AskAiAssistant(ref.watch(aiRepositoryProvider));
});

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
    });
    if (state.hasError) return null;
    return message;
  }

  void clearError() => state = const AsyncData(null);
}

final aiChatControllerProvider =
    NotifierProvider<AiChatController, AsyncValue<void>>(AiChatController.new);
