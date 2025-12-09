import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/tracking_models.dart';
import '../../domain/services/tracking_service.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/growth_chart_widget.dart';
import '../widgets/badge_collection_widget.dart';
import '../widgets/level_display_widget.dart';
import '../widgets/calendar_widget.dart';

/// WP 3.6: 장기 추적 시스템 메인 페이지
class TrackingPage extends StatefulWidget {
  final String childId;
  final String? childName;

  const TrackingPage({
    super.key,
    required this.childId,
    this.childName,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TrackingService _trackingService = TrackingService();

  bool _dataGenerated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 샘플 데이터 생성 (처음 한 번만)
    if (!_dataGenerated) {
      _trackingService.generateSampleData(widget.childId);
      _dataGenerated = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = _trackingService.getLevelInfo(widget.childId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.childName ?? '아동'}의 성장 기록'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: '타임라인'),
            Tab(icon: Icon(Icons.show_chart), text: '성장'),
            Tab(icon: Icon(Icons.emoji_events), text: '배지'),
            Tab(icon: Icon(Icons.calendar_month), text: '캘린더'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 레벨 카드 (모든 탭에서 공통으로 보임)
          Padding(
            padding: const EdgeInsets.all(16),
            child: LevelDisplayWidget(levelInfo: levelInfo),
          ),

          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildGrowthTab(),
                _buildBadgeTab(),
                _buildCalendarTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    final events = _trackingService.getTimelineEvents(widget.childId);

    return TimelineWidget(
      events: events,
      onEventTap: (event) {
        _showEventDetail(event);
      },
    );
  }

  Widget _buildGrowthTab() {
    final data = _trackingService.getGrowthData(widget.childId);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GrowthChartWidget(
        dataPoints: data,
        onPointTap: (point) {
          _showGrowthDetail(point);
        },
      ),
    );
  }

  Widget _buildBadgeTab() {
    final badges = _trackingService.getBadges(widget.childId);

    return BadgeCollectionWidget(
      badges: badges,
      onBadgeTap: (badge) {
        _showBadgeDetail(badge);
      },
    );
  }

  Widget _buildCalendarTab() {
    final calendarData = _trackingService.getCalendarData(
      widget.childId,
      DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LearningCalendarWidget(
        calendarData: calendarData,
        onDayTap: (date, session) {
          if (session != null) {
            _showSessionDetail(session);
          }
        },
      ),
    );
  }

  void _showEventDetail(TimelineEvent event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _getEventEmoji(event.type),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(event.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                event.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGrowthDetail(GrowthDataPoint point) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatDate(point.date)} 검사 결과',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '전체 점수: ${point.totalScore.toStringAsFixed(0)}점',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '영역별 점수',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...point.domainScores.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getDomainName(entry.key)),
                      Text(
                        '${entry.value.toStringAsFixed(0)}점',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBadgeDetail(AchievementBadge badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.isEarned ? badge.emoji : '🔒',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              if (badge.isEarned) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_formatDate(badge.earnedAt!)} 획득',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '조건: ${_getConditionText(badge)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSessionDetail(LearningSessionRecord session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatDate(session.date)} 학습 기록',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('학습 시간', '${session.durationMinutes}분'),
              _buildDetailRow('완료 게임', '${session.completedGames.length}개'),
              _buildDetailRow('총 문제', '${session.totalQuestions}개'),
              _buildDetailRow('정답 수', '${session.correctAnswers}개'),
              _buildDetailRow(
                '정답률',
                '${session.averageAccuracy.toStringAsFixed(0)}%',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _getDomainName(String domain) {
    const names = {
      'phonological': '음운 인식',
      'visual': '시각 처리',
      'auditory': '청각 처리',
      'memory': '작업 기억',
      'attention': '주의 집중',
    };
    return names[domain] ?? domain;
  }

  String _getConditionText(AchievementBadge badge) {
    switch (badge.condition) {
      case 'consecutive_days':
        return '${badge.requiredValue}일 연속 학습';
      case 'overall_accuracy':
        return '전체 정답률 ${badge.requiredValue}% 달성';
      case 'score_increase':
        return '점수 ${badge.requiredValue}점 이상 상승';
      case 'total_minutes':
        return '총 ${badge.requiredValue}분 학습';
      default:
        return '';
    }
  }
}

