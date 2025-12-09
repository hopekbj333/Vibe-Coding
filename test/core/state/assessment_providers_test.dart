import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:literacy_assessment/core/state/app_state.dart';
import 'package:literacy_assessment/core/state/assessment_providers.dart';

void main() {
  group('AssessmentStateProvider 테스트', () {
    test('초기 상태는 비어있어야 함', () {
      final container = ProviderContainer();
      final state = container.read(assessmentStateProvider);
      
      expect(state.assessmentId, isNull);
      expect(state.childId, isNull);
      expect(state.status, AssessmentStatus.inProgress);
      expect(state.isInProgress, isTrue);
      expect(state.isCompleted, isFalse);
      expect(state.isPaused, isFalse);
    });

    test('검사 시작이 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
        module: 'phonological',
        step: 1,
      );
      
      final state = container.read(assessmentStateProvider);
      expect(state.assessmentId, 'test-assessment-123');
      expect(state.childId, 'test-child-456');
      expect(state.currentModule, 'phonological');
      expect(state.currentStep, 1);
      expect(state.status, AssessmentStatus.inProgress);
      expect(state.startedAt, isNotNull);
    });

    test('검사 일시 정지가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
      );
      
      notifier.pauseAssessment();
      
      final state = container.read(assessmentStateProvider);
      expect(state.status, AssessmentStatus.paused);
      expect(state.isPaused, isTrue);
      expect(state.pausedAt, isNotNull);
    });

    test('검사 재개가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
      );
      notifier.pauseAssessment();
      notifier.resumeAssessment();
      
      final state = container.read(assessmentStateProvider);
      expect(state.status, AssessmentStatus.inProgress);
      expect(state.isInProgress, isTrue);
      expect(state.pausedAt, isNull);
    });

    test('검사 완료가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
      );
      notifier.completeAssessment();
      
      final state = container.read(assessmentStateProvider);
      expect(state.status, AssessmentStatus.completed);
      expect(state.isCompleted, isTrue);
      expect(state.completedAt, isNotNull);
    });

    test('검사 진행 상태 업데이트가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
        module: 'phonological',
        step: 1,
      );
      
      notifier.updateProgress(
        module: 'sensory',
        step: 2,
        progressData: {'score': 10},
      );
      
      final state = container.read(assessmentStateProvider);
      expect(state.currentModule, 'sensory');
      expect(state.currentStep, 2);
      expect(state.progressData, {'score': 10});
    });

    test('검사 상태 초기화가 정상 작동해야 함', () {
      final container = ProviderContainer();
      final notifier = container.read(assessmentStateProvider.notifier);
      
      notifier.startAssessment(
        assessmentId: 'test-assessment-123',
        childId: 'test-child-456',
      );
      notifier.completeAssessment();
      notifier.resetAssessment();
      
      final state = container.read(assessmentStateProvider);
      expect(state.assessmentId, isNull);
      expect(state.childId, isNull);
      expect(state.status, AssessmentStatus.inProgress);
    });
  });
}

