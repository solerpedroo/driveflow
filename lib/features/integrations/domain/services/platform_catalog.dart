import 'package:flutter/material.dart';

import '../../../../core/constants/ride_platforms.dart';
import '../entities/platform_catalog_entry.dart';

/// Catálogo das plataformas integráveis (Uber, 99, InDrive).
abstract final class PlatformCatalog {
  static const integratablePlatforms = [
    RidePlatform.uber,
    RidePlatform.ninetyNine,
    RidePlatform.inDrive,
  ];

  static const entries = <PlatformCatalogEntry>[
    PlatformCatalogEntry(
      platform: RidePlatform.uber,
      tagline: 'Traga corridas, ganhos e repasses automaticamente',
      brandColor: Color(0xFF000000),
      icon: Icons.local_taxi_rounded,
      oauthProvider: 'uber_driver',
      capabilities: [
        PlatformCapability.dailyEarnings,
        PlatformCapability.tripCount,
        PlatformCapability.tripDetails,
        PlatformCapability.payouts,
        PlatformCapability.workedHours,
        PlatformCapability.surgeZones,
        PlatformCapability.ratings,
      ],
    ),
    PlatformCatalogEntry(
      platform: RidePlatform.ninetyNine,
      tagline: 'Importe corridas e repasses sem digitar nada',
      brandColor: Color(0xFFFFD500),
      icon: Icons.emoji_transportation_rounded,
      oauthProvider: '99_driver',
      capabilities: [
        PlatformCapability.dailyEarnings,
        PlatformCapability.tripCount,
        PlatformCapability.payouts,
        PlatformCapability.workedHours,
        PlatformCapability.ratings,
      ],
    ),
    PlatformCatalogEntry(
      platform: RidePlatform.inDrive,
      tagline: 'Ofertas e ganhos negociados em um só lugar',
      brandColor: Color(0xFF00B140),
      icon: Icons.directions_car_filled_rounded,
      oauthProvider: 'indrive_driver',
      capabilities: [
        PlatformCapability.dailyEarnings,
        PlatformCapability.tripCount,
        PlatformCapability.tripDetails,
        PlatformCapability.workedHours,
      ],
    ),
  ];

  static PlatformCatalogEntry entryFor(RidePlatform platform) {
    return entries.firstWhere((e) => e.platform == platform);
  }
}
