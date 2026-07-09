import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/driveflow_tab_count.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/df_haptics.dart';
import 'driveflow_bottom_nav_bar.dart' show DriveFlowBottomNavBar, kDriveFlowTabSwitchDuration;
import 'driveflow_connectivity_banner.dart';
import 'driveflow_gradient_background.dart';

/// Shell pós-login — mesh animado + nav glass (tier outlier).
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

  void _onTab(int index) {
    if (index != selectedIndex) DfHaptics.selection();
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
                      final active = index == selectedIndex;
                      return Positioned.fill(
                        child: ExcludeSemantics(
                          excluding: !active,
                          child: IgnorePointer(
                            ignoring: !active,
                            child: ClipRect(
                              child: AnimatedSlide(
                                duration: kDriveFlowTabSwitchDuration,
                                curve: DriveFlowMotion.spring,
                                offset: active
                                    ? Offset.zero
                                    : const Offset(0, 0.025),
                                child: AnimatedOpacity(
                                  duration: kDriveFlowTabSwitchDuration,
                                  curve: DriveFlowMotion.snap,
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
