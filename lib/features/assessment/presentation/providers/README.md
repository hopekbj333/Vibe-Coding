# Assessment Feature Providers

## 개요

이 디렉토리는 Assessment 기능의 Riverpod Provider들을 관리합니다.

## Provider 구조

### 1. Service Providers
서비스 인스턴스를 제공하는 기본 Provider들

- `storyAssessmentServiceProvider`: `StoryAssessmentService` 인스턴스
- `assessmentEngineProvider`: `AssessmentEngine` 인스턴스
- `scoringRepositoryProvider`: `MockScoringRepository` 인스턴스

### 2. State Notifier Providers
상태를 관리하는 StateNotifierProvider들

- `currentStorySessionProvider`: 현재 스토리 검사 세션 상태
- `currentAssessmentSessionProvider`: 현재 일반 검사 세션 상태
- `scoringNotifierProvider`: 채점 진행 상태

### 3. Derived Providers
다른 Provider에서 파생된 Provider들

- `currentQuestionProvider`: 현재 문항 (세션에서 파생)
- `assessmentProgressProvider`: 진행률 (세션에서 파생)
- `assessmentStatsProvider`: 통계 (세션에서 파생)
- `isAssessmentCompletedProvider`: 완료 여부 (세션에서 파생)

## 의존성 그래프

```
Service Providers
    ↓
State Notifier Providers
    ↓
Derived Providers
```

## 사용 패턴

### StateNotifier 사용
```dart
// StateNotifierProvider 정의
final currentStorySessionProvider =
    StateNotifierProvider<StorySessionNotifier, StorySessionState>((ref) {
  final service = ref.watch(storyAssessmentServiceProvider);
  return StorySessionNotifier(service);
});

// 위젯에서 사용
final sessionState = ref.watch(currentStorySessionProvider);
final session = sessionState.session;
```

### Derived Provider 사용
```dart
// 세션에서 파생된 정보 제공
final currentQuestionProvider = Provider<AssessmentQuestion?>((ref) {
  final sessionAsync = ref.watch(currentAssessmentSessionProvider);
  // ...
});
```

## 개선 사항

### 향후 개선 (Phase 3+)
- [ ] State 클래스에 `freezed` 적용
- [ ] `@riverpod` 어노테이션 사용 (code generation)
- [ ] Provider 의존성 그래프 문서화
