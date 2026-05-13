import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> dataPoints;
  final double maxValue;

  LineChartPainter({
    required this.dataPoints,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3;

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.5;

    final axisPaint = Paint()
      ..color = AppColors.axisLabelColor
      ..strokeWidth = 1;

    final width = size.width;
    final height = size.height;

    for (double value = maxValue / 2; value <= maxValue; value += maxValue / 2) {
      final y = height - (value / maxValue * height);
      _drawDashedLine(canvas, Offset(0, y), Offset(width, y), gridPaint, 4, 4);
    }

    canvas.drawLine(Offset(0, height), Offset(width, height), axisPaint);
    canvas.drawLine(Offset(0, 0), Offset(0, height), axisPaint);

    final points = <Offset>[];
    final spacing = width / (dataPoints.length - 1);
    final maxDay = (dataPoints.last['day'] ?? 20).toInt();

    for (int day = 5; day <= maxDay; day += 5) {
      final dataIndex = day - 1;
      final x = dataIndex * spacing;
      _drawDashedLine(canvas, Offset(x, 0), Offset(x, height), gridPaint, 4, 4);
    }

    for (double value = 0; value <= maxValue; value += maxValue / 2) {
      final y = height - (value / maxValue * height);
      canvas.drawLine(Offset(-6, y), Offset(0, y), axisPaint);
    }

    for (int day = 5; day <= maxDay; day += 5) {
      final dataIndex = day - 1;
      final x = dataIndex * spacing;
      canvas.drawLine(Offset(x, height), Offset(x, height + 6), axisPaint);
    }

    for (int i = 0; i < dataPoints.length; i++) {
      final value = (dataPoints[i]['score'] ?? 0).toDouble();
      final x = i * spacing;
      final y = height - (value / maxValue * height);
      points.add(Offset(x, y));
    }

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 3, Paint()..color = Colors.white..strokeWidth = 1);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashLength, double gapLength) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance == 0) {
      return;
    }

    final steps = (distance / (dashLength + gapLength)).ceil();

    for (int i = 0; i < steps; i++) {
      final t1 = (i * (dashLength + gapLength)) / distance;
      final t2 = (i * (dashLength + gapLength) + dashLength) / distance;

      if (t1 < 1.0) {
        final p1 = Offset(start.dx + dx * t1, start.dy + dy * t1);
        final p2 = Offset(start.dx + dx * t2.clamp(0.0, 1.0), start.dy + dy * t2.clamp(0.0, 1.0));
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
