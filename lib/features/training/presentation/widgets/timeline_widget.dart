import 'package:flutter/material.dart';
import '../../data/models/tracking_models.dart';

/// S 3.6.1: 타임라인 뷰 위젯
class TimelineWidget extends StatelessWidget {
  final List<TimelineEvent> events;
  final Function(TimelineEvent)? onEventTap;

  const TimelineWidget({
    super.key,
    required this.events,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return _buildTimelineItem(context, event, isLast);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📅',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 기록이 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '학습을 시작하면 여기에 기록이 표시됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    TimelineEvent event,
    bool isLast,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 표시
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getEventColor(event.type),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getEventEmoji(event.type),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // 이벤트 카드
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => onEventTap?.call(event),
                child: Container(
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
                      // 날짜
                      Text(
                        _formatDate(event.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 제목
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 설명
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      // 점수 표시 (있을 경우)
                      if (event.metadata?['score'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventColor(event.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(event.metadata!['score'] as double).toStringAsFixed(0)}점',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getEventColor(event.type),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.assessment:
        return Colors.blue;
      case TimelineEventType.miniTest:
        return Colors.orange;
      case TimelineEventType.achievement:
        return Colors.amber;
      case TimelineEventType.levelUp:
        return Colors.purple;
      case TimelineEventType.milestone:
        return Colors.green;
    }
  }

  String _getEventEmoji(TimelineEventType type) {
    switch (type) {
      case TimelineEventType.assessment:
        return '📋';
      case TimelineEventType.miniTest:
        return '📝';
      case TimelineEventType.achievement:
        return '🏆';
      case TimelineEventType.levelUp:
        return '⬆️';
      case TimelineEventType.milestone:
        return '🎯';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

