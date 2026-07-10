import '../entities/platform_trip_entity.dart';

/// Duração trabalhada estimada a partir de corridas sincronizadas.
abstract final class PlatformTripDuration {
  static const fallbackHoursPerTrip = 0.5;

  /// Horas reais quando `durationMinutes` existe; senão fallback conservador.
  static double workedHours(PlatformTripEntity trip) {
    if (trip.durationMinutes != null && trip.durationMinutes! > 0) {
      return trip.durationMinutes! / 60.0;
    }
    return fallbackHoursPerTrip;
  }

  static double sumHours(Iterable<PlatformTripEntity> trips) {
    return trips.fold<double>(0, (sum, trip) => sum + workedHours(trip));
  }
}
