import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/driveflow_tab_count.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import 'driveflow_bottom_nav_bar.dart' show DriveFlowBottomNavBar, kDriveFlowTabSwitchDuration;
import 'driveflow_connectivity_banner.dart';
import 'driveflow_gradient_background.dart';

/// Shell pós-login — fundo grouped iOS + tab bar Cupertino + lazy tabs.
class DriveFlowMainShell extends StatelessWidget {
  const DriveFlowMainShell({
    required this.selectedIndex,
    required this.onNavIndexChanged,
    required this.tabBodies,
    required this.activatedTabIndices,
    super.key,
  }) : assert(tabBodies.length == kDriveFlowMainTabCount);

  final int selectedIndex;
  final ValueChanged<int> onNavIndexChanged;
  final List<Widget> tabBodies;
  final Set<int> activatedTabIndices;

  void _onTab(int index) {
    onNavIndexChanged(index);
  }

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
          body: SafeArea(
            child: Column(
              children: [
                const DriveFlowConnectivityBanner(),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: List.generate(tabBodies.length, (index) {
                      if (!activatedTabIndices.contains(index)) {
                        return const SizedBox.shrink();
                      }
                      final active = index == selectedIndex;
                      return Positioned.fill(
                        child: ExcludeSemantics(
                          excluding: !active,
                          child: IgnorePointer(
                            ignoring: !active,
                            child: ClipRect(
                              child: _AnimatedTabLayer(
                                active: active,
                                child: tabBodies[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                DriveFlowBottomNavBar(
                  selectedIndex: selectedIndex,
                  onItemTap: _onTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Anima entrada/saída de aba — inclusive na primeira visita (lazy mount).
class _AnimatedTabLayer extends StatefulWidget {
  const _AnimatedTabLayer({
    required this.active,
    required this.child,
  });

  final bool active;
  final Widget child;

  @override
  State<_AnimatedTabLayer> createState() => _AnimatedTabLayerState();
}

class _AnimatedTabLayerState extends State<_AnimatedTabLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kDriveFlowTabSwitchDuration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: DriveFlowMotion.snap,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: DriveFlowMotion.spring,
      ),
    );

    if (widget.active) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedTabLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
