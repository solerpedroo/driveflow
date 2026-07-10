import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../driveflow_gradient_background.dart';
import 'df_tab_scroll_view.dart';

/// Scaffold de subpágina empurrada — gradiente + voltar + scroll Mescla.
class DfSubpageScaffold extends StatelessWidget {
  const DfSubpageScaffold({
    required this.title,
    required this.children,
    super.key,
    this.onRefresh,
    this.actions,
    this.leading,
    this.bottomPadding = 32,
  });

  final String title;
  final List<Widget> children;
  final Future<void> Function()? onRefresh;
  final List<Widget>? actions;
  final Widget? leading;
  final double bottomPadding;

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            actions: actions,
          ),
          body: DfTabScrollView(
            onRefresh: onRefresh,
            bottomPadding: bottomPadding,
            children: children,
          ),
        ),
      ),
    );
  }
}
