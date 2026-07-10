import '../entities/platform_trip_entity.dart';

/// Normalização de rótulos de região para agrupamento.
abstract final class PlatformRegionLabel {
  static const unknownLabel = 'Área não identificada';
  static const shortTripLabel = 'Corridas curtas (<5 km)';
  static const longTripLabel = 'Corridas longas (≥5 km)';

  /// Pickup → dropoff → bucket por distância.
  static String fromTrip(PlatformTripEntity trip) {
    final pickup = normalize(trip.pickupLabel);
    if (pickup.isNotEmpty) return pickup;

    final dropoff = normalize(trip.dropoffLabel);
    if (dropoff.isNotEmpty) return dropoff;

    final km = trip.distanceKm;
    if (km != null && km > 0) {
      return km < 5 ? shortTripLabel : longTripLabel;
    }

    return unknownLabel;
  }

  static String normalize(String? label) {
    if (label == null || label.trim().isEmpty) return '';

    var trimmed = label.trim();

    // Remove prefixos comuns de endereço.
    final prefixes = [
      'rua ',
      'r. ',
      'r ',
      'av. ',
      'av ',
      'avenida ',
      'al. ',
      'travessa ',
      'praça ',
    ];
    final lower = trimmed.toLowerCase();
    for (final prefix in prefixes) {
      if (lower.startsWith(prefix)) {
        trimmed = trimmed.substring(prefix.length).trim();
        break;
      }
    }

    // Bairro antes da vírgula (ex: "Centro, São Paulo").
    final comma = trimmed.indexOf(',');
    if (comma > 0) return trimmed.substring(0, comma).trim();

    // Primeiras duas palavras significativas.
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.length > 1);
    final words = parts.take(2).toList();
    if (words.isEmpty) return '';
    return words.join(' ');
  }

  static bool isEstimated(String label) =>
      label == unknownLabel ||
      label == shortTripLabel ||
      label == longTripLabel;
}
