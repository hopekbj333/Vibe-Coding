/// 학습 세션 모델
/// 
/// 일일 학습 제한 및 세션 관리를 위한 데이터 모델
class LearningSession {
  final String id;
  final String childId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes; // 설정된 제한 시간 (기본 15분)
  final int elapsedSeconds; // 경과 시간
  final int questionsCompleted;
  final int correctAnswers;
  final List<String> completedModules;
  final SessionStatus status;

  LearningSession({
    required this.id,
    required this.childId,
    required this.startTime,
    this.endTime,
    this.durationMinutes = 15,
    this.elapsedSeconds = 0,
    this.questionsCompleted = 0,
    this.correctAnswers = 0,
    this.completedModules = const [],
    this.status = SessionStatus.active,
  });

  LearningSession copyWith({
    String? id,
    String? childId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    int? elapsedSeconds,
    int? questionsCompleted,
    int? correctAnswers,
    List<String>? completedModules,
    SessionStatus? status,
  }) {
    return LearningSession(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      questionsCompleted: questionsCompleted ?? this.questionsCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      completedModules: completedModules ?? this.completedModules,
      status: status ?? this.status,
    );
  }

  /// 남은 시간 (초)
  int get remainingSeconds {
    final totalSeconds = durationMinutes * 60;
    return (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
  }

  /// 남은 시간 (분:초 형식)
  String get remainingTimeFormatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    final totalSeconds = durationMinutes * 60;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// 정답률
  double get accuracy {
    if (questionsCompleted == 0) return 0.0;
    return correctAnswers / questionsCompleted;
  }

  /// 시간 종료 여부
  bool get isTimeUp => remainingSeconds <= 0;

  /// 5분 남음 알림 필요 여부
  bool get shouldNotify5Minutes {
    return remainingSeconds <= 300 && remainingSeconds > 295;
  }

  /// 1분 남음 알림 필요 여부
  bool get shouldNotify1Minute {
    return remainingSeconds <= 60 && remainingSeconds > 55;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'elapsedSeconds': elapsedSeconds,
      'questionsCompleted': questionsCompleted,
      'correctAnswers': correctAnswers,
      'completedModules': completedModules,
      'status': status.name,
    };
  }

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] as String,
      childId: json['childId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationMinutes: json['durationMinutes'] as int? ?? 15,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      questionsCompleted: json['questionsCompleted'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      completedModules: (json['completedModules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
    );
  }
}

enum SessionStatus {
  active,    // 진행 중
  paused,    // 일시 정지
  completed, // 정상 완료
  timeUp,    // 시간 종료
}

