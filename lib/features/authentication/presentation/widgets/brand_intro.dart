import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/driveflow_mark.dart';

/// Intro de marca — handoff contínuo do splash nativo (#0064F5 + DF).
class BrandIntro extends HookWidget {
  const BrandIntro({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  static const Duration minHold = Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    final markController = useAnimationController(
      duration: DriveFlowMotion.slow,
    );
    final wordController = useAnimationController(
      duration: DriveFlowMotion.normal,
    );

    final markScale = useMemoized(
      () => Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: markController, curve: DriveFlowMotion.enter),
      ),
      [markController],
    );
    final markOpacity = useMemoized(
      () => CurvedAnimation(parent: markController, curve: DriveFlowMotion.enter),
      [markController],
    );
    final wordOpacity = useMemoized(
      () => CurvedAnimation(parent: wordController, curve: DriveFlowMotion.enter),
      [wordController],
    );
    final wordSlide = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: wordController, curve: DriveFlowMotion.enter),
      ),
      [wordController],
    );

    useEffect(() {
      var cancelled = false;
      Future<void> run() async {
        await markController.forward();
        if (cancelled) return;
        await wordController.forward();
        if (cancelled) return;
        final elapsed = markController.duration! + wordController.duration!;
        final remaining = minHold - elapsed;
        if (remaining > Duration.zero) {
          await Future<void>.delayed(remaining);
        }
        if (!cancelled) onComplete();
      }

      run();
      return () => cancelled = true;
    }, const []);

    return ColoredBox(
      color: kBrandSplashColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: markOpacity,
              child: ScaleTransition(
                scale: markScale,
                child: const DriveFlowMarkGlyph(size: 96),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: wordOpacity,
              child: SlideTransition(
                position: wordSlide,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.geist(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: Colors.white,
                    ),
                    children: const [
                      TextSpan(text: 'Drive'),
                      TextSpan(
                        text: 'Flow',
                        style: TextStyle(
                          color: Color(0xFFB8D4FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
