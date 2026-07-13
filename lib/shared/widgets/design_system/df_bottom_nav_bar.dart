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

  static const double _trackHeight = 78;
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
            height: _trackHeight,
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
    final labelStateKey = ValueKey(
      'nav-label-${label.toLowerCase()}-${isActive ? 'active' : 'inactive'}',
    );

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
              minWidth: isActive ? 84 : 50,
              minHeight: isActive ? 68 : 50,
            ),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.navActiveFill(brightness),
                    borderRadius: BorderRadius.circular(22),
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 10 : 6,
                vertical: 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 22, color: contentColor),
                  AnimatedSwitcher(
                    duration: DriveFlowMotion.normal,
                    reverseDuration: DriveFlowMotion.fast,
                    switchInCurve: DriveFlowMotion.enter,
                    switchOutCurve: DriveFlowMotion.snap,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.14),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: isActive
                        ? SizedBox(
                            key: labelStateKey,
                            child: _AnimatedNavLabel(
                              label: label,
                              color: contentColor,
                              brightness: brightness,
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('nav-label-empty'),
                          ),
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
      begin: const Offset(0, 0.2),
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
      key: const ValueKey('driveflow_nav_label_container'),
      padding: const EdgeInsets.only(top: 4),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 76),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: AppTypography.iosCaption(widget.brightness).copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
