import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/stt_result_model.dart';

/// STT (Speech-to-Text) 서비스
/// 
/// 음성을 텍스트로 변환하는 서비스
/// 현재는 시뮬레이션 모드로 동작하며, 
/// 실제 Google Cloud Speech / Naver Clova 연동 시 확장 가능
abstract class SttService {
  /// 오디오 파일을 텍스트로 변환
  Future<SttResult> transcribeAudio(String audioPath);

  /// 실시간 음성 인식 시작
  Stream<SttResult> startRealtimeRecognition();

  /// 실시간 음성 인식 중지
  Future<void> stopRealtimeRecognition();

  /// 발음 점수 분석
  Future<PronunciationScore> analyzePronunciation(
    String audioPath,
    String expectedText,
  );
}

/// 시뮬레이션 STT 서비스
/// 
/// 실제 STT API 없이 개발/테스트용으로 사용
class SimulatedSttService implements SttService {
  final Random _random = Random();
  StreamController<SttResult>? _realtimeController;
  Timer? _realtimeTimer;
  bool _isRecognizing = false;

  // 시뮬레이션용 단어 사전
  static const Map<String, List<String>> _simulatedResponses = {
    'default': ['사과', '나비', '바나나', '코끼리', '강아지'],
    'numbers': ['일', '이', '삼', '사', '오', '육', '칠', '팔', '구', '십'],
    'syllables': ['가', '나', '다', '라', '마', '바', '사', '아', '자', '차'],
  };

  @override
  Future<SttResult> transcribeAudio(String audioPath) async {
    // 실제 처리 시간 시뮬레이션
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // 랜덤 텍스트 생성
    final words = _simulatedResponses['default']!;
    final transcript = words[_random.nextInt(words.length)];

    // 신뢰도 시뮬레이션 (0.6 ~ 1.0)
    final confidence = 0.6 + (_random.nextDouble() * 0.4);

    // 단어별 상세 정보 생성
    final wordDetails = _generateWordDetails(transcript, confidence);

    debugPrint('🎤 STT 시뮬레이션: "$transcript" (신뢰도: ${(confidence * 100).toStringAsFixed(1)}%)');

    return SttResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transcript: transcript,
      confidence: confidence,
      words: wordDetails,
      durationMs: 1000 + _random.nextInt(2000),
      processedAt: DateTime.now(),
    );
  }

  @override
  Stream<SttResult> startRealtimeRecognition() {
    _realtimeController?.close();
    _realtimeController = StreamController<SttResult>();
    _isRecognizing = true;

    // 주기적으로 실시간 인식 결과 시뮬레이션
    _realtimeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isRecognizing) {
        timer.cancel();
        return;
      }

      final words = _simulatedResponses['default']!;
      final transcript = words[_random.nextInt(words.length)];
      final confidence = 0.7 + (_random.nextDouble() * 0.3);

      _realtimeController?.add(SttResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transcript: transcript,
        confidence: confidence,
        processedAt: DateTime.now(),
      ));
    });

    return _realtimeController!.stream;
  }

  @override
  Future<void> stopRealtimeRecognition() async {
    _isRecognizing = false;
    _realtimeTimer?.cancel();
    await _realtimeController?.close();
    _realtimeController = null;
  }

  @override
  Future<PronunciationScore> analyzePronunciation(
    String audioPath,
    String expectedText,
  ) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    // 음소 분석 시뮬레이션
    final phonemes = _extractPhonemes(expectedText);
    final phonemeScores = phonemes.map((phoneme) {
      final score = 60 + _random.nextInt(41); // 60-100
      return PhonemeScore(
        phoneme: phoneme,
        score: score,
        feedback: score < 70 ? _getPhoneFeedback(phoneme) : null,
      );
    }).toList();

    // 전체 점수 계산
    final overallScore = phonemeScores.isEmpty
        ? 80
        : (phonemeScores.map((p) => p.score).reduce((a, b) => a + b) /
                phonemeScores.length)
            .round();

    return PronunciationScore(
      overallScore: overallScore,
      accuracyScore: overallScore - 5 + _random.nextInt(11),
      fluencyScore: overallScore - 5 + _random.nextInt(11),
      completenessScore: overallScore - 5 + _random.nextInt(11),
      phonemes: phonemeScores,
    );
  }

  List<WordDetail> _generateWordDetails(String transcript, double baseConfidence) {
    final syllables = transcript.split('');
    final details = <WordDetail>[];
    int currentTime = 0;

    for (int i = 0; i < syllables.length; i++) {
      final duration = 200 + _random.nextInt(300);
      final confidence = baseConfidence - 0.1 + (_random.nextDouble() * 0.2);

      details.add(WordDetail(
        word: syllables[i],
        confidence: confidence.clamp(0.0, 1.0),
        startTimeMs: currentTime,
        endTimeMs: currentTime + duration,
      ));

      currentTime += duration;
    }

    return details;
  }

  List<String> _extractPhonemes(String text) {
    // 한글 초성, 중성, 종성 분리 (간소화된 버전)
    final phonemes = <String>[];
    
    for (final char in text.runes) {
      if (char >= 0xAC00 && char <= 0xD7A3) {
        // 한글 음절
        final syllableIndex = char - 0xAC00;
        final cho = syllableIndex ~/ 588;
        final jung = (syllableIndex % 588) ~/ 28;
        final jong = syllableIndex % 28;

        phonemes.add(_chosung[cho]);
        phonemes.add(_jungsung[jung]);
        if (jong > 0) {
          phonemes.add(_jongsung[jong]);
        }
      }
    }

    return phonemes;
  }

  String _getPhoneFeedback(String phoneme) {
    final feedbacks = {
      'ㄱ': "'ㄱ' 소리를 조금 더 세게 내봐요!",
      'ㄴ': "'ㄴ' 소리가 살짝 약해요. 혀를 윗잇몸에 붙여봐요!",
      'ㄷ': "'ㄷ' 소리를 좀 더 또렷하게!",
      'ㄹ': "'ㄹ' 소리가 어려워요. 천천히 해봐요!",
      'ㅁ': "'ㅁ' 소리, 입술을 꼭 붙였다 떼봐요!",
      'ㅂ': "'ㅂ' 소리를 조금 더 힘차게!",
      'ㅅ': "'ㅅ' 소리가 살짝 흐려요. 이 사이로 바람을 내봐요!",
      'ㅇ': "좋아요! 잘하고 있어요!",
      'ㅈ': "'ㅈ' 소리를 또렷하게!",
      'ㅊ': "'ㅊ' 소리에 바람을 더 넣어봐요!",
      'ㅋ': "'ㅋ' 소리를 더 힘차게!",
      'ㅌ': "'ㅌ' 소리에 바람을 넣어봐요!",
      'ㅍ': "'ㅍ' 소리를 더 강하게!",
      'ㅎ': "'ㅎ' 소리, 바람을 내봐요!",
    };
    return feedbacks[phoneme] ?? "조금 더 연습해봐요!";
  }

  static const _chosung = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];
  
  static const _jungsung = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'
  ];
  
  static const _jongsung = [
    '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
  ];
}

/// 자동 채점 서비스
/// 
/// STT 결과를 기반으로 자동 채점을 수행
class AutoScoringService {
  final SttService _sttService;

  AutoScoringService(this._sttService);

  /// 자동 채점 수행
  Future<AutoScoringResult> scoreAnswer({
    required String questionId,
    required String audioPath,
    required String expectedAnswer,
    double autoApproveThreshold = 0.85,
  }) async {
    // STT로 음성 인식
    final sttResult = await _sttService.transcribeAudio(audioPath);

    // 정답과 비교
    final matchScore = _calculateMatchScore(
      sttResult.transcript,
      expectedAnswer,
    );

    // 최종 신뢰도 = STT 신뢰도 × 매칭 점수
    final finalConfidence = sttResult.confidence * matchScore;

    // 채점 결정
    AutoScoringDecision decision;
    String? reason;

    if (finalConfidence >= autoApproveThreshold && matchScore >= 0.9) {
      decision = AutoScoringDecision.autoCorrect;
      reason = '높은 신뢰도로 정답 자동 처리';
    } else if (finalConfidence < 0.5 && matchScore < 0.5) {
      decision = AutoScoringDecision.autoIncorrect;
      reason = '낮은 일치율로 오답 자동 처리';
    } else {
      decision = AutoScoringDecision.manualReview;
      reason = '신뢰도가 애매하여 수동 검토 필요';
    }

    debugPrint('📝 자동 채점: ${sttResult.transcript} vs $expectedAnswer');
    debugPrint('   매칭: ${(matchScore * 100).toStringAsFixed(1)}%, 결정: ${decision.name}');

    return AutoScoringResult(
      questionId: questionId,
      expectedAnswer: expectedAnswer,
      sttResult: sttResult,
      isMatch: matchScore >= 0.9,
      matchScore: matchScore,
      decision: decision,
      reason: reason,
    );
  }

  /// 문자열 매칭 점수 계산 (0.0 ~ 1.0)
  double _calculateMatchScore(String recognized, String expected) {
    // 정규화: 공백 제거, 소문자 변환
    final normalizedRecognized = recognized.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final normalizedExpected = expected.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    if (normalizedRecognized == normalizedExpected) {
      return 1.0;
    }

    if (normalizedRecognized.isEmpty || normalizedExpected.isEmpty) {
      return 0.0;
    }

    // Levenshtein 거리 기반 유사도
    final distance = _levenshteinDistance(normalizedRecognized, normalizedExpected);
    final maxLength = max(normalizedRecognized.length, normalizedExpected.length);
    
    return 1.0 - (distance / maxLength);
  }

  /// Levenshtein 거리 계산
  int _levenshteinDistance(String s1, String s2) {
    final m = s1.length;
    final n = s2.length;

    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 + [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]].reduce(min);
        }
      }
    }

    return dp[m][n];
  }
}

