import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../../features/shift/domain/entities/shift_session_summary.dart';
import '../../shared/domain/models/period_summary.dart';
import '../utils/currency_formatter.dart';

/// Sincroniza widgets nativos (Android Glance + iOS WidgetKit) com lucro do dia e turno ativo.
abstract final class HomeWidgetService {
  static const appGroupId = 'group.com.driveflow.driveflow';
  static const widgetKind = 'DriveFlowHomeWidget';
  static const profitKey = 'today_profit';
  static const revenueKey = 'today_revenue';
  static const shiftActiveKey = 'shift_active';
  static const shiftRevenueKey = 'shift_revenue';
  static const shiftElapsedKey = 'shift_elapsed';
  static const androidProviderName =
      'com.driveflow.driveflow.widget.DriveFlowHomeWidgetReceiver';

  static Future<void> initialize() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> syncToday({
    required PeriodSummary today,
    bool hideValues = false,
    ShiftSessionSummary? shiftSummary,
    bool shiftActive = false,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

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

    if (Platform.isAndroid) {
      await HomeWidget.updateWidget(
        name: widgetKind,
        androidName: androidProviderName,
      );
    } else if (Platform.isIOS) {
      await HomeWidget.updateWidget(
        name: widgetKind,
        iOSName: widgetKind,
      );
    }
  }
}
