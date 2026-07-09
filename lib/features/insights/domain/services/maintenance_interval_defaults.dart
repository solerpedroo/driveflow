import '../../../../core/constants/app_constants.dart';

/// Intervalos sugeridos por tipo de manutenção (km e dias).
class MaintenanceIntervalDefault {
  const MaintenanceIntervalDefault({
    required this.kmInterval,
    required this.daysInterval,
  });

  final double kmInterval;
  final int daysInterval;
}

/// Tabela local de defaults para previsão preditiva.
abstract final class MaintenanceIntervalDefaults {
  static const defaults = <MaintenanceType, MaintenanceIntervalDefault>{
    MaintenanceType.oil: MaintenanceIntervalDefault(
      kmInterval: 10000,
      daysInterval: 180,
    ),
    MaintenanceType.tires: MaintenanceIntervalDefault(
      kmInterval: 40000,
      daysInterval: 730,
    ),
    MaintenanceType.revision: MaintenanceIntervalDefault(
      kmInterval: 15000,
      daysInterval: 365,
    ),
    MaintenanceType.filters: MaintenanceIntervalDefault(
      kmInterval: 15000,
      daysInterval: 365,
    ),
    MaintenanceType.alignment: MaintenanceIntervalDefault(
      kmInterval: 10000,
      daysInterval: 365,
    ),
    MaintenanceType.battery: MaintenanceIntervalDefault(
      kmInterval: 80000,
      daysInterval: 1095,
    ),
    MaintenanceType.brakes: MaintenanceIntervalDefault(
      kmInterval: 30000,
      daysInterval: 730,
    ),
  };

  static MaintenanceIntervalDefault forType(MaintenanceType type) {
    return defaults[type] ??
        const MaintenanceIntervalDefault(
          kmInterval: 10000,
          daysInterval: 365,
        );
  }
}
