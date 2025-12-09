import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

/// S 3.6.2: 성장 그래프 위젯
class GrowthChartWidget extends StatefulWidget {
  final List<GrowthDataPoint> dataPoints;
  final Function(GrowthDataPoint)? onPointTap;

  const GrowthChartWidget({
    super.key,
    required this.dataPoints,
    this.onPointTap,
  });

  @override
  State<GrowthChartWidget> createState() => _GrowthChartWidgetState();
}

class _GrowthChartWidgetState extends State<GrowthChartWidget> {
  String _selectedPeriod = '3개월';
  int? _selectedPointIndex;

  static const List<String> _periods = ['1개월', '3개월', '6개월', '1년'];
  static const Map<String, Color> _domainColors = {
    'phonological': Colors.blue,
    'visual': Colors.orange,
    'auditory': Colors.green,
    'memory': Colors.purple,
    'attention': Colors.red,
  };
  static const Map<String, String> _domainNames = {
    'phonological': '음운 인식',
    'visual': '시각 처리',
    'auditory': '청각 처리',
    'memory': '작업 기억',
    'attention': '주의 집중',
  };

  List<GrowthDataPoint> get _filteredData {
    if (widget.dataPoints.isEmpty) return [];

    final now = DateTime.now();
    Duration duration;

    switch (_selectedPeriod) {
      case '1개월':
        duration = const Duration(days: 30);
        break;
      case '3개월':
        duration = const Duration(days: 90);
        break;
      case '6개월':
        duration = const Duration(days: 180);
        break;
      case '1년':
        duration = const Duration(days: 365);
        break;
      default:
        duration = const Duration(days: 90);
    }

    final cutoff = now.subtract(duration);
    return widget.dataPoints
        .where((p) => p.date.isAfter(cutoff))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 기간 필터
        _buildPeriodFilter(),
        const SizedBox(height: 16),
        // 차트
        Expanded(child: _buildChart()),
        // 범례
        _buildLegend(),
      ],
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                    _selectedPointIndex = null;
                  });
                }
              },
              selectedColor: Colors.blue[100],
              backgroundColor: Colors.grey[100],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    final data = _filteredData;

    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📊',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 데이터가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            _handleTap(details.localPosition, constraints.maxWidth, data);
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _GrowthChartPainter(
              dataPoints: data,
              domainColors: _domainColors,
              selectedIndex: _selectedPointIndex,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset position, double width, List<GrowthDataPoint> data) {
    if (data.isEmpty) return;

    final pointWidth = width / (data.length - 1).clamp(1, double.infinity);
    final index = (position.dx / pointWidth).round().clamp(0, data.length - 1);

    setState(() {
      _selectedPointIndex = index;
    });

    widget.onPointTap?.call(data[index]);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: _domainColors.entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: entry.value,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _domainNames[entry.key] ?? entry.key,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<GrowthDataPoint> dataPoints;
  final Map<String, Color> domainColors;
  final int? selectedIndex;

  _GrowthChartPainter({
    required this.dataPoints,
    required this.domainColors,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    final padding = const EdgeInsets.fromLTRB(40, 20, 20, 40);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // 그리드 그리기
    _drawGrid(canvas, size, padding, chartWidth, chartHeight);

    // 각 영역별 라인 그리기
    for (final domain in domainColors.keys) {
      final color = domainColors[domain]!;
      paint.color = color;
      pointPaint.color = color;

      final path = Path();
      bool started = false;

      for (int i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final score = point.domainScores[domain] ?? 0;

        final x = padding.left + (i / (dataPoints.length - 1).clamp(1, double.infinity)) * chartWidth;
        final y = padding.top + chartHeight - (score / 100) * chartHeight;

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }

        // 점 그리기
        canvas.drawCircle(
          Offset(x, y),
          selectedIndex == i ? 6 : 4,
          pointPaint,
        );
      }

      canvas.drawPath(path, paint);
    }

    // 선택된 포인트 강조
    if (selectedIndex != null && selectedIndex! < dataPoints.length) {
      final x = padding.left + (selectedIndex! / (dataPoints.length - 1).clamp(1, double.infinity)) * chartWidth;
      
      final linePaint = Paint()
        ..color = Colors.grey[400]!
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(x, padding.top),
        Offset(x, size.height - padding.bottom),
        linePaint,
      );
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    EdgeInsets padding,
    double chartWidth,
    double chartHeight,
  ) {
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 가로선 및 Y축 라벨
    for (int i = 0; i <= 5; i++) {
      final y = padding.top + (i / 5) * chartHeight;
      final score = 100 - (i * 20);

      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '$score',
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(padding.left - textPainter.width - 4, y - textPainter.height / 2),
      );
    }

    // X축 라벨 (날짜)
    if (dataPoints.isNotEmpty) {
      final step = (dataPoints.length / 4).ceil();
      for (int i = 0; i < dataPoints.length; i += step) {
        final x = padding.left + (i / (dataPoints.length - 1).clamp(1, double.infinity)) * chartWidth;
        final date = dataPoints[i].date;

        textPainter.text = TextSpan(
          text: '${date.month}/${date.day}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - padding.bottom + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

