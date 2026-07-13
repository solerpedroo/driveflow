import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../../shared/domain/models/period_summary.dart';
import '../utils/currency_formatter.dart';

/// Sincroniza o widget Android com o lucro do dia.
abstract final class HomeWidgetService {
  static const profitKey = 'today_profit';
  static const revenueKey = 'today_revenue';
  static const androidProviderName =
      'com.driveflow.driveflow.widget.DriveFlowHomeWidgetReceiver';

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await HomeWidget.setAppGroupId('group.com.driveflow.driveflow');
  }

  static Future<void> syncToday({
    required PeriodSummary today,
    bool hideValues = false,
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
    await HomeWidget.updateWidget(
      name: 'DriveFlowHomeWidget',
      androidName: androidProviderName,
    );
  }
}
