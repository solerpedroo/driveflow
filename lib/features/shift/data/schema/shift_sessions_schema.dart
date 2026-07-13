abstract final class ShiftSessionsSchema {
  static const table = 'shift_sessions';

  static const id = 'id';
  static const userId = 'user_id';
  static const vehicleId = 'vehicle_id';
  static const startedAt = 'started_at';
  static const endedAt = 'ended_at';
  static const elapsedMs = 'elapsed_ms';
  static const accumulatedPauseMs = 'accumulated_pause_ms';
  static const isTaxiMode = 'is_taxi_mode';
  static const status = 'status';
  static const planBlocks = 'plan_blocks';
  static const revenue = 'revenue';
  static const rides = 'rides';
  static const revenuePerHour = 'revenue_per_hour';
  static const adherenceScore = 'adherence_score';
  static const matchedPlanBlocks = 'matched_plan_blocks';
  static const totalPlanBlocks = 'total_plan_blocks';
  static const revenueByPlatform = 'revenue_by_platform';
  static const blockOutcomes = 'block_outcomes';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
