import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../../features/shift/domain/entities/shift_session_summary.dart';
import '../../shared/domain/models/period_summary.dart';
import '../utils/currency_formatter.dart';

/// Sincroniza o widget Android com o lucro do dia e turno ativo.
abstract final class HomeWidgetService {
  static const profitKey = 'today_profit';
  static const revenueKey = 'today_revenue';
  static const shiftActiveKey = 'shift_active';
  static const shiftRevenueKey = 'shift_revenue';
  static const shiftElapsedKey = 'shift_elapsed';
  static const androidProviderName =
      'com.driveflow.driveflow.widget.DriveFlowHomeWidgetReceiver';

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await HomeWidget.setAppGroupId('group.com.driveflow.driveflow');
  }

  static Future<void> syncToday({
    required PeriodSummary today,
    bool hideValues = false,
    ShiftSessionSummary? shiftSummary,
    bool shiftActive = false,
  }) async {
    if (!Platform.isAndroid) return;

    await HomeWidget.saveWidgetData<String>(
      profitKey,
      hideValues ? '•••' : CurrencyFormatter.format(today.profit),
    );
    await HomeWidget.saveWidgetData<String>(
      revenueKey,
      hideValues ? '•••' : CurrencyFormatter.format(today.revenue),
    );
    await HomeWidget.saveWidgetData<bool>(shiftActiveKey, shiftActive);
    if (shiftSummary != null && shiftActive) {
      await HomeWidget.saveWidgetData<String>(
        shiftRevenueKey,
        hideValues ? '•••' : CurrencyFormatter.format(shiftSummary.revenue),
      );
      final hours = shiftSummary.elapsed.inHours;
      final minutes = shiftSummary.elapsed.inMinutes.remainder(60);
      await HomeWidget.saveWidgetData<String>(
        shiftElapsedKey,
        '${hours}h ${minutes.toString().padLeft(2, '0')}m',
      );
    } else {
      await HomeWidget.saveWidgetData<String>(shiftRevenueKey, '');
      await HomeWidget.saveWidgetData<String>(shiftElapsedKey, '');
    }
    await HomeWidget.updateWidget(
      name: 'DriveFlowHomeWidget',
      androidName: androidProviderName,
    );
  }
}
