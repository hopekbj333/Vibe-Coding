# 🚀 Milestone 2 시작 가이드 (새 창 작업용)

**이 문서는 새 컨텍스트 창에서 Milestone 2를 시작할 때 참고하는 문서입니다.**

---

## 📋 첫 번째 요청 (복사해서 사용)

```
안녕하세요. Literacy Assessment 프로젝트입니다.

Milestone 1을 완료하고 이제 Milestone 2를 시작합니다.

먼저 다음 문서들을 읽어주세요:
1. agents.md - 프로젝트 가이드라인
2. MILESTONE1_COMPLETION_SUMMARY.md - 이전 작업 요약
3. PROJECT_STRUCTURE.md - 프로젝트 구조
4. milestone2_WP2.1_gameframework.md - 첫 번째 작업

그리고 WP 2.1 작업을 시작해주세요.
```

---

## 📚 필수 참고 문서

### 1. 프로젝트 기본 문서
- `agents.md` - AI 에이전트 작업 규칙 (⭐ 최우선)
- `PROJECT_STRUCTURE.md` - 폴더 구조
- `STATE_MANAGEMENT_GUIDE.md` - Riverpod 사용법

### 2. Milestone 1 완료 내용
- `MILESTONE1_COMPLETION_SUMMARY.md` - 작업 요약
  - 완료된 기능
  - 해결한 이슈
  - 중요한 기술 결정
  - Mock 데이터 구조

### 3. Milestone 2 작업 문서
- `milestone2.md` - 전체 개요
- `milestone2_WP2.1_gameframework.md` - 게임 엔진
- `milestone2_WP2.2_gamepatterns.md` - 게임 패턴
- `milestone2_WP2.3_phonological1.md` - 음운 1단계
- `milestone2_WP2.4_phonological2.md` - 음운 2단계
- `milestone2_WP2.5_phonological3.md` - 음운 3단계
- `milestone2_WP2.6_learning_mgmt.md` - 학습 관리
- `milestone2_WP2.7_voice_scoring.md` - 음성 채점 고도화
- `milestone2_WP2.8_retest.md` - 재검사

---

## 🎯 Milestone 2 목표

### 핵심 목표
1. **Flame Engine 게임 도입** - 재미있는 학습 게임
2. **5대 게임 패턴 모듈** - 재사용 가능한 템플릿
3. **음운 인식 훈련** - 3단계 학습 콘텐츠
4. **학습 관리 시스템** - 일일 제한, 진도 관리
5. **STT 연동** - 음성 채점 자동화

### 예상 작업량
- 워크패키지: 8개
- 시나리오: 43개
- 예상 기간: 4~6주 (개발자 1명 기준)

---

## 🏗️ 기술 스택 추가

### 새로 추가할 패키지
```yaml
dependencies:
  flame: ^1.17.0          # 2D 게임 엔진
  flame_audio: ^2.1.0     # Flame용 오디오
  audioplayers: ^5.2.0    # 일반 오디오 재생
  speech_to_text: ^6.6.0  # STT (WP 2.7)
  
  # 향후 고려
  pdf: ^3.10.0            # PDF 생성 (나중에)
  share_plus: ^7.2.0      # 공유 기능
  flutter_tts: ^4.0.0     # TTS (재도입 검토)
```

### 폴더 구조 확장
```
lib/features/
├── assessment/    # 기존 (검사)
└── training/      # 신규 (학습)
    ├── data/
    │   ├── models/
    │   │   ├── game_session_model.dart
    │   │   ├── training_content_model.dart
    │   │   └── learning_progress_model.dart
    │   └── repositories/
    │       └── training_repository.dart
    ├── domain/
    │   └── services/
    │       ├── difficulty_adjuster.dart
    │       ├── progress_tracker.dart
    │       └── audio_feedback_service.dart
    └── presentation/
        ├── games/     # Flame 게임들
        │   ├── base/
        │   │   └── base_game.dart
        │   ├── patterns/
        │   │   ├── ox_game.dart
        │   │   ├── choice_game.dart
        │   │   ├── matching_game.dart
        │   │   ├── sequencing_game.dart
        │   │   └── gonogo_game.dart
        │   └── phonological/
        │       ├── sound_detective_game.dart
        │       ├── rhythm_game.dart
        │       └── ...
        ├── pages/
        │   ├── training_home_page.dart
        │   ├── progress_map_page.dart
        │   └── game_player_page.dart
        └── providers/
            └── training_providers.dart
```

---

## 🔑 주요 아키텍처 결정

### 1. 검사 vs 학습 분리
- **검사**: `features/assessment/` (기존)
- **학습**: `features/training/` (신규)
- **공통**: `core/` (공유)

### 2. Flutter 위젯 vs Flame 게임
- **검사**: Flutter 위젯 사용 (현재 구조)
- **학습**: Flame Engine 사용 (신규)
- **전환**: GameWidget으로 Flutter ↔ Flame 연결

### 3. 데이터 재사용
- 검사 문항 구조(`QuestionModel`) 참고
- 학습 문항은 별도 모델(`TrainingContent`)
- 일부 위젯은 재사용 가능

---

## 📊 현재 구현 상태

### Milestone 1 (완료) ✅
- [x] WP 1.1: 시스템 환경
- [x] WP 1.2: 사용자 관리
- [x] WP 1.3: 검사 프레임워크
- [x] WP 1.4: 음운 인식 검사 (41문항 중 q4~q16)
- [x] WP 1.5: 감각 처리 검사 (q17~q34)
- [x] WP 1.6: 인지 제어 검사 (q35~q41)
- [x] WP 1.7: 채점 시스템 (핵심 기능)
- [x] WP 1.8: 결과 리포트 (핵심 기능)

### Milestone 2 (시작 예정) ⏳
- [ ] WP 2.1: 게임 엔진 및 학습 프레임워크
- [ ] WP 2.2: 5대 게임 패턴 모듈
- [ ] WP 2.3: 음운 인식 1단계 훈련
- [ ] WP 2.4: 음운 인식 2단계 훈련
- [ ] WP 2.5: 음운 인식 3단계 훈련
- [ ] WP 2.6: 학습 관리 시스템
- [ ] WP 2.7: 음성 채점 고도화 (STT)
- [ ] WP 2.8: 재검사 시스템

---

## 🚨 중요한 기술 사항

### DesignSystem 색상명 (자주 틀림!)
```dart
// ✅ 올바른 이름
DesignSystem.primaryBlue
DesignSystem.semanticSuccess  (초록)
DesignSystem.semanticError    (빨강)
DesignSystem.semanticWarning  (노랑)
DesignSystem.semanticInfo     (파랑)
DesignSystem.neutralGray100~900

// ❌ 잘못된 이름 (사용하지 마세요)
DesignSystem.colorPrimary
DesignSystem.colorSuccess
DesignSystem.colorSurface
DesignSystem.colorBorder
```

### QuestionType vs TrainingType
- **검사**: `QuestionType` enum 사용 (27개 정의됨)
- **학습**: 별도로 `TrainingType` enum 만들 예정

### 오버플로우 방지
- 모든 위젯은 `SingleChildScrollView`로 감싸기
- 특히 GridView 사용 시 필수

### AnimationController 재생성
- 문제가 바뀔 때 옵션 개수가 변하면 controller도 재생성 필요

---

## 💡 작업 시작 팁

### WP 2.1부터 시작하는 이유
1. **게임 엔진 먼저**: Flame을 먼저 설정해야 게임을 만들 수 있음
2. **공통 프레임워크**: 모든 학습 게임의 기반
3. **학습 세션 관리**: 검사 프레임워크와 유사한 패턴

### 참고할 기존 코드
- `assessment_player_page.dart` - 전체 진행 구조
- `assessment_providers.dart` - 상태 관리 패턴
- `choice_question_widget.dart` - 위젯 구조 참고

### 주의사항
1. **음성 파일**: 실제 오디오 파일이 아직 없으므로 시뮬레이션
2. **이미지 에셋**: 캐릭터, 배경 이미지 준비 필요
3. **Flame 학습**: Flame Engine 공식 문서 참고 필수

---

## 🎮 Flame Engine 기본 개념

### Flutter vs Flame
```dart
// Flutter 위젯 (검사용)
class MyWidget extends StatelessWidget {
  Widget build() => Container(...);
}

// Flame 게임 (학습용)
class MyGame extends FlameGame {
  void onLoad() { /* 게임 초기화 */ }
  void update(double dt) { /* 매 프레임 업데이트 */ }
  void render(Canvas canvas) { /* 그리기 */ }
}
```

### 게임 루프
- 1초에 60번 `update()` 호출
- 캐릭터 위치, 애니메이션 등 업데이트
- Flutter 위젯보다 복잡하지만 게임에 적합

---

## 📝 작업 순서 제안

### Phase 1: 기반 구축 (1주)
1. WP 2.1: Flame Engine 통합
2. WP 2.2: 기본 게임 패턴 1~2개

### Phase 2: 콘텐츠 구현 (2~3주)
3. WP 2.3: 음운 1단계 (2~3개 게임)
4. WP 2.4: 음운 2단계 (2~3개 게임)
5. WP 2.5: 음운 3단계 (2~3개 게임)

### Phase 3: 관리 시스템 (1~2주)
6. WP 2.6: 학습 관리
7. WP 2.7: STT 연동 (시간 있으면)
8. WP 2.8: 재검사

---

## ✅ 준비 완료 체크리스트

- [x] Milestone 1 완료
- [x] 작업 요약 문서 작성
- [x] WP별 MD 파일 8개 생성
- [x] 비개발자 설명 추가
- [x] 새 창 시작 가이드 작성

**모든 준비가 완료되었습니다!**  
**새 창을 열어서 Milestone 2를 시작하세요!** 🚀

---

**작성일**: 2025-12-04  
**작성자**: AI Assistant

