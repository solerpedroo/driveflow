import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../driveflow_gradient_background.dart';
import 'df_tab_scroll_view.dart';

/// Scaffold de subpágina empurrada — gradiente + voltar + scroll Mescla.
/// Privacidade monetária fica no [DfHeroWealthCard], não no AppBar.
class DfSubpageScaffold extends StatelessWidget {
  const DfSubpageScaffold({
    required this.title,
    super.key,
    this.children,
    this.body,
    this.onRefresh,
    this.actions,
    this.leading,
    this.bottomPadding = 32,
    @Deprecated('Use onToggleVisibility no DfHeroWealthCard')
    this.valueHidden,
    @Deprecated('Use onToggleVisibility no DfHeroWealthCard')
    this.onToggleValueVisibility,
  }) : assert(
          (children != null) ^ (body != null),
          'Informe children (scroll) ou body (layout customizado), não ambos.',
        );

  final String title;
  final List<Widget>? children;
  final Widget? body;
  final Future<void> Function()? onRefresh;
  final List<Widget>? actions;
  final Widget? leading;
  final double bottomPadding;

  @Deprecated('Use onToggleVisibility no DfHeroWealthCard')
  final bool? valueHidden;
  @Deprecated('Use onToggleVisibility no DfHeroWealthCard')
  final VoidCallback? onToggleValueVisibility;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: brightness == Brightness.dark
          ? AppColors.darkOverlay
          : AppColors.lightOverlay,
      child: DriveFlowGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.maybePop(context),
                ),
            title: Text(
              title,
              style: AppTypography.iosHeadline(brightness).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            actions: actions,
          ),
          body: body ??
              DfTabScrollView(
                onRefresh: onRefresh,
                bottomPadding: bottomPadding,
                children: children!,
              ),
        ),
      ),
    );
  }
}
