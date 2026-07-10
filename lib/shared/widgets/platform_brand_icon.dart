import 'package:flutter/material.dart';

import '../../core/constants/ride_platforms.dart';
import '../../core/theme/app_colors.dart';

/// Ícone de marca para Uber, 99 e InDrive (assets locais).
class PlatformBrandIcon extends StatelessWidget {
  const PlatformBrandIcon({
    required this.platform,
    this.size = 48,
    this.borderRadius = 12,
    super.key,
  });

  final RidePlatform platform;
  final double size;
  final double borderRadius;

  static const _assetPaths = {
    RidePlatform.uber: 'assets/brands/uber.png',
    RidePlatform.ninetyNine: 'assets/brands/99.png',
    RidePlatform.inDrive: 'assets/brands/indrive.png',
  };

  static bool hasBrandAsset(RidePlatform platform) =>
      _assetPaths.containsKey(platform);

  static String? assetPathFor(RidePlatform platform) => _assetPaths[platform];

  @override
  Widget build(BuildContext context) {
    final asset = assetPathFor(platform);
    if (asset == null) {
      return _FallbackIcon(size: size, borderRadius: borderRadius);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: platform.label,
        errorBuilder: (_, __, ___) =>
            _FallbackIcon(size: size, borderRadius: borderRadius),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({
    required this.size,
    required this.borderRadius,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.directions_car_filled_outlined,
        size: size * 0.48,
        color: AppColors.skyBlue,
      ),
    );
  }
}
