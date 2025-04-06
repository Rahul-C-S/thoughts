import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:thoughts/app/config/theme/app_colors.dart';

class Loader extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final double size;
  final Duration duration;
  final Widget? child;
  final double strokeWidth;

  const Loader({
    super.key,
    this.primaryColor = AppColors.primary,
    this.secondaryColor = AppColors.accent,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1500),
    this.child,
    this.strokeWidth = 4.0,
  });

  @override
  State<Loader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<Loader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer rotating arc
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _LoaderArcPainter(
                      color: widget.primaryColor,
                      startAngle: 0,
                      sweepAngle: 300 * math.pi / 180,
                      strokeWidth: widget.strokeWidth,
                    ),
                  ),
                );
              },
            ),
            // Inner rotating arc (opposite direction)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(widget.size * 0.65, widget.size * 0.65),
                    painter: _LoaderArcPainter(
                      color: widget.secondaryColor,
                      startAngle: 0,
                      sweepAngle: 270 * math.pi / 180,
                      strokeWidth: widget.strokeWidth * 0.8,
                    ),
                  ),
                );
              },
            ),
            // Optional child widget in the center
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

class _LoaderArcPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double strokeWidth;

  _LoaderArcPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_LoaderArcPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
