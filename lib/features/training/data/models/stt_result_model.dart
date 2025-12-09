/// STT 결과 모델
/// 
/// Speech-to-Text 변환 결과를 저장
class SttResult {
  final String id;
  final String transcript;           // 인식된 텍스트
  final double confidence;            // 신뢰도 (0.0 ~ 1.0)
  final List<WordDetail> words;       // 단어별 상세 정보
  final int durationMs;               // 음성 길이 (밀리초)
  final String languageCode;          // 언어 코드
  final DateTime processedAt;         // 처리 시간
  final SttStatus status;

  SttResult({
    required this.id,
    required this.transcript,
    required this.confidence,
    this.words = const [],
    this.durationMs = 0,
    this.languageCode = 'ko-KR',
    required this.processedAt,
    this.status = SttStatus.completed,
  });

  SttResult copyWith({
    String? id,
    String? transcript,
    double? confidence,
    List<WordDetail>? words,
    int? durationMs,
    String? languageCode,
    DateTime? processedAt,
    SttStatus? status,
  }) {
    return SttResult(
      id: id ?? this.id,
      transcript: transcript ?? this.transcript,
      confidence: confidence ?? this.confidence,
      words: words ?? this.words,
      durationMs: durationMs ?? this.durationMs,
      languageCode: languageCode ?? this.languageCode,
      processedAt: processedAt ?? this.processedAt,
      status: status ?? this.status,
    );
  }

  /// 신뢰도가 높은지 여부 (90% 이상)
  bool get isHighConfidence => confidence >= 0.9;

  /// 신뢰도가 낮은지 여부 (70% 미만)
  bool get isLowConfidence => confidence < 0.7;

  /// 수동 확인이 필요한지 여부
  bool get needsManualReview => confidence < 0.85;

  /// 신뢰도 레벨
  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.9) return ConfidenceLevel.high;
    if (confidence >= 0.7) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  /// 신뢰도를 퍼센트로 반환
  int get confidencePercent => (confidence * 100).round();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transcript': transcript,
      'confidence': confidence,
      'words': words.map((w) => w.toJson()).toList(),
      'durationMs': durationMs,
      'languageCode': languageCode,
      'processedAt': processedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory SttResult.fromJson(Map<String, dynamic> json) {
    return SttResult(
      id: json['id'] as String,
      transcript: json['transcript'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      words: (json['words'] as List<dynamic>?)
              ?.map((w) => WordDetail.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      durationMs: json['durationMs'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'ko-KR',
      processedAt: DateTime.parse(json['processedAt'] as String),
      status: SttStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SttStatus.completed,
      ),
    );
  }

  /// 빈 결과 생성
  factory SttResult.empty() {
    return SttResult(
      id: '',
      transcript: '',
      confidence: 0.0,
      processedAt: DateTime.now(),
      status: SttStatus.failed,
    );
  }
}

/// 단어별 상세 정보
class WordDetail {
  final String word;
  final double confidence;
  final int startTimeMs;
  final int endTimeMs;
  final PronunciationScore? pronunciation;

  WordDetail({
    required this.word,
    required this.confidence,
    this.startTimeMs = 0,
    this.endTimeMs = 0,
    this.pronunciation,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'confidence': confidence,
      'startTimeMs': startTimeMs,
      'endTimeMs': endTimeMs,
      'pronunciation': pronunciation?.toJson(),
    };
  }

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      word: json['word'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      startTimeMs: json['startTimeMs'] as int? ?? 0,
      endTimeMs: json['endTimeMs'] as int? ?? 0,
      pronunciation: json['pronunciation'] != null
          ? PronunciationScore.fromJson(
              json['pronunciation'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 발음 점수
class PronunciationScore {
  final int overallScore;          // 전체 점수 (0-100)
  final int accuracyScore;         // 정확도 점수
  final int fluencyScore;          // 유창성 점수
  final int completenessScore;     // 완전성 점수
  final List<PhonemeScore> phonemes; // 음소별 점수

  PronunciationScore({
    required this.overallScore,
    this.accuracyScore = 0,
    this.fluencyScore = 0,
    this.completenessScore = 0,
    this.phonemes = const [],
  });

  /// 발음이 좋은지 여부 (70점 이상)
  bool get isGood => overallScore >= 70;

  /// 피드백이 필요한 음소 목록
  List<PhonemeScore> get needsFeedbackPhonemes =>
      phonemes.where((p) => p.score < 70).toList();

  Map<String, dynamic> toJson() {
    return {
      'overallScore': overallScore,
      'accuracyScore': accuracyScore,
      'fluencyScore': fluencyScore,
      'completenessScore': completenessScore,
      'phonemes': phonemes.map((p) => p.toJson()).toList(),
    };
  }

  factory PronunciationScore.fromJson(Map<String, dynamic> json) {
    return PronunciationScore(
      overallScore: json['overallScore'] as int,
      accuracyScore: json['accuracyScore'] as int? ?? 0,
      fluencyScore: json['fluencyScore'] as int? ?? 0,
      completenessScore: json['completenessScore'] as int? ?? 0,
      phonemes: (json['phonemes'] as List<dynamic>?)
              ?.map((p) => PhonemeScore.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 음소별 점수
class PhonemeScore {
  final String phoneme;    // 음소 (예: 'ㄱ', 'ㅏ')
  final int score;         // 점수 (0-100)
  final String? feedback;  // 피드백 메시지

  PhonemeScore({
    required this.phoneme,
    required this.score,
    this.feedback,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneme': phoneme,
      'score': score,
      'feedback': feedback,
    };
  }

  factory PhonemeScore.fromJson(Map<String, dynamic> json) {
    return PhonemeScore(
      phoneme: json['phoneme'] as String,
      score: json['score'] as int,
      feedback: json['feedback'] as String?,
    );
  }
}

enum SttStatus {
  processing,  // 처리 중
  completed,   // 완료
  failed,      // 실패
  timeout,     // 시간 초과
}

enum ConfidenceLevel {
  high,    // 90% 이상
  medium,  // 70-90%
  low,     // 70% 미만
}

/// 자동 채점 결과
class AutoScoringResult {
  final String questionId;
  final String expectedAnswer;
  final SttResult sttResult;
  final bool isMatch;
  final double matchScore;
  final AutoScoringDecision decision;
  final String? reason;

  AutoScoringResult({
    required this.questionId,
    required this.expectedAnswer,
    required this.sttResult,
    required this.isMatch,
    required this.matchScore,
    required this.decision,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'expectedAnswer': expectedAnswer,
      'sttResult': sttResult.toJson(),
      'isMatch': isMatch,
      'matchScore': matchScore,
      'decision': decision.name,
      'reason': reason,
    };
  }
}

enum AutoScoringDecision {
  autoCorrect,     // 자동 정답 처리
  autoIncorrect,   // 자동 오답 처리
  manualReview,    // 수동 검토 필요
}

