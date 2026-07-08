/// Nomes das boxes Hive usadas pelo app.
abstract final class HiveBoxes {
  static const earnings = 'earnings';
  static const expenses = 'expenses';
  static const fuelLogs = 'fuel_logs';
  static const maintenance = 'maintenance';
  static const goals = 'goals';
  static const pendingSyncQueue = 'pending_sync_queue';

  static const all = [
    earnings,
    expenses,
    fuelLogs,
    maintenance,
    goals,
    pendingSyncQueue,
  ];
}
