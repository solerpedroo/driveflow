import 'package:flutter/material.dart';

import '../../../core/theme/app_blur.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/df_haptics.dart';
import 'df_glass_surface.dart';

/// Item da bottom nav — ícone + label revelado apenas quando ativo.
class DfBottomNavItem {
  const DfBottomNavItem({
    required this.icon,
    required this.label,
    this.semanticKey,
  });

  final IconData icon;
  final String label;

  /// Chave estável para testes e deep-link de acessibilidade.
  final Key? semanticKey;
}

/// Bottom nav liquid glass — ícones sempre visíveis; label desliza ao lado ao tocar.
class DfBottomNavBar extends StatelessWidget {
  const DfBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    super.key,
    this.horizontalPadding = AppSpacing.screenHorizontal,
    this.bottomPadding = 12,
  });

  final List<DfBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final double horizontalPadding;
  final double bottomPadding;

  static const double _trackHeight = 60;
  static const double _glassRadius = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final inactive = AppColors.bottomNavInactive(theme);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, bottomPadding),
      child: DfGlassSurface(
        borderRadius: BorderRadius.circular(_glassRadius),
        sigma: AppBlur.nav,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_glassRadius - 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: brightness == Brightness.dark
                  ? [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.01),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.42),
                      Colors.white.withValues(alpha: 0.08),
                    ],
            ),
          ),
          child: SizedBox(
            height: _trackHeight - 16,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _DfBottomNavItemTile(
                      key: items[i].semanticKey ?? ValueKey('df_bottom_nav_$i'),
                      icon: items[i].icon,
                      label: items[i].label,
                      isActive: selectedIndex == i,
                      inactiveColor: inactive,
                      onTap: () {
                        DfHaptics.selection();
                        onItemTap(i);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DfBottomNavItemTile extends StatelessWidget {
  const _DfBottomNavItemTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.inactiveColor,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final contentColor = isActive
        ? AppColors.navActiveForeground(brightness)
        : inactiveColor;

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: DriveFlowMotion.fast,
            curve: DriveFlowMotion.standard,
            constraints: BoxConstraints(
              minWidth: isActive ? 72 : 44,
              minHeight: 44,
            ),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.navActiveFill(brightness),
                    borderRadius: BorderRadius.circular(22),
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 12 : 6,
                vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22, color: contentColor),
                  AnimatedSize(
                    duration: DriveFlowMotion.normal,
                    curve: DriveFlowMotion.spring,
                    alignment: Alignment.centerLeft,
                    child: isActive
                        ? _AnimatedNavLabel(
                            label: label,
                            color: contentColor,
                            brightness: brightness,
                          )
                        : const SizedBox(width: 0, height: 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavLabel extends StatefulWidget {
  const _AnimatedNavLabel({
    required this.label,
    required this.color,
    required this.brightness,
  });

  final String label;
  final Color color;
  final Brightness brightness;

  @override
  State<_AnimatedNavLabel> createState() => _AnimatedNavLabelState();
}

class _AnimatedNavLabelState extends State<_AnimatedNavLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DriveFlowMotion.normal,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: DriveFlowMotion.enter,
    );
    _slide = Tween<Offset>(
      begin: const Offset(-0.35, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DriveFlowMotion.spring,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Text(
            widget.label,
            style: AppTypography.iosCaption(widget.brightness).copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: widget.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
