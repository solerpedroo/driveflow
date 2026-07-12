import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_elevation.dart';

/// Paths dos assets de marca DriveFlow.
abstract final class DriveFlowBrandAssets {
  static const markTile = 'assets/branding/mark_df.png';
  static const glyph = 'assets/branding/splash_logo.png';
  static const iconMaster = 'assets/branding/icon_master_1024.png';
}

/// Mark oficial (logo GPT) — tile arredondado ou glifo branco.
class DriveFlowMark extends StatelessWidget {
  const DriveFlowMark({
    super.key,
    this.size = 28,
    this.showTile = true,
    this.showGlow = false,
  });

  final double size;
  final bool showTile;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    if (showTile) {
      final brightness = Theme.of(context).brightness;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          boxShadow: showGlow ? AppElevation.brandGlow(brightness) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          DriveFlowBrandAssets.markTile,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      );
    }

    return Image.asset(
      DriveFlowBrandAssets.glyph,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}

/// Glifo branco (splash / intro), sem tile.
class DriveFlowMarkGlyph extends StatelessWidget {
  const DriveFlowMarkGlyph({
    super.key,
    this.size = 88,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      DriveFlowBrandAssets.glyph,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}

/// Cor de fundo do splash nativo / brand intro.
const kBrandSplashColor = AppColors.brandBlue;
