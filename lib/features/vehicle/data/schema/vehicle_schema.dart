/// Colunas da tabela `vehicles` no Supabase.
abstract final class VehicleSchema {
  static const table = 'vehicles';

  static const id = 'id';
  static const userId = 'user_id';
  static const brand = 'brand';
  static const model = 'model';
  static const year = 'year';
  static const nickname = 'nickname';
  static const plate = 'plate';
  static const fuel = 'fuel';
  static const tank = 'tank';
  static const avgConsumption = 'avg_consumption';
  static const odometer = 'odometer';
  static const isDefault = 'is_default';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
