import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/pose.dart';
import '../theme.dart';

/// Animated stick figure that loops through an exercise's movement.
class ExerciseFigure extends StatefulWidget {
  const ExerciseFigure({
    super.key,
    required this.exercise,
    this.animate = true,
    this.showFloor = true,
    this.strokeScale = 1,
  });

  final Exercise exercise;
  final bool animate;
  final bool showFloor;

  /// Multiplier for line thickness (use > 1 for small thumbnails).
  final double strokeScale;

  @override
  State<ExerciseFigure> createState() => _ExerciseFigureState();
}

class _ExerciseFigureState extends State<ExerciseFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.exercise.tempo,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutSine,
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(ExerciseFigure old) {
    super.didUpdateWidget(old);
    if (old.exercise.tempo != widget.exercise.tempo) {
      _controller.duration = widget.exercise.tempo;
    }
    if (old.animate != widget.animate || old.exercise != widget.exercise) {
      _sync();
    }
  }

  void _sync() {
    if (widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).colorScheme.onSurface;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _FigurePainter(
          animation: _curve,
          exercise: widget.exercise,
          color: ink,
          showFloor: widget.showFloor,
          strokeScale: widget.strokeScale,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({
    required this.animation,
    required this.exercise,
    required this.color,
    required this.showFloor,
    required this.strokeScale,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Exercise exercise;
  final Color color;
  final bool showFloor;
  final double strokeScale;

  @override
  void paint(Canvas canvas, Size size) {
    final pose = Pose.lerp(exercise.start, exercise.end, animation.value);
    final s = math.min(size.width, size.height);
    final ox = (size.width - s) / 2;
    final oy = (size.height - s) / 2;
    Offset m(Offset p) => Offset(ox + p.dx * s, oy + p.dy * s);

    final stroke = s * 0.03 * strokeScale;
    Paint line(double opacity) => Paint()
      ..color = fade(color, opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void limb(Paint p, Offset a, Offset b, Offset c) {
      final path = Path()
        ..moveTo(m(a).dx, m(a).dy)
        ..lineTo(m(b).dx, m(b).dy)
        ..lineTo(m(c).dx, m(c).dy);
      canvas.drawPath(path, p);
    }

    if (showFloor) {
      canvas.drawLine(
        m(const Offset(0.0, 0.965)),
        m(const Offset(1.0, 0.965)),
        Paint()
          ..color = fade(color, 0.12)
          ..strokeWidth = math.max(1, stroke * 0.25)
          ..strokeCap = StrokeCap.round,
      );
    }

    final far = line(exercise.view == ViewAngle.side ? 0.3 : 1);
    final near = line(1);

    // Far limbs first so they sit behind the torso.
    limb(far, pose.hip, pose.lKnee, pose.lFoot);
    limb(far, pose.neck, pose.lElbow, pose.lHand);

    canvas.drawLine(m(pose.neck), m(pose.hip), near);

    limb(near, pose.hip, pose.rKnee, pose.rFoot);
    limb(near, pose.neck, pose.rElbow, pose.rHand);

    canvas.drawCircle(m(pose.head), s * 0.055, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.exercise != exercise ||
      old.color != color ||
      old.showFloor != showFloor ||
      old.strokeScale != strokeScale;
}
