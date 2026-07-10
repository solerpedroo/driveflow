import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';

/// Metadados de uma plataforma integrável (Uber, 99, InDrive).
class PlatformCatalogEntry {
  const PlatformCatalogEntry({
    required this.platform,
    required this.tagline,
    required this.brandColor,
    required this.icon,
    required this.capabilities,
    required this.oauthProvider,
    this.comingSoon = false,
  });

  final RidePlatform platform;
  final String tagline;
  final Color brandColor;
  final IconData icon;
  final List<PlatformCapability> capabilities;
  final String oauthProvider;
  final bool comingSoon;
}

/// Dados que a API da plataforma pode fornecer ao DriveFlow.
enum PlatformCapability {
  dailyEarnings('Ganhos diários'),
  tripCount('Contagem de corridas'),
  tripDetails('Detalhes por corrida'),
  payouts('Repasses e taxas'),
  workedHours('Horas online'),
  surgeZones('Zonas de pico'),
  ratings('Avaliações');

  const PlatformCapability(this.label);

  final String label;
}
