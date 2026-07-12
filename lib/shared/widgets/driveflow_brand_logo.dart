import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'driveflow_mark.dart';

/// Logotipo DriveFlow — Geist + monograma DF.
class DriveFlowBrandLogo extends StatelessWidget {
  const DriveFlowBrandLogo({
    super.key,
    this.size = LogoSize.large,
    this.showTagline = true,
    this.lightOnDark = false,
  });

  final LogoSize size;
  final bool showTagline;

  /// Wordmark branco + Flow em glow — para fundos brand/navy.
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleSize = switch (size) {
      LogoSize.small => 22.0,
      LogoSize.medium => 26.0,
      LogoSize.large => 34.0,
    };
    final markSize = titleSize * 0.72;
    final driveColor = lightOnDark ? Colors.white : theme.colorScheme.onSurface;
    final flowColor = lightOnDark ? AppColors.brandGlow : AppColors.brandBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DriveFlowMark(size: markSize, showGlow: size == LogoSize.large),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: GoogleFonts.geist(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.9,
                  color: driveColor,
                ),
                children: [
                  const TextSpan(text: 'Drive'),
                  TextSpan(
                    text: 'Flow',
                    style: TextStyle(color: flowColor),
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
              color: lightOnDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : AppColors.secondaryLabel(theme),
            ),
          ),
        ],
      ],
    );
  }
}

enum LogoSize { small, medium, large }
