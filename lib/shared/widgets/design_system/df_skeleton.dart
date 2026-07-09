import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'df_card.dart';

/// Skeleton de lista do Design System v2 com shimmer animado.
class DfSkeleton extends StatefulWidget {
  const DfSkeleton({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  State<DfSkeleton> createState() => _DfSkeletonState();
}

class _DfSkeletonState extends State<DfSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl * 2,
      ),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return DfCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBar(animation: _shimmer, width: 120),
                    const SizedBox(height: AppSpacing.sm),
                    _ShimmerBar(animation: _shimmer, width: 180, height: 12),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _ShimmerBar(animation: _shimmer, width: 72),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.animation,
    required this.width,
    this.height = 16,
  });

  final Animation<double> animation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final base =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);
    final highlight =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.14);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + animation.value * 2, 0),
              end: Alignment(animation.value * 2, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
