import 'package:flutter/material.dart';
import 'package:passion_tree_frontend/core/theme/colors.dart';
import 'package:passion_tree_frontend/core/theme/typography.dart';
import 'package:passion_tree_frontend/core/common_widgets/inputs/pixel_border.dart';
import 'package:passion_tree_frontend/features/dashboard/data/models/dashboard_response.dart';

class TreeCardWidget extends StatefulWidget {
  final int level;
  final TreeCounterStats? treeStats;

  const TreeCardWidget({super.key, required this.level, this.treeStats});

  @override
  State<TreeCardWidget> createState() => _TreeCardWidgetState();
}

class _TreeCardWidgetState extends State<TreeCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  void _openGardenModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Garden',
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: _GardenModal(treeStats: widget.treeStats),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treesPlanted = widget.treeStats?.totalTreesPlanted ?? 0;
    final nodesUnlocked = widget.treeStats?.totalNodesUnlocked ?? 0;

    return GestureDetector(
      onTap: () => _openGardenModal(context),
      child: PixelBorderContainer(
        width: double.infinity,
        pixelSize: 3,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.park, size: 18, color: AppColors.secondaryBrand),
                const SizedBox(width: 6),
                Text(
                  '$treesPlanted Tree${treesPlanted != 1 ? 's' : ''} Planted',
                  style: AppTypography.bodySemiBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$nodesUnlocked Nodes',
                  style: AppTypography.smallBodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.open_in_full,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRect(
              child: SizedBox(
                width: double.infinity,
                height: 190,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _twinkle,
                        builder: (_, _) => CustomPaint(
                          painter: _ForestPainter(
                            treeCount: treesPlanted,
                            twinkle: _twinkle.value,
                          ),
                        ),
                      ),
                    ),
                    if (treesPlanted == 0)
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: Text(
                          'Start learning to grow your forest!',
                          textAlign: TextAlign.center,
                          style: AppTypography.smallBodyRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum _Stage { seedling, sprout, small, medium, large }

class _ForestPainter extends CustomPainter {
  final int treeCount;
  final double twinkle;
  const _ForestPainter({required this.treeCount, required this.twinkle});

  static const double _tW = 50.0;
  static const double _tH = 25.0;
  static const int _cols = 6;
  static const int _rows = 6;
  static const double _sideH = 12.0;

  static const List<(int, int)> _fillOrder = [
    (2, 2), (3, 2), (2, 3), (3, 3),
    (1, 2), (4, 2), (2, 1), (3, 1), (1, 3), (4, 3), (2, 4), (3, 4),
    (1, 1), (4, 1), (1, 4), (4, 4),
    (0, 2), (5, 2), (2, 0), (3, 0), (0, 3), (5, 3), (2, 5), (3, 5),
    (0, 1), (5, 1), (1, 0), (4, 0), (0, 4), (5, 4), (1, 5), (4, 5),
    (0, 0), (5, 0), (0, 5), (5, 5),
  ];

  static Offset _p(Offset o, double gx, double gy, double gz) =>
      Offset(o.dx + (gx - gy) * _tW / 2, o.dy + (gx + gy) * _tH / 2 - gz * _tH);

  static Offset _origin(Size s) => Offset(
        s.width / 2 - (_cols - _rows) * _tW / 4,
        s.height - (_cols + _rows) * _tH / 2 - _sideH - 8,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final o = _origin(size);
    _drawSky(canvas, size);
    _drawStars(canvas, size, o);
    _drawMoon(canvas, size);
    _drawScene(canvas, o);
  }

  void _drawSky(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF020C1E),
            Color(0xFF061228),
            Color(0xFF0D2040),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  static const List<double> _sx = [
    0.08, 0.22, 0.35, 0.42, 0.55, 0.65, 0.71, 0.85, 0.92, 0.14,
    0.28, 0.48, 0.60, 0.77, 0.93, 0.06, 0.19, 0.38, 0.52, 0.70,
    0.88, 0.31, 0.76, 0.44, 0.12, 0.67, 0.83, 0.25, 0.57, 0.40,
    0.95, 0.03, 0.73, 0.50, 0.18, 0.62, 0.90, 0.33, 0.47, 0.79,
  ];
  static const List<double> _sy = [
    0.10, 0.05, 0.14, 0.06, 0.09, 0.04, 0.15, 0.08, 0.12, 0.20,
    0.25, 0.22, 0.18, 0.24, 0.20, 0.30, 0.35, 0.32, 0.28, 0.33,
    0.30, 0.08, 0.06, 0.30, 0.03, 0.17, 0.11, 0.26, 0.07, 0.21,
    0.13, 0.09, 0.29, 0.16, 0.34, 0.02, 0.23, 0.19, 0.27, 0.05,
  ];

  void _drawStars(Canvas canvas, Size size, Offset o) {
    final alpha = (treeCount / 10.0).clamp(0.0, 1.0);
    if (alpha == 0) return;
    // จำกัดดาวอยู่แค่ 45% บนสุดของ canvas
    final skyHeight = size.height * 0.45;
    for (int i = 0; i < _sx.length; i++) {
      final phase = (twinkle + i * 0.137) % 1.0;
      final flicker = 0.4 + 0.6 * (0.5 + 0.5 * _sin(phase * 3.1416 * 2));
      final big = i % 4 == 0;
      // clamp sy ไม่ให้เกิน 0.9 → ดาวอยู่ใน skyHeight เสมอ
      final sy = _sy[i].clamp(0.0, 0.9);
      canvas.drawCircle(
        Offset(_sx[i] * size.width, sy * skyHeight),
        big ? 1.5 : 1.0,
        Paint()
          ..color = Colors.white.withValues(
              alpha: alpha * flicker * (big ? 0.85 : 0.5)),
      );
    }
  }

  double _sin(double x) =>
      (x - x * x * x / 6 + x * x * x * x * x / 120).clamp(-1.0, 1.0);

  void _drawMoon(Canvas canvas, Size size) {
    final cx = size.width * 0.84;
    final cy = size.height * 0.11;
    canvas.drawCircle(Offset(cx, cy), 10, Paint()..color = const Color(0xFFFFF0A0));
    canvas.drawCircle(Offset(cx + 6, cy - 3), 7, Paint()..color = const Color(0xFF061228));
  }

  void _drawScene(Canvas canvas, Offset o) {
    final n = treeCount.clamp(0, 36);
    final base = _baseStage(treeCount);

    final treeAt = <(int, int), ({_Stage stage, int type})>{};
    for (int i = 0; i < n; i++) {
      final (gx, gy) = _fillOrder[i];
      final type = (gx * 7 + gy * 11) % 4;
      var s = switch (type) {
        0 => _grow(base),
        3 => _shrink(base),
        _ => base,
      };
      if (i < n * 0.25) s = _grow(s);
      treeAt[(gx, gy)] = (stage: s, type: type);
    }

    for (int sum = 0; sum < _cols + _rows - 1; sum++) {
      for (int gx = 0; gx < _cols; gx++) {
        final gy = sum - gx;
        if (gy < 0 || gy >= _rows) continue;
        final td = treeAt[(gx, gy)];
        _tile(canvas, o, gx, gy, td != null);
        if (gx == _cols - 1) _rightFace(canvas, o, gx, gy);
        if (gy == _rows - 1) _frontFace(canvas, o, gx, gy);
        if (td != null) {
          _dispatchTree(canvas, o, gx.toDouble(), gy.toDouble(), td.stage, td.type);
        }
      }
    }
  }

  void _tile(Canvas canvas, Offset o, int gx, int gy, bool hasTree) {
    final g = gx.toDouble();
    final r = gy.toDouble();
    final back  = _p(o, g,     r,     0);
    final right = _p(o, g + 1, r,     0);
    final front = _p(o, g + 1, r + 1, 0);
    final left  = _p(o, g,     r + 1, 0);

    final fill = Path()
      ..moveTo(back.dx,  back.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(front.dx, front.dy)
      ..lineTo(left.dx,  left.dy)
      ..close();

    canvas.drawPath(
      fill,
      Paint()..color = hasTree ? const Color(0xFF153A18) : const Color(0xFF0E2E12),
    );
    canvas.drawPath(fill, Paint()
      ..color = const Color(0xFF091A0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8);
  }

  void _rightFace(Canvas canvas, Offset o, int gx, int gy) {
    final g = gx.toDouble();
    final r = gy.toDouble();
    final a = _p(o, g + 1, r,     0);
    final b = _p(o, g + 1, r + 1, 0);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(b.dx, b.dy + _sideH)
        ..lineTo(a.dx, a.dy + _sideH)
        ..close(),
      Paint()..color = const Color(0xFF091408),
    );
  }

  void _frontFace(Canvas canvas, Offset o, int gx, int gy) {
    final g = gx.toDouble();
    final r = gy.toDouble();
    final a = _p(o, g,     r + 1, 0);
    final b = _p(o, g + 1, r + 1, 0);
    canvas.drawPath(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(b.dx, b.dy + _sideH)
        ..lineTo(a.dx, a.dy + _sideH)
        ..close(),
      Paint()..color = const Color(0xFF0C2010),
    );
  }

  void _dispatchTree(Canvas canvas, Offset o, double gx, double gy,
      _Stage stage, int type) {
    final cx = gx + 0.5;
    final cy = gy + 0.5;
    switch (type) {
      case 0:
        _pine(canvas, o, cx, cy, stage);
      case 2:
        _pine(canvas, o, cx, cy, _shrink(stage));
      case 1:
        _round(canvas, o, cx, cy, stage);
      case 3:
        if (stage == _Stage.seedling ||
            stage == _Stage.sprout ||
            stage == _Stage.small) {
          _flower(canvas, o, cx, cy, (gx * 3 + gy * 5).round() % 3);
        } else {
          _round(canvas, o, cx, cy, _shrink(stage));
        }
      default:
        _pine(canvas, o, cx, cy, stage);
    }
  }

  void _pine(Canvas canvas, Offset o, double cx, double cy, _Stage s) {
    final (tH, cR, layers) = _pineP(s);
    _trunk(canvas, o, cx, cy, tH, 0.07);
    for (int i = 0; i < layers; i++) {
      final t  = layers == 1 ? 0.5 : i / (layers - 1).toDouble();
      final r  = cR * (1.0 - t * 0.72);
      final gz = tH + i * cR * 0.40;
      _crown(canvas, _p(o, cx, cy, gz), r, t);
    }
  }

  (double, double, int) _pineP(_Stage s) => switch (s) {
    _Stage.seedling => (0.18, 0.13, 1),
    _Stage.sprout   => (0.30, 0.18, 2),
    _Stage.small    => (0.48, 0.24, 3),
    _Stage.medium   => (0.72, 0.30, 4),
    _Stage.large    => (1.05, 0.37, 5),
  };

  void _round(Canvas canvas, Offset o, double cx, double cy, _Stage s) {
    final (tH, cR, layers) = _roundP(s);
    _trunk(canvas, o, cx, cy, tH, 0.13);
    for (int i = 0; i < layers; i++) {
      final t  = layers == 1 ? 0.5 : i / (layers - 1).toDouble();
      final r  = cR * (1.0 - t * 0.28);
      final gz = tH + i * cR * 0.72;
      _crown(canvas, _p(o, cx, cy, gz), r, t);
    }
  }

  (double, double, int) _roundP(_Stage s) => switch (s) {
    _Stage.seedling => (0.12, 0.22, 1),
    _Stage.sprout   => (0.18, 0.33, 1),
    _Stage.small    => (0.25, 0.44, 2),
    _Stage.medium   => (0.33, 0.56, 2),
    _Stage.large    => (0.42, 0.65, 2),
  };

  static const List<Color> _fc = [
    Color(0xFFFFDA08),
    Color(0xFFFF8EC4),
    Color(0xFFD4F5FF),
  ];

  void _flower(Canvas canvas, Offset o, double cx, double cy, int ci) {
    canvas.drawLine(
      _p(o, cx, cy, 0.00),
      _p(o, cx, cy, 0.24),
      Paint()
        ..color = const Color(0xFF2A8030)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    final mid = _p(o, cx, cy, 0.13);
    canvas.drawLine(
      mid,
      mid + const Offset(6, 1),
      Paint()..color = const Color(0xFF348038)..strokeWidth = 1.0,
    );
    final bud = _p(o, cx, cy, 0.30);
    const hw = 0.16 * _tW / 2;
    const hh = 0.16 * _tH / 2;
    canvas.drawPath(
      Path()
        ..moveTo(bud.dx + hw, bud.dy - hh)
        ..lineTo(bud.dx + hw, bud.dy + hh)
        ..lineTo(bud.dx - hw, bud.dy + hh)
        ..lineTo(bud.dx - hw, bud.dy - hh)
        ..close(),
      Paint()..color = _fc[ci],
    );
    canvas.drawCircle(
      bud + const Offset(0, hh * 0.3),
      1.2,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _trunk(Canvas canvas, Offset o, double cx, double cy, double h, double w) {
    final base = _p(o, cx, cy, 0);
    final dx   = 2 * w * _tW / 2;
    final dy   = 2 * w * _tH / 2;
    final rise = h * _tH;

    canvas.drawPath(
      Path()
        ..moveTo(base.dx - dx, base.dy)
        ..lineTo(base.dx,      base.dy + dy)
        ..lineTo(base.dx,      base.dy + dy - rise)
        ..lineTo(base.dx - dx, base.dy - rise)
        ..close(),
      Paint()..color = const Color(0xFF3A1E08),
    );
    canvas.drawPath(
      Path()
        ..moveTo(base.dx,      base.dy + dy)
        ..lineTo(base.dx + dx, base.dy)
        ..lineTo(base.dx + dx, base.dy - rise)
        ..lineTo(base.dx,      base.dy + dy - rise)
        ..close(),
      Paint()..color = const Color(0xFF5C3014),
    );
  }

  void _crown(Canvas canvas, Offset c, double r, double t) {
    final hw = r * _tW / 2;
    final hh = r * _tH / 2;

    final back  = Offset(c.dx + hw, c.dy - hh);
    final right = Offset(c.dx + hw, c.dy + hh);
    final front = Offset(c.dx - hw, c.dy + hh);
    final left  = Offset(c.dx - hw, c.dy - hh);

    final diamond = Path()
      ..moveTo(back.dx,  back.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(front.dx, front.dy)
      ..lineTo(left.dx,  left.dy)
      ..close();

    final green = Color.lerp(
      const Color(0xFF1C6422),
      const Color(0xFF30943A),
      t,
    )!;
    canvas.drawPath(diamond, Paint()..color = green);

    canvas.drawPath(
      Path()
        ..moveTo(c.dx,     c.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(front.dx, front.dy)
        ..close(),
      Paint()..color = const Color(0xFF0A2E0E).withValues(alpha: 0.55),
    );

    canvas.drawLine(back, left, Paint()
      ..color = const Color(0xFF3CAA3E).withValues(alpha: 0.55)
      ..strokeWidth = 1.5);
  }

  _Stage _grow(_Stage s) => switch (s) {
    _Stage.seedling => _Stage.sprout,
    _Stage.sprout   => _Stage.small,
    _Stage.small    => _Stage.medium,
    _Stage.medium   => _Stage.large,
    _Stage.large    => _Stage.large,
  };

  _Stage _shrink(_Stage s) => switch (s) {
    _Stage.seedling => _Stage.seedling,
    _Stage.sprout   => _Stage.seedling,
    _Stage.small    => _Stage.sprout,
    _Stage.medium   => _Stage.small,
    _Stage.large    => _Stage.medium,
  };

  _Stage _baseStage(int n) {
    if (n >= 45) return _Stage.large;
    if (n >= 25) return _Stage.medium;
    if (n >= 10) return _Stage.small;
    if (n >= 3)  return _Stage.sprout;
    return _Stage.seedling;
  }

  @override
  bool shouldRepaint(_ForestPainter old) =>
      old.treeCount != treeCount || old.twinkle != twinkle;
}

// ─────────────────────────────────────────────────────────────────────────────

class _GardenModal extends StatefulWidget {
  final TreeCounterStats? treeStats;
  const _GardenModal({this.treeStats});

  @override
  State<_GardenModal> createState() => _GardenModalState();
}

class _GardenModalState extends State<_GardenModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treesPlanted = widget.treeStats?.totalTreesPlanted ?? 0;
    final nodesUnlocked = widget.treeStats?.totalNodesUnlocked ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.park, size: 20, color: AppColors.secondaryBrand),
              const SizedBox(width: 8),
              Text(
                'My Garden',
                style: AppTypography.bodySemiBold
                    .copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '$treesPlanted Trees · $nodesUnlocked Nodes',
                style: AppTypography.smallBodyRegular
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return ClipRRect(
                child: SizedBox(
                  width: w,
                  height: 320,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 6.0,
                    child: SizedBox(
                      width: w,
                      height: 320,
                      child: AnimatedBuilder(
                        animation: _twinkle,
                        builder: (_, _) => CustomPaint(
                          painter: _ForestPainter(
                            treeCount: treesPlanted,
                            twinkle: _twinkle.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Pinch to zoom · Drag to pan',
              style: AppTypography.smallBodyRegular.copyWith(
                color: Colors.white30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}