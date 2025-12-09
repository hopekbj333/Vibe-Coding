import '../../data/models/difficulty_params_model.dart';
import '../../data/models/game_session_model.dart';

/// 동적 난이도 조절 엔진
/// 
/// 아이의 최근 수행 결과를 기반으로 난이도를 자동으로 조절합니다.
/// Milestone 2 - WP 2.1 (S 2.1.4)
class DifficultyAdjuster {
  /// 최근 N문제를 기준으로 난이도 조절
  static const int _windowSize = 5;

  /// 상향 조정 임계값 (정답률)
  static const double _increaseThreshold = 0.8; // 80% 이상

  /// 하향 조정 임계값 (정답률)
  static const double _decreaseThreshold = 0.4; // 40% 이하

  /// 연속 오답 허용 횟수 (Frustration-Free)
  static const int _maxConsecutiveWrong = 3;

  /// 최근 정답 내역을 추적하는 큐
  final List<bool> _recentAnswers = [];

  /// 연속 오답 카운터
  int _consecutiveWrongCount = 0;

  /// 현재 난이도 파라미터
  DifficultyParams _currentParams;

  DifficultyAdjuster({
    DifficultyParams? initialDifficulty,
  }) : _currentParams = initialDifficulty ?? DifficultyPresets.easy;

  /// 현재 난이도 파라미터
  DifficultyParams get currentParams => _currentParams;

  /// 최근 정답률
  double get recentAccuracy {
    if (_recentAnswers.isEmpty) return 0.0;
    final correctCount = _recentAnswers.where((x) => x).length;
    return correctCount / _recentAnswers.length;
  }

  /// 연속 오답 횟수
  int get consecutiveWrongCount => _consecutiveWrongCount;

  /// 정답/오답 기록 및 난이도 조정
  /// 
  /// [isCorrect]: 정답 여부
  /// 반환: 난이도가 변경되었으면 true
  bool recordAnswer(bool isCorrect) {
    // 최근 답안에 추가
    _recentAnswers.add(isCorrect);
    if (_recentAnswers.length > _windowSize) {
      _recentAnswers.removeAt(0);
    }

    // 연속 오답 카운터 업데이트
    if (isCorrect) {
      _consecutiveWrongCount = 0;
    } else {
      _consecutiveWrongCount++;
    }

    // 난이도 조정 필요 여부 확인
    return _adjustIfNeeded();
  }

  /// 난이도 조정이 필요한지 확인하고 실행
  bool _adjustIfNeeded() {
    // 1. 좌절 방지: 연속 3번 오답 시 무조건 하향
    if (_consecutiveWrongCount >= _maxConsecutiveWrong) {
      if (_currentParams.level > 1) {
        _decreaseDifficulty();
        _consecutiveWrongCount = 0; // 카운터 리셋
        return true;
      }
    }

    // 2. 충분한 데이터가 모일 때까지 대기
    if (_recentAnswers.length < _windowSize) {
      return false;
    }

    // 3. 정답률 기반 조정
    final accuracy = recentAccuracy;

    if (accuracy >= _increaseThreshold) {
      // 80% 이상: 난이도 상향
      if (_currentParams.level < 5) {
        _increaseDifficulty();
        _clearRecentAnswers(); // 조정 후 기록 초기화
        return true;
      }
    } else if (accuracy <= _decreaseThreshold) {
      // 40% 이하: 난이도 하향
      if (_currentParams.level > 1) {
        _decreaseDifficulty();
        _clearRecentAnswers(); // 조정 후 기록 초기화
        return true;
      }
    }

    return false;
  }

  /// 난이도 상향
  void _increaseDifficulty() {
    _currentParams = _currentParams.harder();
  }

  /// 난이도 하향
  void _decreaseDifficulty() {
    _currentParams = _currentParams.easier();
  }

  /// 최근 답안 기록 초기화
  void _clearRecentAnswers() {
    _recentAnswers.clear();
  }

  /// 수동으로 난이도 설정
  void setDifficulty(int level) {
    _currentParams = DifficultyPresets.fromLevel(level);
    _clearRecentAnswers();
    _consecutiveWrongCount = 0;
  }

  /// 특정 파라미터만 조정
  void adjustParams({
    int? timeLimit,
    int? optionCount,
    double? gameSpeed,
    int? hintCount,
  }) {
    _currentParams = _currentParams.adjust(
      timeLimit: timeLimit,
      optionCount: optionCount,
      gameSpeed: gameSpeed,
      hintCount: hintCount,
    );
  }

  /// 세션 기반 난이도 조정
  /// 
  /// 게임 세션 정보를 받아서 난이도를 조정합니다.
  DifficultyParams adjustFromSession(GameSessionModel session) {
    final accuracy = session.accuracy;

    // 정답률이 매우 높으면 상향
    if (accuracy >= 0.85 && session.currentDifficultyLevel < 5) {
      return DifficultyPresets.fromLevel(session.currentDifficultyLevel + 1);
    }
    // 정답률이 매우 낮으면 하향
    else if (accuracy <= 0.35 && session.currentDifficultyLevel > 1) {
      return DifficultyPresets.fromLevel(session.currentDifficultyLevel - 1);
    }

    // 변경 없음
    return DifficultyPresets.fromLevel(session.currentDifficultyLevel);
  }

  /// 리셋 (새 게임 시작 시)
  void reset({DifficultyParams? newDifficulty}) {
    _recentAnswers.clear();
    _consecutiveWrongCount = 0;
    if (newDifficulty != null) {
      _currentParams = newDifficulty;
    }
  }

  /// 디버그 정보
  String getDebugInfo() {
    return '''
=== 난이도 조절 엔진 ===
현재 레벨: ${_currentParams.level} (${_currentParams.levelName})
최근 정답률: ${(recentAccuracy * 100).toStringAsFixed(1)}%
연속 오답: $_consecutiveWrongCount회
최근 답안: ${_recentAnswers.map((x) => x ? 'O' : 'X').join(' ')}
제한 시간: ${_currentParams.timeLimit}초
보기 개수: ${_currentParams.optionCount}개
게임 속도: ${_currentParams.gameSpeed}x
''';
  }
}

/// 난이도 조절 전략
/// 
/// 게임 타입별로 다른 조절 전략을 사용할 수 있습니다.
enum AdjustmentStrategy {
  standard,    // 표준: 정답률 기반
  aggressive,  // 공격적: 빠른 난이도 변화
  conservative,// 보수적: 느린 난이도 변화
  adaptive,    // 적응형: 아이의 학습 패턴에 따라
}

/// 전략별 난이도 조절기 팩토리
class DifficultyAdjusterFactory {
  static DifficultyAdjuster create({
    AdjustmentStrategy strategy = AdjustmentStrategy.standard,
    DifficultyParams? initialDifficulty,
  }) {
    // 현재는 표준 전략만 구현
    // 향후 전략별로 다른 조절기를 반환할 수 있습니다
    return DifficultyAdjuster(initialDifficulty: initialDifficulty);
  }
}

