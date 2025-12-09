import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/design/design_system.dart';

/// 세션 타이머 위젯
/// 
/// 남은 학습 시간을 원형 프로그레스로 표시
class SessionTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isCompact;
  final VoidCallback? onTap;

  const SessionTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 
        ? remainingSeconds / totalSeconds 
        : 0.0;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // 경고 색상 (5분 이하: 노랑, 1분 이하: 빨강)
    Color timerColor = DesignSystem.primaryBlue;
    if (remainingSeconds <= 60) {
      timerColor = DesignSystem.semanticError;
    } else if (remainingSeconds <= 300) {
      timerColor = DesignSystem.semanticWarning;
    }

    if (isCompact) {
      return _buildCompactTimer(timeText, progress, timerColor);
    }

    return _buildFullTimer(timeText, progress, timerColor);
  }

  Widget _buildCompactTimer(String timeText, double progress, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              timeText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullTimer(String timeText, double progress, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 원
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade200),
              ),
            ),
            // 진행 원
            SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: _CircularProgressPainter(
                      progress: value,
                      color: color,
                      strokeWidth: 8,
                    ),
                  );
                },
              ),
            ),
            // 시간 텍스트
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

/// 타이머 알림 다이얼로그
class TimerAlertDialog extends StatelessWidget {
  final TimerAlertType type;
  final VoidCallback? onContinue;
  final VoidCallback? onStop;

  const TimerAlertDialog({
    super.key,
    required this.type,
    this.onContinue,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getEmoji(),
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getMessage(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: type == TimerAlertType.timeUp
          ? [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onStop?.call();
                },
                child: const Text('확인'),
              ),
            ]
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onContinue?.call();
                },
                child: const Text('계속하기'),
              ),
            ],
    );
  }

  String _getEmoji() {
    switch (type) {
      case TimerAlertType.fiveMinutes:
        return '⏰';
      case TimerAlertType.oneMinute:
        return '🏃';
      case TimerAlertType.timeUp:
        return '🎉';
    }
  }

  String _getTitle() {
    switch (type) {
      case TimerAlertType.fiveMinutes:
        return '5분 남았어요!';
      case TimerAlertType.oneMinute:
        return '1분 남았어요!';
      case TimerAlertType.timeUp:
        return '오늘은 여기까지!';
    }
  }

  String _getMessage() {
    switch (type) {
      case TimerAlertType.fiveMinutes:
        return '조금만 더 하면 끝이야!';
      case TimerAlertType.oneMinute:
        return '마무리하자!';
      case TimerAlertType.timeUp:
        return '오늘 정말 잘했어요!\n내일 또 만나요 👋';
    }
  }
}

enum TimerAlertType {
  fiveMinutes,
  oneMinute,
  timeUp,
}

