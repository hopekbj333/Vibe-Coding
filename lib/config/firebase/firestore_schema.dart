// Firestore 데이터베이스 스키마 정의
// 
// 이 파일은 Firestore 컬렉션과 문서 구조를 문서화합니다.
// 실제 데이터 모델은 features/ 하위의 각 모듈에서 구현됩니다.

/// 사용자 컬렉션: users
/// 
/// 문서 ID: 사용자 UID (Firebase Auth UID)
/// 
/// 필드:
/// - email: String - 사용자 이메일
/// - displayName: String? - 표시 이름
/// - role: String - 'parent' | 'teacher' | 'admin'
/// - createdAt: Timestamp - 계정 생성 시간
/// - updatedAt: Timestamp - 마지막 업데이트 시간
/// - children: List<String> - 연결된 아동 프로필 ID 목록
class FirestoreSchema {
  FirestoreSchema._();

  // 컬렉션 이름
  static const String users = 'users';
  static const String children = 'children';
  static const String assessments = 'assessments';
  static const String assessmentResults = 'assessment_results';
  static const String audioRecordings = 'audio_recordings';
  static const String scores = 'scores';

  /// 아동 프로필 컬렉션: children
  /// 
  /// 문서 ID: 자동 생성 ID
  /// 
  /// 필드:
  /// - parentId: String - 부모 사용자 UID
  /// - name: String - 아동 이름
  /// - birthDate: Timestamp - 생년월일
  /// - gender: String? - 'male' | 'female' | null
  /// - createdAt: Timestamp - 생성 시간
  /// - updatedAt: Timestamp - 마지막 업데이트 시간
  /// - lastAssessmentDate: Timestamp? - 마지막 검사 날짜
  /// - assessmentCount: int - 총 검사 횟수

  /// 검사 세션 컬렉션: assessments
  /// 
  /// 문서 ID: 자동 생성 ID
  /// 
  /// 필드:
  /// - childId: String - 아동 프로필 ID
  /// - parentId: String - 부모 사용자 UID
  /// - status: String - 'in_progress' | 'completed' | 'paused' | 'cancelled'
  /// - startedAt: Timestamp - 검사 시작 시간
  /// - completedAt: Timestamp? - 검사 완료 시간
  /// - pausedAt: Timestamp? - 일시 정지 시간
  /// - currentModule: String? - 현재 진행 중인 모듈
  /// - currentStep: int? - 현재 단계
  /// - modules: Map<String, ModuleProgress> - 모듈별 진행 상태
  /// 
  /// 하위 컬렉션:
  /// - responses: 검사 응답 데이터

  /// 검사 결과 컬렉션: assessment_results
  /// 
  /// 문서 ID: 자동 생성 ID
  /// 
  /// 필드:
  /// - assessmentId: String - 검사 세션 ID
  /// - childId: String - 아동 프로필 ID
  /// - parentId: String - 부모 사용자 UID
  /// - completedAt: Timestamp - 완료 시간
  /// - totalScore: int? - 총점
  /// - moduleScores: Map<String, ModuleScore> - 모듈별 점수
  /// - reportGeneratedAt: Timestamp? - 리포트 생성 시간

  /// 오디오 녹음 컬렉션: audio_recordings
  /// 
  /// 문서 ID: 자동 생성 ID
  /// 
  /// 필드:
  /// - assessmentId: String - 검사 세션 ID
  /// - childId: String - 아동 프로필 ID
  /// - module: String - 모듈 이름
  /// - step: String - 단계 이름
  /// - questionId: String - 문제 ID
  /// - storagePath: String - Firebase Storage 경로
  /// - duration: int? - 녹음 길이 (밀리초)
  /// - recordedAt: Timestamp - 녹음 시간
  /// - scoringStatus: String - 'pending' | 'scored' | 'failed'
  /// - score: int? - 채점 점수 (수동 채점 시)

  /// 채점 데이터 컬렉션: scores
  /// 
  /// 문서 ID: 자동 생성 ID
  /// 
  /// 필드:
  /// - assessmentId: String - 검사 세션 ID
  /// - childId: String - 아동 프로필 ID
  /// - module: String - 모듈 이름
  /// - questionId: String - 문제 ID
  /// - isCorrect: bool - 정답 여부
  /// - score: int - 점수
  /// - responseData: Map<String, dynamic> - 응답 데이터
  /// - scoredAt: Timestamp - 채점 시간
  /// - scoredBy: String? - 채점자 UID (수동 채점 시)
  /// - scoringMethod: String - 'auto' | 'manual'
}

/// 모듈 진행 상태
class ModuleProgress {
  final String module;
  final int currentStep;
  final int totalSteps;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;

  ModuleProgress({
    required this.module,
    required this.currentStep,
    required this.totalSteps,
    required this.isCompleted,
    this.startedAt,
    this.completedAt,
  });

  /// Firestore 문서에서 생성
  factory ModuleProgress.fromMap(Map<String, dynamic> map) {
    return ModuleProgress(
      module: map['module'] as String,
      currentStep: map['currentStep'] as int,
      totalSteps: map['totalSteps'] as int,
      isCompleted: map['isCompleted'] as bool,
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  /// Firestore 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'module': module,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'isCompleted': isCompleted,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Firestore Timestamp로 변환 (실제 사용 시)
  /// 
  /// Firestore에서는 Timestamp를 사용하므로, 실제 구현 시에는
  /// cloud_firestore의 Timestamp를 사용하세요:
  /// 
  /// ```dart
  /// import 'package:cloud_firestore/cloud_firestore.dart';
  /// 
  /// Map<String, dynamic> toFirestore() {
  ///   return {
  ///     'startedAt': startedAt != null 
  ///         ? Timestamp.fromDate(startedAt!) 
  ///         : null,
  ///     // ...
  ///   };
  /// }
  /// ```
}

/// 모듈 점수
class ModuleScore {
  final String module;
  final int score;
  final int maxScore;
  final double percentage;
  final Map<String, dynamic>? details;

  ModuleScore({
    required this.module,
    required this.score,
    required this.maxScore,
    required this.percentage,
    this.details,
  });

  /// Firestore 문서에서 생성
  factory ModuleScore.fromMap(Map<String, dynamic> map) {
    return ModuleScore(
      module: map['module'] as String,
      score: map['score'] as int,
      maxScore: map['maxScore'] as int,
      percentage: (map['percentage'] as num).toDouble(),
      details: map['details'] as Map<String, dynamic>?,
    );
  }

  /// Firestore 문서로 변환
  Map<String, dynamic> toMap() {
    return {
      'module': module,
      'score': score,
      'maxScore': maxScore,
      'percentage': percentage,
      'details': details,
    };
  }

  /// 백분율 계산
  static double calculatePercentage(int score, int maxScore) {
    if (maxScore == 0) return 0.0;
    return (score / maxScore) * 100;
  }
}

