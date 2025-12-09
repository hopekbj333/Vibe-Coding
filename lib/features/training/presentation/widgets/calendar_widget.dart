import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

/// S 3.6.3: 학습 캘린더 위젯
class LearningCalendarWidget extends StatefulWidget {
  final Map<DateTime, LearningSessionRecord?> calendarData;
  final Function(DateTime, LearningSessionRecord?)? onDayTap;

  const LearningCalendarWidget({
    super.key,
    required this.calendarData,
    this.onDayTap,
  });

  @override
  State<LearningCalendarWidget> createState() => _LearningCalendarWidgetState();
}

class _LearningCalendarWidgetState extends State<LearningCalendarWidget> {
  late DateTime _selectedMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 월 네비게이션
          _buildMonthNavigation(),
          const SizedBox(height: 16),
          
          // 요일 헤더
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          
          // 달력 그리드
          _buildCalendarGrid(),
          
          // 범례
          _buildLegend(),
          
          // 선택된 날짜 상세 정보
          if (_selectedDay != null) _buildDayDetail(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _selectedMonth = DateTime(
                _selectedMonth.year,
                _selectedMonth.month - 1,
              );
              _selectedDay = null;
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${_selectedMonth.year}년 ${_selectedMonth.month}월',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {
            final now = DateTime.now();
            if (_selectedMonth.year < now.year ||
                (_selectedMonth.year == now.year &&
                    _selectedMonth.month < now.month)) {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
                _selectedDay = null;
              });
            }
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: day == '일'
                    ? Colors.red[400]
                    : day == '토'
                        ? Colors.blue[400]
                        : Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    // 이전 달의 빈 칸
    for (int i = 0; i < startingWeekday; i++) {
      days.add(const SizedBox());
    }

    // 현재 달의 날짜들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final session = widget.calendarData[date];
      final isToday = _isToday(date);
      final isSelected = _selectedDay != null &&
          _selectedDay!.year == date.year &&
          _selectedDay!.month == date.month &&
          _selectedDay!.day == date.day;

      days.add(_buildDayCell(date, day, session, isToday, isSelected));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: days,
    );
  }

  Widget _buildDayCell(
    DateTime date,
    int day,
    LearningSessionRecord? session,
    bool isToday,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
        widget.onDayTap?.call(date, session);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[100]
              : isToday
                  ? Colors.blue[50]
                  : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : null,
                color: _getDayColor(date),
              ),
            ),
            const SizedBox(height: 2),
            _buildStudyIndicator(session),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyIndicator(LearningSessionRecord? session) {
    if (session == null) {
      return const Text(
        '-',
        style: TextStyle(fontSize: 10, color: Colors.grey),
      );
    }

    final duration = session.durationMinutes;
    String indicator;
    Color color;

    if (duration >= 30) {
      indicator = '🌟🌟';
      color = Colors.amber;
    } else if (duration >= 15) {
      indicator = '🌟';
      color = Colors.amber;
    } else {
      indicator = '⭐';
      color = Colors.grey;
    }

    return Text(
      indicator,
      style: const TextStyle(fontSize: 10),
    );
  }

  Color _getDayColor(DateTime date) {
    if (date.weekday == DateTime.sunday) {
      return Colors.red[400]!;
    } else if (date.weekday == DateTime.saturday) {
      return Colors.blue[400]!;
    }
    return Colors.black87;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('🌟🌟', '30분 이상'),
          const SizedBox(width: 16),
          _buildLegendItem('🌟', '15분 이상'),
          const SizedBox(width: 16),
          _buildLegendItem('⭐', '15분 미만'),
          const SizedBox(width: 16),
          _buildLegendItem('-', '미학습'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String symbol, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(symbol, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDayDetail() {
    final session = widget.calendarData[_selectedDay];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${_selectedDay!.month}월 ${_selectedDay!.day}일 학습 기록',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (session == null)
            Text(
              '학습 기록이 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            )
          else ...[
            _buildDetailRow('학습 시간', '${session.durationMinutes}분'),
            _buildDetailRow(
              '완료 게임',
              session.completedGames.isEmpty
                  ? '없음'
                  : '${session.completedGames.length}개',
            ),
            _buildDetailRow(
              '정답률',
              '${session.averageAccuracy.toStringAsFixed(0)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

