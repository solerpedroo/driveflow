import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_elevation.dart';
import '../../core/theme/app_gradients.dart';

/// Logotipo DriveFlow — Geist + mark com profundidade sutil.
class DriveFlowBrandLogo extends StatelessWidget {
  const DriveFlowBrandLogo({
    super.key,
    this.size = LogoSize.large,
    this.showTagline = true,
  });

  final LogoSize size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final titleSize = switch (size) {
      LogoSize.small => 22.0,
      LogoSize.medium => 26.0,
      LogoSize.large => 34.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: titleSize * 0.55,
              height: titleSize * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppGradients.brand,
                boxShadow: AppElevation.brandGlow(brightness),
              ),
              child: Icon(
                Icons.speed_rounded,
                color: Colors.white,
                size: titleSize * 0.32,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: GoogleFonts.geist(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                  color: theme.colorScheme.onSurface,
                ),
                children: const [
                  TextSpan(text: 'Drive'),
                  TextSpan(
                    text: 'Flow',
                    style: TextStyle(color: AppColors.brandBlue),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            kAppTagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryLabel(theme),
            ),
          ),
        ],
      ],
    );
  }
}

enum LogoSize { small, medium, large }
