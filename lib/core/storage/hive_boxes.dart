/// Nomes das boxes Hive usadas pelo app.
abstract final class HiveBoxes {
  static const earnings = 'earnings';
  static const expenses = 'expenses';
  static const fuelLogs = 'fuel_logs';
  static const maintenance = 'maintenance';
  static const goals = 'goals';
  static const vehicles = 'vehicles';
  static const appState = 'app_state';
  static const shiftSessions = 'shift_sessions';
  static const shiftHistory = 'shift_history';
  static const pendingSyncQueue = 'pending_sync_queue';

  static const all = [
    earnings,
    expenses,
    fuelLogs,
    maintenance,
    goals,
    vehicles,
    appState,
    shiftSessions,
    shiftHistory,
    pendingSyncQueue,
  ];
}
