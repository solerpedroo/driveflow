/// Colunas da tabela `profiles` no Supabase.
abstract final class ProfileSchema {
  static const table = 'profiles';

  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const photo = 'photo';
  static const driverType = 'driver_type';
  static const onboardingCompletedAt = 'onboarding_completed_at';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}
