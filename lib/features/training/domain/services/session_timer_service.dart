import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../data/models/learning_session_model.dart';

/// 세션 타이머 서비스
/// 
/// 15분 학습 제한 타이머 관리
class SessionTimerService extends ChangeNotifier {
  LearningSession? _currentSession;
  Timer? _timer;
  
  // 알림 콜백
  VoidCallback? onFiveMinutesLeft;
  VoidCallback? oneMinuteLeft;
  VoidCallback? onTimeUp;

  LearningSession? get currentSession => _currentSession;
  bool get isActive => _timer?.isActive ?? false;
  int get remainingSeconds => _currentSession?.remainingSeconds ?? 0;
  String get remainingTimeFormatted => _currentSession?.remainingTimeFormatted ?? '00:00';
  double get progress => _currentSession?.progress ?? 0.0;

  /// 세션 시작
  void startSession({
    required String childId,
    int durationMinutes = 15,
  }) {
    // 기존 세션 종료
    stopSession();

    _currentSession = LearningSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: childId,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
    );

    _startTimer();
    notifyListeners();
  }

  /// 세션 일시 정지
  void pauseSession() {
    _timer?.cancel();
    _currentSession = _currentSession?.copyWith(
      status: SessionStatus.paused,
    );
    notifyListeners();
  }

  /// 세션 재개
  void resumeSession() {
    if (_currentSession?.status == SessionStatus.paused) {
      _currentSession = _currentSession?.copyWith(
        status: SessionStatus.active,
      );
      _startTimer();
      notifyListeners();
    }
  }

  /// 세션 종료
  LearningSession? stopSession() {
    _timer?.cancel();
    final session = _currentSession?.copyWith(
      endTime: DateTime.now(),
      status: SessionStatus.completed,
    );
    _currentSession = null;
    notifyListeners();
    return session;
  }

  /// 문제 완료 기록
  void recordQuestionComplete({required bool isCorrect}) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      questionsCompleted: _currentSession!.questionsCompleted + 1,
      correctAnswers: isCorrect
          ? _currentSession!.correctAnswers + 1
          : _currentSession!.correctAnswers,
    );
    notifyListeners();
  }

  /// 모듈 완료 기록
  void recordModuleComplete(String moduleId) {
    if (_currentSession == null) return;

    final modules = List<String>.from(_currentSession!.completedModules);
    if (!modules.contains(moduleId)) {
      modules.add(moduleId);
      _currentSession = _currentSession!.copyWith(
        completedModules: modules,
      );
      notifyListeners();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_currentSession == null) {
      timer.cancel();
      return;
    }

    final newElapsed = _currentSession!.elapsedSeconds + 1;
    _currentSession = _currentSession!.copyWith(
      elapsedSeconds: newElapsed,
    );

    // 알림 체크
    if (_currentSession!.shouldNotify5Minutes) {
      onFiveMinutesLeft?.call();
    }
    if (_currentSession!.shouldNotify1Minute) {
      oneMinuteLeft?.call();
    }

    // 시간 종료 체크
    if (_currentSession!.isTimeUp) {
      _timer?.cancel();
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.timeUp,
        endTime: DateTime.now(),
      );
      onTimeUp?.call();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

