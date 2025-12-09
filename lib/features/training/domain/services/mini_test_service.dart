import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../data/models/mini_test_model.dart';

/// 미니 테스트 서비스
/// 
/// 학습 영역별 미니 테스트 생성 및 결과 관리
class MiniTestService extends ChangeNotifier {
  MiniTest? _currentTest;
  List<MiniTestResult> _testResults = [];
  final Map<String, int> _previousScores = {}; // moduleId -> 이전 점수

  MiniTest? get currentTest => _currentTest;
  List<MiniTestResult> get testResults => List.unmodifiable(_testResults);

  /// 이전 점수 설정 (검사 결과 연동)
  void setPreviousScore(String moduleId, int score) {
    _previousScores[moduleId] = score;
    notifyListeners();
  }

  /// 미니 테스트 생성
  MiniTest generateMiniTest({
    required String childId,
    required String moduleId,
    required String moduleName,
    int questionCount = 5,
  }) {
    final questions = _generateQuestions(moduleId, questionCount);

    _currentTest = MiniTest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: childId,
      moduleId: moduleId,
      moduleName: moduleName,
      questions: questions,
      totalQuestions: questionCount,
      createdAt: DateTime.now(),
      status: MiniTestStatus.pending,
    );

    notifyListeners();
    return _currentTest!;
  }

  /// 테스트 시작
  void startTest() {
    if (_currentTest == null) return;

    _currentTest = _currentTest!.copyWith(
      status: MiniTestStatus.inProgress,
    );
    notifyListeners();
  }

  /// 문항 응답 제출
  void submitAnswer({
    required int questionIndex,
    required dynamic answer,
    required int responseTimeMs,
  }) {
    if (_currentTest == null) return;
    if (questionIndex >= _currentTest!.questions.length) return;

    final questions = List<MiniTestQuestion>.from(_currentTest!.questions);
    final question = questions[questionIndex];
    
    final isCorrect = _checkAnswer(question.correctAnswer, answer);
    
    questions[questionIndex] = question.copyWith(
      userAnswer: answer,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    _currentTest = _currentTest!.copyWith(questions: questions);
    notifyListeners();
  }

  /// 테스트 완료
  MiniTestResult completeTest() {
    if (_currentTest == null) {
      throw Exception('No active test');
    }

    final test = _currentTest!;
    final score = test.score;
    final previousScore = _previousScores[test.moduleId] ?? 50; // 기본값 50
    final improvement = score - previousScore;
    final isPassed = score >= 80;

    _currentTest = test.copyWith(
      completedAt: DateTime.now(),
      status: isPassed ? MiniTestStatus.passed : MiniTestStatus.failed,
    );

    final result = MiniTestResult(
      testId: test.id,
      childId: test.childId,
      moduleId: test.moduleId,
      moduleName: test.moduleName,
      currentScore: score,
      previousScore: previousScore,
      improvement: improvement,
      isPassed: isPassed,
      completedAt: DateTime.now(),
      recommendation: _generateRecommendation(score, improvement, isPassed),
    );

    _testResults.add(result);
    
    // 현재 점수를 이전 점수로 저장
    _previousScores[test.moduleId] = score;

    notifyListeners();
    return result;
  }

  /// 이전 점수 가져오기
  int? getPreviousScore(String moduleId) {
    return _previousScores[moduleId];
  }

  /// 테스트 결과 히스토리 가져오기
  List<MiniTestResult> getResultsForModule(String moduleId) {
    return _testResults.where((r) => r.moduleId == moduleId).toList();
  }

  /// 현재 테스트 초기화
  void resetCurrentTest() {
    _currentTest = null;
    notifyListeners();
  }

  // 문항 생성 (모듈별)
  List<MiniTestQuestion> _generateQuestions(String moduleId, int count) {
    final random = Random();
    
    // 모듈별 문항 풀
    final questionPool = _getQuestionPool(moduleId);
    
    // 랜덤 선택
    questionPool.shuffle(random);
    return questionPool.take(count).toList();
  }

  List<MiniTestQuestion> _getQuestionPool(String moduleId) {
    switch (moduleId) {
      case 'phonological1':
        return _phonological1Questions();
      case 'phonological2':
        return _phonological2Questions();
      case 'phonological3':
        return _phonological3Questions();
      default:
        return _defaultQuestions();
    }
  }

  List<MiniTestQuestion> _phonological1Questions() {
    return [
      MiniTestQuestion(
        id: 'p1_q1',
        questionType: 'same_sound',
        questionText: '같은 소리를 찾으세요',
        options: ['가', '나', '가', '다'],
        correctAnswer: 2,
      ),
      MiniTestQuestion(
        id: 'p1_q2',
        questionType: 'different_sound',
        questionText: '다른 소리를 찾으세요',
        options: ['바', '바', '파', '바'],
        correctAnswer: 2,
      ),
      MiniTestQuestion(
        id: 'p1_q3',
        questionType: 'rhythm',
        questionText: '같은 리듬을 찾으세요',
        options: ['짧-짧', '길-짧', '짧-긴', '길-길'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p1_q4',
        questionType: 'tempo',
        questionText: '더 빠른 것은?',
        options: ['느림', '빠름'],
        correctAnswer: 1,
      ),
      MiniTestQuestion(
        id: 'p1_q5',
        questionType: 'emotion',
        questionText: '기쁜 목소리를 찾으세요',
        options: ['😊', '😢', '😠'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p1_q6',
        questionType: 'same_sound',
        questionText: '같은 소리를 찾으세요',
        options: ['마', '바', '마', '사'],
        correctAnswer: 2,
      ),
    ];
  }

  List<MiniTestQuestion> _phonological2Questions() {
    return [
      MiniTestQuestion(
        id: 'p2_q1',
        questionType: 'word_count',
        questionText: '"엄마 사과 먹어요"에서 단어는 몇 개?',
        options: ['2개', '3개', '4개', '5개'],
        correctAnswer: 1,
      ),
      MiniTestQuestion(
        id: 'p2_q2',
        questionType: 'alliteration',
        questionText: '"사과"와 같은 소리로 시작하는 것은?',
        options: ['사탕', '바나나', '포도'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p2_q3',
        questionType: 'rhyme',
        questionText: '"토끼"와 끝소리가 같은 것은?',
        options: ['나비', '강아지', '고양이'],
        correctAnswer: 2,
      ),
      MiniTestQuestion(
        id: 'p2_q4',
        questionType: 'word_chain',
        questionText: '"나비"의 끝 글자로 시작하는 것은?',
        options: ['비행기', '나무', '토끼'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p2_q5',
        questionType: 'word_boundary',
        questionText: '"사과바나나"를 나누면?',
        options: ['사과|바나나', '사|과바나나', '사과바|나나'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p2_q6',
        questionType: 'alliteration',
        questionText: '"고양이"와 같은 소리로 시작하는 것은?',
        options: ['고구마', '바나나', '사과'],
        correctAnswer: 0,
      ),
    ];
  }

  List<MiniTestQuestion> _phonological3Questions() {
    return [
      MiniTestQuestion(
        id: 'p3_q1',
        questionType: 'syllable_count',
        questionText: '"나비"는 몇 음절?',
        options: ['1개', '2개', '3개'],
        correctAnswer: 1,
      ),
      MiniTestQuestion(
        id: 'p3_q2',
        questionType: 'syllable_split',
        questionText: '"사과"를 쪼개면?',
        options: ['사+과', 'ㅅㅏ+ㄱㅗㅏ', 'ㅅ+ㅏㄱㅗㅏ'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p3_q3',
        questionType: 'syllable_merge',
        questionText: '"바"+"나"+"나"를 합치면?',
        options: ['바나나', '바나', '나바나'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p3_q4',
        questionType: 'syllable_drop',
        questionText: '"사과"에서 "과"를 빼면?',
        options: ['사', '과', '사과'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p3_q5',
        questionType: 'syllable_reverse',
        questionText: '"나비"를 거꾸로 하면?',
        options: ['비나', '나비', '바니'],
        correctAnswer: 0,
      ),
      MiniTestQuestion(
        id: 'p3_q6',
        questionType: 'syllable_replace',
        questionText: '"바나나"의 "바"를 "사"로 바꾸면?',
        options: ['사나나', '바사나', '나사바'],
        correctAnswer: 0,
      ),
    ];
  }

  List<MiniTestQuestion> _defaultQuestions() {
    return _phonological1Questions();
  }

  bool _checkAnswer(dynamic correctAnswer, dynamic userAnswer) {
    return correctAnswer == userAnswer;
  }

  String _generateRecommendation(int score, int improvement, bool isPassed) {
    if (isPassed) {
      if (improvement > 20) {
        return '🎉 대단해요! $improvement점이나 올랐어요! 다음 단계로 도전해보세요!';
      } else if (improvement > 0) {
        return '👏 잘했어요! 꾸준히 실력이 늘고 있어요!';
      } else {
        return '✨ 통과! 이미 잘하고 있어요!';
      }
    } else {
      if (improvement > 0) {
        return '💪 점점 나아지고 있어요! 조금만 더 연습하면 통과할 수 있어요!';
      } else {
        return '🌟 괜찮아요! 더 연습하고 다시 도전해봐요!';
      }
    }
  }
}

/// 단계 승급 서비스
class StagePromotionService extends ChangeNotifier {
  final Map<String, bool> _unlockedStages = {
    'phonological1': true,
    'phonological2': false,
    'phonological3': false,
  };

  int _promotionThreshold = 80; // 승급 기준 (기본 80점)

  int get promotionThreshold => _promotionThreshold;

  /// 승급 기준 설정 (부모 설정)
  void setPromotionThreshold(int threshold) {
    _promotionThreshold = threshold.clamp(70, 90);
    notifyListeners();
  }

  /// 단계 잠금 해제 여부
  bool isStageUnlocked(String stageId) {
    return _unlockedStages[stageId] ?? false;
  }

  /// 승급 판정
  PromotionResult checkPromotion({
    required String currentStageId,
    required int testScore,
  }) {
    final nextStageId = _getNextStageId(currentStageId);
    
    if (nextStageId == null) {
      return PromotionResult(
        currentStageId: currentStageId,
        nextStageId: null,
        testScore: testScore,
        threshold: _promotionThreshold,
        isPassed: testScore >= _promotionThreshold,
        isPromoted: false,
        message: '🏆 마지막 단계를 완료했어요!',
      );
    }

    final isPassed = testScore >= _promotionThreshold;
    
    if (isPassed) {
      _unlockedStages[nextStageId] = true;
      notifyListeners();

      return PromotionResult(
        currentStageId: currentStageId,
        nextStageId: nextStageId,
        testScore: testScore,
        threshold: _promotionThreshold,
        isPassed: true,
        isPromoted: true,
        message: '🎉 축하해요! 다음 단계가 열렸어요!',
      );
    } else {
      final gap = _promotionThreshold - testScore;
      return PromotionResult(
        currentStageId: currentStageId,
        nextStageId: nextStageId,
        testScore: testScore,
        threshold: _promotionThreshold,
        isPassed: false,
        isPromoted: false,
        message: '💪 $gap점만 더 올리면 다음 단계로 갈 수 있어요!',
        retryRecommendation: '3일 더 연습하고 다시 도전해봐요!',
      );
    }
  }

  String? _getNextStageId(String currentStageId) {
    const stageOrder = ['phonological1', 'phonological2', 'phonological3'];
    final currentIndex = stageOrder.indexOf(currentStageId);
    
    if (currentIndex < 0 || currentIndex >= stageOrder.length - 1) {
      return null;
    }
    
    return stageOrder[currentIndex + 1];
  }

  /// 단계 강제 잠금 해제 (개발/테스트용)
  void forceUnlock(String stageId) {
    _unlockedStages[stageId] = true;
    notifyListeners();
  }
}

/// 승급 판정 결과
class PromotionResult {
  final String currentStageId;
  final String? nextStageId;
  final int testScore;
  final int threshold;
  final bool isPassed;
  final bool isPromoted;
  final String message;
  final String? retryRecommendation;

  PromotionResult({
    required this.currentStageId,
    required this.nextStageId,
    required this.testScore,
    required this.threshold,
    required this.isPassed,
    required this.isPromoted,
    required this.message,
    this.retryRecommendation,
  });
}

