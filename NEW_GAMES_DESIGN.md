# 📝 신규 게임 설계서 (19개)

**작성일:** 2025-12-06  
**목적:** 50개 게임 구조를 완성하기 위한 신규 게임 설계

---

## 📊 개요

**추가 필요:**
- Auditory: 5개
- Visual: 4개
- Working Memory: 5개
- Attention: 5개
- **총 19개**

---

## 🔊 Auditory (청각 처리) - 신규 5개

### A-6: 소리 순서 기억 게임

**파일명:** `sound_sequence_memory_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 여러 개의 소리를 순서대로 들려줌
- 같은 순서로 버튼을 눌러야 함
- 예: "딩동-땡땡-똑똑" → 3개 버튼 순서대로 터치

**문항 예시:**
```json
{
  "itemId": "ssm_001",
  "question": "순서대로 소리를 찾으세요",
  "options": [
    {"optionId": "sound1", "label": "🔔 딩동", "audioPath": "bell.mp3"},
    {"optionId": "sound2", "label": "🥁 땡땡", "audioPath": "drum.mp3"},
    {"optionId": "sound3", "label": "🚪 똑똑", "audioPath": "knock.mp3"}
  ],
  "correctAnswer": "sound1,sound2,sound3",
  "itemData": {"sequenceLength": 3}
}
```

**게임 패턴:** `sequencing`

---

### A-7: 음높이 구별 게임

**파일명:** `pitch_discrimination_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 두 개의 음을 들려줌
- 높은 소리인지 낮은 소리인지 판별
- 또는 같은 음높이인지 다른 음높이인지

**문항 예시:**
```json
{
  "itemId": "pd_001",
  "question": "어느 소리가 더 높나요?",
  "options": [
    {"optionId": "opt1", "label": "첫 번째", "audioPath": "pitch_low.mp3"},
    {"optionId": "opt2", "label": "두 번째", "audioPath": "pitch_high.mp3"}
  ],
  "correctAnswer": "opt2"
}
```

**게임 패턴:** `multipleChoice`

---

### A-8: 소리 크기 비교 게임

**파일명:** `volume_comparison_game.dart`  
**난이도:** ★☆☆

**게임 설명:**
- 여러 소리 중 가장 큰 소리/작은 소리 찾기
- 3~4개 소리를 순차적으로 들려줌

**문항 예시:**
```json
{
  "itemId": "vc_001",
  "question": "가장 큰 소리를 찾으세요",
  "options": [
    {"optionId": "opt1", "label": "소리 1", "audioPath": "vol_soft.mp3"},
    {"optionId": "opt2", "label": "소리 2", "audioPath": "vol_loud.mp3"},
    {"optionId": "opt3", "label": "소리 3", "audioPath": "vol_medium.mp3"}
  ],
  "correctAnswer": "opt2"
}
```

**게임 패턴:** `multipleChoice`

---

### A-9: 빠르기 순서 게임

**파일명:** `tempo_sequence_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 빠르기가 다른 리듬을 들려줌
- 느린 것부터 빠른 것 순서로 배열

**문항 예시:**
```json
{
  "itemId": "ts_001",
  "question": "느린 순서대로 정렬하세요",
  "options": [
    {"optionId": "opt1", "label": "리듬 1", "audioPath": "tempo_fast.mp3"},
    {"optionId": "opt2", "label": "리듬 2", "audioPath": "tempo_slow.mp3"},
    {"optionId": "opt3", "label": "리듬 3", "audioPath": "tempo_medium.mp3"}
  ],
  "correctAnswer": "opt2,opt3,opt1"
}
```

**게임 패턴:** `sequencing`

---

### A-10: 환경음 식별 게임

**파일명:** `environmental_sound_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 일상 환경음을 듣고 무엇인지 맞추기
- 예: 비 소리, 자동차, 문 닫는 소리 등

**문항 예시:**
```json
{
  "itemId": "es_001",
  "question": "무슨 소리일까요?",
  "questionAudioPath": "rain_sound.mp3",
  "options": [
    {"optionId": "opt1", "label": "🌧️ 비", "imagePath": "rain.png"},
    {"optionId": "opt2", "label": "🌊 파도", "imagePath": "wave.png"},
    {"optionId": "opt3", "label": "💨 바람", "imagePath": "wind.png"}
  ],
  "correctAnswer": "opt1"
}
```

**게임 패턴:** `multipleChoice`

---

## 👁️ Visual (시각 처리) - 신규 4개

### V-7: 부분으로 전체 추측 게임

**파일명:** `visual_closure_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 일부만 보이는 그림/글자를 보고 전체 추측
- Visual Closure 능력 평가

**문항 예시:**
```json
{
  "itemId": "vc_001",
  "question": "어떤 글자일까요?",
  "questionImagePath": "partial_가.png",
  "options": [
    {"optionId": "opt1", "label": "가", "imagePath": "full_가.png"},
    {"optionId": "opt2", "label": "나", "imagePath": "full_나.png"},
    {"optionId": "opt3", "label": "다", "imagePath": "full_다.png"}
  ],
  "correctAnswer": "opt1"
}
```

**게임 패턴:** `multipleChoice`

---

### V-8: 배경-전경 구별 게임

**파일명:** `figure_ground_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 복잡한 배경에서 특정 그림/글자 찾기
- Figure-Ground 지각 능력

**문항 예시:**
```json
{
  "itemId": "fg_001",
  "question": "숨어있는 '가'를 모두 찾으세요",
  "questionImagePath": "complex_background.png",
  "correctAnswer": "3",
  "itemData": {"targetCount": 3}
}
```

**게임 패턴:** `matching`

---

### V-9: 시각 추적 게임

**파일명:** `visual_tracking_game.dart`  
**난이도:** ★☆☆

**게임 설명:**
- 움직이는 물체를 눈으로 따라가기
- 여러 선 중 하나를 끝까지 추적

**문항 예시:**
```json
{
  "itemId": "vt_001",
  "question": "빨간 선이 어디로 가나요?",
  "questionImagePath": "tangled_lines.png",
  "options": [
    {"optionId": "opt1", "label": "A"},
    {"optionId": "opt2", "label": "B"},
    {"optionId": "opt3", "label": "C"}
  ],
  "correctAnswer": "opt2"
}
```

**게임 패턴:** `multipleChoice`

---

### V-10: 패턴 완성 게임

**파일명:** `pattern_completion_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 규칙적인 패턴을 보여주고 빈칸 채우기
- 예: ○△○△○?

**문항 예시:**
```json
{
  "itemId": "pc_001",
  "question": "다음에 올 모양은?",
  "questionImagePath": "pattern_circle_triangle.png",
  "options": [
    {"optionId": "opt1", "label": "○", "imagePath": "circle.png"},
    {"optionId": "opt2", "label": "△", "imagePath": "triangle.png"},
    {"optionId": "opt3", "label": "□", "imagePath": "square.png"}
  ],
  "correctAnswer": "opt2"
}
```

**게임 패턴:** `multipleChoice`

---

## 🧠 Working Memory (작업 기억) - 신규 5개

### WM-6: 숫자 폭 기억 게임

**파일명:** `digit_span_game.dart` (Phonological4에서 이동)  
**난이도:** ★★☆

**게임 설명:**
- 숫자를 순서대로 듣고 따라 말하기
- 순방향/역방향 두 가지 모드

**문항 예시:**
```json
{
  "itemId": "ds_001",
  "question": "숫자를 순서대로 말하세요",
  "questionAudioPath": "digits_3_7_2.mp3",
  "correctAnswer": "3-7-2",
  "itemData": {"digits": [3, 7, 2], "mode": "forward"}
}
```

**게임 패턴:** `recording` (STT)

---

### WM-7: 이중 과제 게임

**파일명:** `dual_task_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 두 가지 작업을 동시에 수행
- 예: 숫자 세면서 + 색깔 구별하기

**문항 예시:**
```json
{
  "itemId": "dt_001",
  "question": "빨간 동그라미가 몇 개인가요?",
  "questionImagePath": "mixed_shapes.png",
  "correctAnswer": "5",
  "itemData": {"task1": "count", "task2": "filter_color"}
}
```

**게임 패턴:** `multipleChoice`

---

### WM-8: 업데이트 기억 게임

**파일명:** `updating_memory_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 계속 바뀌는 정보를 기억하고 업데이트
- 예: 최근 3개만 기억하기

**문항 예시:**
```json
{
  "itemId": "um_001",
  "question": "마지막 3개를 말하세요",
  "questionAudioPath": "sequence_1_2_3_4_5.mp3",
  "correctAnswer": "3-4-5",
  "itemData": {"windowSize": 3}
}
```

**게임 패턴:** `recording`

---

### WM-9: 위치 기억 게임

**파일명:** `location_memory_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 여러 물체의 위치를 기억
- 사라진 후 원래 위치 맞추기

**문항 예시:**
```json
{
  "itemId": "lm_001",
  "question": "사과가 어디 있었나요?",
  "questionImagePath": "objects_shown.png",
  "options": [
    {"optionId": "pos1", "label": "위치 1"},
    {"optionId": "pos2", "label": "위치 2"},
    {"optionId": "pos3", "label": "위치 3"}
  ],
  "correctAnswer": "pos2"
}
```

**게임 패턴:** `multipleChoice`

---

### WM-10: 복합 기억 폭 게임

**파일명:** `complex_span_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 문장을 듣고 마지막 단어만 기억
- 여러 문장 후 순서대로 말하기

**문항 예시:**
```json
{
  "itemId": "cs_001",
  "question": "각 문장의 마지막 단어를 말하세요",
  "questionAudioPath": "sentences_cat_dog_bird.mp3",
  "correctAnswer": "고양이-강아지-새",
  "itemData": {
    "sentences": [
      "나는 고양이를 좋아해",
      "집에는 강아지가 있어",
      "하늘에 새가 날아"
    ]
  }
}
```

**게임 패턴:** `recording`

---

## 🎯 Attention (주의력) - 신규 5개

### AT-6: 선택적 주의 게임

**파일명:** `selective_attention_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 여러 자극 중 특정 자극만 반응
- 예: 빨간색 동그라미만 터치

**문항 예시:**
```json
{
  "itemId": "sa_001",
  "question": "빨간 동그라미만 터치하세요",
  "options": [
    {"optionId": "obj1", "label": "🔴", "optionData": {"color": "red", "shape": "circle"}},
    {"optionId": "obj2", "label": "🔵", "optionData": {"color": "blue", "shape": "circle"}},
    {"optionId": "obj3", "label": "🟥", "optionData": {"color": "red", "shape": "square"}}
  ],
  "correctAnswer": "obj1"
}
```

**게임 패턴:** `multipleChoice`

---

### AT-7: 분할 주의 게임

**파일명:** `divided_attention_game.dart`  
**난이도:** ★★★

**게임 설명:**
- 두 가지를 동시에 주의해야 함
- 예: 왼쪽 화면 + 오른쪽 화면 동시 관찰

**문항 예시:**
```json
{
  "itemId": "da_001",
  "question": "양쪽 모두에서 같은 것을 찾으세요",
  "questionImagePath": "split_screen.png",
  "correctAnswer": "both_have_star",
  "itemData": {"leftSide": "stars", "rightSide": "mixed"}
}
```

**게임 패턴:** `multipleChoice`

---

### AT-8: 지속적 주의 게임

**파일명:** `sustained_attention_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 일정 시간 동안 집중 유지
- 목표 자극이 나타날 때만 반응 (CPT - Continuous Performance Test)

**문항 예시:**
```json
{
  "itemId": "sust_001",
  "question": "별(⭐)이 나오면 터치하세요",
  "itemData": {
    "duration": 60,
    "stimuli": ["○", "△", "⭐", "□", "⭐", "○"],
    "targetStimulus": "⭐",
    "targetIndices": [2, 4]
  },
  "correctAnswer": "2,4"
}
```

**게임 패턴:** `goNoGo`

---

### AT-9: 시각 탐색 게임

**파일명:** `visual_search_game.dart`  
**난이도:** ★★☆

**게임 설명:**
- 여러 물체 중에서 목표 찾기
- Where's Waldo 스타일

**문항 예시:**
```json
{
  "itemId": "vs_001",
  "question": "빨간 사과를 찾으세요",
  "questionImagePath": "many_fruits.png",
  "correctAnswer": "position_3_5",
  "itemData": {"gridSize": "5x5", "targetPosition": [3, 5]}
}
```

**게임 패턴:** `matching`

---

### AT-10: Go/No-Go 기본 게임

**파일명:** `go_no_go_basic_game.dart`  
**난이도:** ★☆☆

**게임 설명:**
- 특정 자극에만 반응 (Go), 나머지는 무시 (No-Go)
- 충동 조절 능력 측정

**문항 예시:**
```json
{
  "itemId": "gng_001",
  "question": "⭐가 나오면 터치, ✖️가 나오면 무시",
  "itemData": {
    "stimuli": ["⭐", "✖️", "⭐", "⭐", "✖️"],
    "goStimulus": "⭐",
    "nogoStimulus": "✖️"
  },
  "correctAnswer": "tap_on_0_2_3"
}
```

**게임 패턴:** `goNoGo`

---

## 📋 구현 우선순위

### 우선순위 1 (쉬움, 빠르게 구현 가능)
- ✅ volume_comparison_game (소리 크기)
- ✅ environmental_sound_game (환경음)
- ✅ visual_closure_game (부분 추측)
- ✅ visual_tracking_game (시각 추적)
- ✅ go_no_go_basic_game (기본 반응)

### 우선순위 2 (중간)
- ⏳ pitch_discrimination_game (음높이)
- ⏳ pattern_completion_game (패턴)
- ⏳ location_memory_game (위치 기억)
- ⏳ selective_attention_game (선택 주의)
- ⏳ visual_search_game (시각 탐색)

### 우선순위 3 (복잡, 나중에)
- ⬜ sound_sequence_memory_game (소리 순서)
- ⬜ tempo_sequence_game (빠르기 순서)
- ⬜ figure_ground_game (배경-전경)
- ⬜ dual_task_game (이중 과제)
- ⬜ updating_memory_game (업데이트 기억)
- ⬜ complex_span_game (복합 기억)
- ⬜ divided_attention_game (분할 주의)
- ⬜ sustained_attention_game (지속 주의)

---

## 🎯 다음 단계

1. ✅ 신규 게임 설계 완료
2. ⏳ digit_span_game을 Working Memory로 이동
3. ⏳ 최종 50개 게임 문서 확정
4. ⏳ 우선순위 1 게임부터 구현 시작

---

**작성일:** 2025-12-06  
**상태:** 설계 완료  
**다음:** 구현 시작
