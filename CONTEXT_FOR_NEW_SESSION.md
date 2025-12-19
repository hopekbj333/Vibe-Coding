# 새 세션을 위한 컨텍스트 정보

## 📋 프로젝트 개요

- **프로젝트명**: 문해력 기초 검사 (Literacy Assessment)
- **목적**: 한글 학습의 전제 조건인 음운처리능력(음운인식능력 15개 + 음운처리능력 20개)을 검사하는 디지털 검사 서비스
- **검사 방식**: 스토리형 검사 (35문항)
- **기술 스택**: Flutter, Riverpod, GoRouter, Firebase, Flame Engine

---

## ✅ 최근 완료된 작업 (2025-01-XX)

### 1. JSON 기반 Instruction Sequence 시스템 구축
- **핵심 파일**: `assets/questions/story/instruction_sequences.json`
  - 이 파일이 **35개 문항의 안내 시퀀스의 유일한 소스**입니다
  - 모든 문항의 TTS, 오디오, 딜레이 순서가 JSON으로 정의되어 있습니다

- **구현된 엔진**:
  - `lib/features/assessment/data/services/instruction_sequence_loader_service.dart`
    - JSON 파일을 로드하고 파싱
  - `lib/features/assessment/domain/services/instruction_sequence_executor.dart`
    - JSON의 steps를 순서대로 실행 (tts, delay, audio, audio_sequence, audio_or_tts)

- **사용 위치**: `lib/features/assessment/presentation/pages/story/story_question_page.dart`
  - `_playFullInstructionSequence()` 메서드에서 JSON 기반 엔진 사용

### 2. Feedback 기능 완전 제거
- **이유**: 스토리형 검사는 "검사"이지 "학습"이 아니므로 피드백이 필요 없음
- **제거된 항목**:
  - `StoryQuestion` 모델의 `feedback` 필드
  - `AbilityGameMapping`의 `feedback` 필드
  - `story_question_mapping_service.dart`의 모든 feedback 블록 (35개)
  - `story_feedback_page.dart` 파일 삭제
  - `app_router.dart`의 `/story/feedback` 라우트 제거
  - `StoryFeedback` 클래스 정의 제거

---

## 🏗 현재 아키텍처

### Instruction Sequence JSON 구조
```json
{
  "1": {
    "steps": [
      {"action": "tts", "text": "우와! 동물 마을이야!..."},
      {"action": "delay", "ms": 1000},
      {"action": "audio", "source": "questionAudioPath"},
      {"action": "delay", "ms": 1000},
      {"action": "tts", "text": "다시 듣고 싶으면..."}
    ]
  },
  "2": {
    "steps": [
      {"action": "tts", "text": "이제 두 가지의 소리를..."},
      {"action": "delay", "ms": 1000},
      {"action": "audio_sequence", "source": "options", "field": "audioPath", "delayBetween": 1000},
      {"action": "delay", "ms": 1000},
      {"action": "tts", "text": "소리를 다시 듣고..."}
    ]
  },
  "3": {
    "steps": [
      {"action": "tts", "text": "다음에 들리는 말소리가..."},
      {"action": "delay", "ms": 1000},
      {"action": "audio_or_tts", "audioPath": "questionAudioPath", "ttsFallback": "question.question"},
      {"action": "delay", "ms": 1000},
      {"action": "tts", "text": "다시 듣고 싶으면..."}
    ]
  }
  // ... 35개 문항
}
```

### 지원하는 Action 타입
1. **`tts`**: TTS로 텍스트 읽기
   - `text`: 읽을 텍스트
2. **`delay`**: 딜레이
   - `ms`: 밀리초 단위 딜레이
3. **`audio`**: 단일 오디오 재생
   - `source`: "questionAudioPath" (문항 오디오)
4. **`audio_sequence`**: 여러 오디오 순차 재생 (2번 문항용)
   - `source`: "options"
   - `field`: "audioPath"
   - `delayBetween`: 오디오 간 딜레이 (ms)
5. **`audio_or_tts`**: 오디오 시도, 실패 시 TTS (3번 문항용)
   - `audioPath`: "questionAudioPath"
   - `ttsFallback`: "question.question" (문항 텍스트)

---

## ⚠️ 중요한 규칙 및 주의사항

### 1. 완성 문항 보호 (CRITICAL)
- **사용자가 '완성'이라고 표시하거나 승인한 문항/기능/코드는 사용자의 명시적 승인 없이 절대로 수정하지 않습니다**
- 완성된 문항의 버그 수정이라도 사용자에게 먼저 확인을 받아야 합니다
- 완성된 코드의 리팩토링이나 개선 작업도 사용자 승인이 필요합니다

### 2. 새로운 항목 추가 시 확인 필수
- **모든 새로운 항목이나 기능은 사용자에게 정확하게 확인을 받고 진행해야 합니다**
- 예: feedback을 JSON에 추가하려다가 사용자가 "검사에는 필요 없다"고 지시하여 제거함

### 3. instruction_sequences.json이 유일한 소스
- 35개 문항의 안내 시퀀스는 **오직 `instruction_sequences.json`에서만 관리**됩니다
- 다른 파일에 하드코딩된 문항 관련 멘트는 모두 제거되었습니다

### 4. Zero-Text Interface 원칙
- 아동용 화면에는 텍스트를 절대 사용하지 않거나 최소화
- 모든 지시는 **음성(TTS/녹음)**으로 제공
- 버튼은 **이미지/아이콘**이어야 함

---

## 🔍 현재 상태 및 남은 작업

### 완료된 것
- ✅ JSON 기반 instruction sequence 시스템 구축
- ✅ Feedback 기능 완전 제거
- ✅ 35개 문항의 기본 instruction sequence 정의 (instruction_sequences.json)

### 확인 필요 / 남은 작업
1. **스피커 버튼 로직**
   - `story_question_page.dart`의 스피커 버튼이 여전히 하드코딩되어 있을 수 있음
   - Q2, Q3에 대한 특별 처리 로직이 남아있을 수 있음
   - JSON 기반으로 리팩토링 필요할 수 있음

2. **storyContext, stageTitle**
   - `story_question_mapping_service.dart`에 하드코딩되어 있음
   - JSON으로 이동할지, 아니면 그대로 둘지 확인 필요

3. **characterDialogue**
   - 현재 빈 문자열로 설정되어 있음 (`// instruction_sequences.json에서 관리` 주석)
   - 실제로 사용되는지 확인 필요

---

## 📁 주요 파일 위치

### Instruction Sequence 관련
- `assets/questions/story/instruction_sequences.json` - **35개 문항 안내 시퀀스 정의**
- `lib/features/assessment/data/services/instruction_sequence_loader_service.dart` - JSON 로더
- `lib/features/assessment/domain/services/instruction_sequence_executor.dart` - 실행 엔진

### 스토리형 검사 페이지
- `lib/features/assessment/presentation/pages/story/story_question_page.dart` - 문항 제시 페이지
- `lib/features/assessment/data/services/story_question_mapping_service.dart` - 35개 능력 매핑

### 모델
- `lib/features/assessment/data/models/story_assessment_model.dart` - StoryQuestion 등 모델 정의

---

## 🚨 작업 시 주의사항

1. **언어**: 모든 대화와 설명은 **한국어**로 합니다
2. **파일 수정 전 확인**: 기존 코드를 덮어쓰기 전에 `read_file`로 내용을 확인
3. **사용자 관점**: "이것이 6살 아이가 쓰기에 적합한가?"를 자문
4. **에러 처리**: 아동이 오작동(마구 누르기 등)을 할 수 있음을 가정하고 예외 처리를 꼼꼼하게
5. **소통**: 구현 방향이 모호하면 사용자에게 질문하여 명확히 한 후 진행

---

## 📝 참고 문서

- `AGENTS.md` - 프로젝트 가이드라인 (최우선 기준)
- `PROJECT_STRUCTURE.md` - 프로젝트 구조 설명
- `milestone1.md`, `milestone2.md` 등 - 마일스톤별 문서

---

*Last Updated: 2025-01-XX (Feedback 제거 완료 후)*





