import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

/// 검사 진행 상태 Provider
/// 
/// 현재 진행 중인 검사의 상태를 관리합니다.
final assessmentStateProvider = StateNotifierProvider<AssessmentStateNotifier, AssessmentStateModel>((ref) {
  return AssessmentStateNotifier(ref);
});

/// 검사 진행 상태 Notifier
class AssessmentStateNotifier extends StateNotifier<AssessmentStateModel> {
  AssessmentStateNotifier(Ref ref) : super(AssessmentStateModel());

  /// 검사 시작
  void startAssessment({
    required String assessmentId,
    required String childId,
    String? module,
    int? step,
  }) {
    state = AssessmentStateModel(
      assessmentId: assessmentId,
      childId: childId,
      status: AssessmentStatus.inProgress,
      startedAt: DateTime.now(),
      currentModule: module,
      currentStep: step,
      progressData: {},
    );
  }

  /// 검사 진행 업데이트
  void updateProgress({
    String? module,
    int? step,
    Map<String, dynamic>? progressData,
  }) {
    state = state.copyWith(
      currentModule: module ?? state.currentModule,
      currentStep: step ?? state.currentStep,
      progressData: progressData ?? state.progressData,
    );
  }

  /// 검사 일시 정지
  void pauseAssessment() {
    if (state.status == AssessmentStatus.inProgress) {
      state = state.copyWith(
        status: AssessmentStatus.paused,
        pausedAt: DateTime.now(),
      );
    }
  }

  /// 검사 재개
  void resumeAssessment() {
    if (state.status == AssessmentStatus.paused) {
      // copyWith는 null을 명시적으로 설정할 수 없으므로 직접 새 객체 생성
      state = AssessmentStateModel(
        assessmentId: state.assessmentId,
        childId: state.childId,
        status: AssessmentStatus.inProgress,
        startedAt: state.startedAt,
        completedAt: state.completedAt,
        pausedAt: null, // 명시적으로 null 설정
        currentModule: state.currentModule,
        currentStep: state.currentStep,
        progressData: state.progressData,
      );
    }
  }

  /// 검사 완료
  void completeAssessment() {
    state = state.copyWith(
      status: AssessmentStatus.completed,
      completedAt: DateTime.now(),
    );
  }

  /// 검사 취소
  void cancelAssessment() {
    state = state.copyWith(
      status: AssessmentStatus.cancelled,
      completedAt: DateTime.now(),
    );
  }

  /// 검사 상태 초기화
  void resetAssessment() {
    state = AssessmentStateModel();
  }
}

