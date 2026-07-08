import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/driveflow_tab_count.dart';
import '../../core/theme/app_colors.dart';
import 'driveflow_bottom_nav_bar.dart' show DriveFlowBottomNavBar, kDriveFlowTabSwitchDuration;

/// Shell pós-login com bottom nav e abas vivas (Stack animado).
class DriveFlowMainShell extends StatelessWidget {
  const DriveFlowMainShell({
    required this.selectedIndex,
    required this.onNavIndexChanged,
    required this.tabBodies,
    super.key,
  }) : assert(tabBodies.length == kDriveFlowMainTabCount);

  final int selectedIndex;
  final ValueChanged<int> onNavIndexChanged;
  final List<Widget> tabBodies;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final gradient = AppColors.ambientGradient(brightness);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: brightness == Brightness.dark
          ? AppColors.darkOverlay
          : AppColors.lightOverlay,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: List.generate(tabBodies.length, (index) {
                      final active = index == selectedIndex;
                      return Positioned.fill(
                        child: ExcludeSemantics(
                          excluding: !active,
                          child: IgnorePointer(
                            ignoring: !active,
                            child: ClipRect(
                              child: AnimatedSlide(
                                duration: kDriveFlowTabSwitchDuration,
                                curve: Curves.easeOutCubic,
                                offset: active
                                    ? Offset.zero
                                    : const Offset(0, 0.03),
                                child: AnimatedOpacity(
                                  duration: kDriveFlowTabSwitchDuration,
                                  curve: Curves.easeOutCubic,
                                  opacity: active ? 1 : 0,
                                  child: tabBodies[index],
                                ),
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
                  onItemTap: onNavIndexChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
