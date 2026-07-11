import 'package:flutter/material.dart';

import 'driver_type.dart';

/// Plataformas e canais de ganho — apps de corrida e táxi manual.
enum RidePlatform {
  uber('uber', 'Uber'),
  ninetyNine('99', '99'),
  inDrive('indrive', 'InDrive'),
  taximeter('taximeter', 'Taxímetro'),
  streetHail('street', 'Bandeira / rua'),
  hotelContract('hotel', 'Hotel / contrato'),
  airport('airport', 'Aeroporto'),
  privateRide('private', 'Particular'),
  other('other', 'Outro');

  const RidePlatform(this.value, this.label);

  final String value;
  final String label;

  static RidePlatform fromValue(String value) {
    return RidePlatform.values.firstWhere(
      (p) => p.value == value,
      orElse: () => RidePlatform.other,
    );
  }

  bool get isRideShareApp =>
      this == RidePlatform.uber ||
      this == RidePlatform.ninetyNine ||
      this == RidePlatform.inDrive;

  bool get isTaxiChannel => !isRideShareApp && this != RidePlatform.privateRide;

  IconData? get icon => switch (this) {
        RidePlatform.taximeter => Icons.speed_rounded,
        RidePlatform.streetHail => Icons.location_on_outlined,
        RidePlatform.hotelContract => Icons.hotel_rounded,
        RidePlatform.airport => Icons.flight_land_rounded,
        RidePlatform.privateRide => Icons.person_outline_rounded,
        RidePlatform.other => Icons.more_horiz_rounded,
        _ => null,
      };
}

const kRideSharePlatforms = [
  RidePlatform.uber,
  RidePlatform.ninetyNine,
  RidePlatform.inDrive,
  RidePlatform.privateRide,
  RidePlatform.other,
];

const kTaxiPlatforms = [
  RidePlatform.taximeter,
  RidePlatform.streetHail,
  RidePlatform.hotelContract,
  RidePlatform.airport,
  RidePlatform.privateRide,
  RidePlatform.other,
];

/// Mantido por compatibilidade — lista completa legada.
const kRidePlatforms = RidePlatform.values;

List<RidePlatform> ridePlatformsFor(DriverType driverType) {
  return driverType.isTaxi ? kTaxiPlatforms : kRideSharePlatforms;
}
