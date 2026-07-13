import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/shift_session_entity.dart';
import '../../domain/entities/shift_session_status.dart';

/// Cronômetro do turno (HH:MM:SS).
///
/// Com [session], o ticks fica isolado neste widget (1 Hz) — não reconstrói
/// a tela pai. Sem [session], usa [elapsed] estático (histórico / resumo).
class ShiftTimerWidget extends StatefulWidget {
  const ShiftTimerWidget({
    required this.isPaused,
    this.elapsed,
    this.session,
    super.key,
  }) : assert(elapsed != null || session != null);

  final Duration? elapsed;
  final ShiftSessionEntity? session;
  final bool isPaused;

  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  State<ShiftTimerWidget> createState() => _ShiftTimerWidgetState();
}

class _ShiftTimerWidgetState extends State<ShiftTimerWidget> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = _resolveElapsed();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant ShiftTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session == null) {
      _elapsed = widget.elapsed ?? Duration.zero;
    } else if (oldWidget.session?.id != widget.session?.id ||
        oldWidget.session?.status != widget.session?.status ||
        oldWidget.session?.pausedAt != widget.session?.pausedAt ||
        oldWidget.session?.accumulatedPause !=
            widget.session?.accumulatedPause) {
      _elapsed = _resolveElapsed();
    }
    _syncTicker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _resolveElapsed() {
    final session = widget.session;
    if (session != null) return session.elapsedAt(DateTime.now());
    return widget.elapsed ?? Duration.zero;
  }

  void _syncTicker() {
    final shouldTick =
        widget.session != null && !widget.isPaused && widget.session!.isActive;
    if (shouldTick) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsed = _resolveElapsed());
      });
    } else {
      _timer?.cancel();
      _timer = null;
      _elapsed = _resolveElapsed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isPaused = widget.isPaused ||
        widget.session?.status == ShiftSessionStatus.paused;

    return Column(
      children: [
        Text(
          isPaused ? 'Turno pausado' : 'Tempo no turno',
          style: AppTypography.iosFootnote(brightness).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryLabel(Theme.of(context)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ShiftTimerWidget.format(_elapsed),
          style: AppTypography.iosLargeTitle(brightness).copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            fontWeight: FontWeight.w700,
            color: isPaused ? AppColors.warningAmber : null,
          ),
        ),
      ],
    );
  }
}

/// Texto de tempo decorrido com tick isolado (banner compacto).
class LiveElapsedText extends StatefulWidget {
  const LiveElapsedText({
    required this.session,
    this.style,
    super.key,
  });

  final ShiftSessionEntity session;
  final TextStyle? style;

  @override
  State<LiveElapsedText> createState() => _LiveElapsedTextState();
}

class _LiveElapsedTextState extends State<LiveElapsedText> {
  Timer? _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.session.elapsedAt(DateTime.now());
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant LiveElapsedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.id != widget.session.id ||
        oldWidget.session.status != widget.session.status ||
        oldWidget.session.pausedAt != widget.session.pausedAt ||
        oldWidget.session.accumulatedPause !=
            widget.session.accumulatedPause) {
      _elapsed = widget.session.elapsedAt(DateTime.now());
    }
    _syncTicker();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    final shouldTick = widget.session.status != ShiftSessionStatus.paused &&
        widget.session.isActive;
    if (shouldTick) {
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _elapsed = widget.session.elapsedAt(DateTime.now());
        });
      });
    } else {
      _timer?.cancel();
      _timer = null;
      _elapsed = widget.session.elapsedAt(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      ShiftTimerWidget.format(_elapsed),
      style: widget.style,
    );
  }
}
