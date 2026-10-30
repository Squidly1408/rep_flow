import 'dart:ui';

/// A stick-figure pose. Every joint is in a normalised 0–1 box
/// (x: left → right, y: top → bottom). The floor sits at y ≈ 0.955.
///
/// "l" limbs are drawn behind the body (faded in side views),
/// "r" limbs are drawn in front.
class Pose {
  const Pose({
    required this.head,
    required this.neck,
    required this.hip,
    required this.lElbow,
    required this.lHand,
    required this.rElbow,
    required this.rHand,
    required this.lKnee,
    required this.lFoot,
    required this.rKnee,
    required this.rFoot,
  });

  final Offset head;
  final Offset neck;
  final Offset hip;
  final Offset lElbow;
  final Offset lHand;
  final Offset rElbow;
  final Offset rHand;
  final Offset lKnee;
  final Offset lFoot;
  final Offset rKnee;
  final Offset rFoot;

  static Pose lerp(Pose a, Pose b, double t) {
    Offset l(Offset x, Offset y) => Offset.lerp(x, y, t)!;
    return Pose(
      head: l(a.head, b.head),
      neck: l(a.neck, b.neck),
      hip: l(a.hip, b.hip),
      lElbow: l(a.lElbow, b.lElbow),
      lHand: l(a.lHand, b.lHand),
      rElbow: l(a.rElbow, b.rElbow),
      rHand: l(a.rHand, b.rHand),
      lKnee: l(a.lKnee, b.lKnee),
      lFoot: l(a.lFoot, b.lFoot),
      rKnee: l(a.rKnee, b.rKnee),
      rFoot: l(a.rFoot, b.rFoot),
    );
  }
}
