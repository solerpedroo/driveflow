import 'package:flutter/material.dart';

/// Perfil operacional do usuário — define UX e integrações disponíveis.
enum DriverType {
  rideShare('ride_share', 'Motorista de aplicativo', Icons.smartphone_rounded),
  taxi('taxi', 'Taxista', Icons.local_taxi_rounded);

  const DriverType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static DriverType fromValue(String? value) {
    if (value == null) {
      return DriverType.rideShare;
    }
    return DriverType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DriverType.rideShare,
    );
  }

  bool get isTaxi => this == DriverType.taxi;
  bool get isRideShare => this == DriverType.rideShare;

  String get shortLabel => switch (this) {
        DriverType.rideShare => 'App',
        DriverType.taxi => 'Táxi',
      };

  String get roleLabel => switch (this) {
        DriverType.rideShare => 'Motorista',
        DriverType.taxi => 'Taxista',
      };
}
