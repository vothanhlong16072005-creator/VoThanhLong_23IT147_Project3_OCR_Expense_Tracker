import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../models/transaction.dart';

class AnimatedDonutChart extends StatefulWidget {
  final Map<ExpenseCategory, double> dataMap;
  const AnimatedDonutChart({super.key, required this.dataMap});

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.dataMap.values.fold(0, (sum, val) => sum + val);

    if (total == 0) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'No spending data available yet',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        // Donut Chart with Center Total
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 220),
                    painter: DonutChartPainter(
                      dataMap: widget.dataMap,
                      progress: _animation.value,
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Clean Category Legend List
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.dataMap.entries.where((e) => e.value > 0).map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key.displayName,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$percentage%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> dataMap;
  final double progress;

  DonutChartPainter({required this.dataMap, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = dataMap.values.fold(0, (sum, val) => sum + val);
    if (total == 0) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double strokeWidth = 22.0;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(size.center(Offset.zero), (size.width - strokeWidth) / 2, bgPaint);

    double startAngle = -pi / 2;
    final double targetTotalSweep = 2 * pi * progress;

    for (var entry in dataMap.entries) {
      if (entry.value <= 0) continue;

      final sweepAngle = (entry.value / total) * targetTotalSweep;

      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweepAngle > 0.08 ? sweepAngle - 0.04 : sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dataMap != dataMap;
  }
}
