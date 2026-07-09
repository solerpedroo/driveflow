import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';

/// Entrada escalonada fade + slide para listas de widgets (formulários auth).
class DfStaggeredEntrance extends StatefulWidget {
  const DfStaggeredEntrance({
    required this.children,
    super.key,
    this.delayBetween = const Duration(milliseconds: 60),
    this.initialDelay = const Duration(milliseconds: 120),
  });

  final List<Widget> children;
  final Duration delayBetween;
  final Duration initialDelay;

  @override
  State<DfStaggeredEntrance> createState() => _DfStaggeredEntranceState();
}

class _DfStaggeredEntranceState extends State<DfStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalMs = widget.initialDelay.inMilliseconds +
        widget.children.length * widget.delayBetween.inMilliseconds +
        DriveFlowMotion.normal.inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final start = (widget.initialDelay.inMilliseconds +
                      i * widget.delayBetween.inMilliseconds) /
                  _controller.duration!.inMilliseconds;
              final end = (start +
                      DriveFlowMotion.normal.inMilliseconds /
                          _controller.duration!.inMilliseconds)
                  .clamp(0.0, 1.0);
              final curved = CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: DriveFlowMotion.enter),
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
      ],
    );
  }
}
