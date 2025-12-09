# 🎯 최종 50개 게임 확정 목록

**확정일:** 2025-12-06  
**구조:** 5개 분야 × 10개 게임 = **50개**  
**목표 문항:** 50개 × 300문항 = **15,000개**

---

## 📊 전체 구조

```
┌─────────────────────────────────────────────────┐
│  5개 분야 × 10개 게임 = 50개 게임                 │
├─────────────────────────────────────────────────┤
│  각 게임 × 300개 문항 = 15,000개 학습 문항        │
└─────────────────────────────────────────────────┘
```

---

## 1️⃣ Phonological (음운 인식) - 10개

| ID | 게임명 | 파일명 | 난이도 | 패턴 | 상태 |
|----|--------|--------|--------|------|------|
| P-01 | 같은 소리 찾기 | `same_sound_game.dart` | ★☆☆ | multipleChoice | ✅ JSON |
| P-02 | 다른 소리 찾기 | `different_sound_game.dart` | ★☆☆ | multipleChoice | 🔄 |
| P-03 | 리듬 따라하기 | `rhythm_follow_game.dart` | ★★☆ | rhythmTap | 🔄 |
| P-04 | 각운 찾기 | `rhyme_game.dart` | ★★☆ | multipleChoice | 🔄 |
| P-05 | 박수로 음절 쪼개기 | `syllable_clap_game.dart` | ★★☆ | rhythmTap | ✅ JSON |
| P-06 | 음절 합성 | `syllable_merge_game.dart` | ★★★ | multipleChoice | 🔄 |
| P-07 | 음절 분리 | `syllable_split_game.dart` | ★★★ | multipleChoice | 🔄 |
| P-08 | 초성 분리 | `onset_separation_game.dart` | ★★★ | recording | 🔄 |
| P-09 | 음소 합성 | `phoneme_synthesis_game.dart` | ★★★ | multipleChoice | 🔄 |
| P-10 | 음소 대치 | `phoneme_substitution_game.dart` | ★★★ | recording | 🔄 |

**난이도 분포:** 쉬움 2개, 중간 4개, 어려움 4개

---

## 2️⃣ Auditory (청각 처리) - 10개

| ID | 게임명 | 파일명 | 난이도 | 패턴 | 상태 |
|----|--------|--------|--------|------|------|
| A-01 | 동물 소리 이야기 | `animal_sound_story_game.dart` | ★☆☆ | multipleChoice | 🔄 |
| A-02 | 악기 순서 기억 | `instrument_sequence_game.dart` | ★★☆ | sequencing | 🔄 |
| A-03 | 리듬 패턴 | `rhythm_pattern_game.dart` | ★★☆ | rhythmTap | 🔄 |
| A-04 | 사이먼 가라사대 | `simon_says_game.dart` | ★★★ | sequencing | 🔄 |
| A-05 | 소리 규칙 찾기 | `sound_rule_game.dart` | ★★★ | multipleChoice | 🔄 |
| A-06 | 소리 순서 기억 | `sound_sequence_memory_game.dart` | ★★☆ | sequencing | 📝 신규 |
| A-07 | 음높이 구별 | `pitch_discrimination_game.dart` | ★★☆ | multipleChoice | 📝 신규 |
| A-08 | 소리 크기 비교 | `volume_comparison_game.dart` | ★☆☆ | multipleChoice | 📝 신규 |
| A-09 | 빠르기 순서 | `tempo_sequence_game.dart` | ★★★ | sequencing | 📝 신규 |
| A-10 | 환경음 식별 | `environmental_sound_game.dart` | ★★☆ | multipleChoice | 📝 신규 |

**난이도 분포:** 쉬움 2개, 중간 5개, 어려움 3개

---

## 3️⃣ Visual (시각 처리) - 10개

| ID | 게임명 | 파일명 | 난이도 | 패턴 | 상태 |
|----|--------|--------|--------|------|------|
| V-01 | 숨은 글자 찾기 | `hidden_letter_game.dart` | ★★☆ | matching | 🔄 |
| V-02 | 글자 방향 구별 | `letter_direction_game.dart` | ★★☆ | multipleChoice | 🔄 |
| V-03 | 좌우 대칭 | `mirror_symmetry_game.dart` | ★★☆ | multipleChoice | 🔄 |
| V-04 | 퍼즐 | `puzzle_game.dart` | ★★★ | matching | 🔄 |
| V-05 | 도형 회전 | `shape_rotation_game.dart` | ★★★ | multipleChoice | 🔄 |
| V-06 | 틀린 그림 찾기 | `spot_difference_game.dart` | ★★☆ | matching | 🔄 |
| V-07 | 부분으로 전체 추측 | `visual_closure_game.dart` | ★★☆ | multipleChoice | 📝 신규 |
| V-08 | 배경-전경 구별 | `figure_ground_game.dart` | ★★★ | matching | 📝 신규 |
| V-09 | 시각 추적 | `visual_tracking_game.dart` | ★☆☆ | multipleChoice | 📝 신규 |
| V-10 | 패턴 완성 | `pattern_completion_game.dart` | ★★☆ | multipleChoice | 📝 신규 |

**난이도 분포:** 쉬움 1개, 중간 6개, 어려움 3개

---

## 4️⃣ Working Memory (작업 기억) - 10개

| ID | 게임명 | 파일명 | 난이도 | 패턴 | 상태 |
|----|--------|--------|--------|------|------|
| WM-01 | 카드 짝 맞추기 | `card_match_game.dart` | ★★☆ | matching | ✅ JSON |
| WM-02 | 지시 따르기 | `instruction_follow_game.dart` | ★★☆ | sequencing | 🔄 |
| WM-03 | N-back | `n_back_game.dart` | ★★★ | goNoGo | 🔄 |
| WM-04 | 거꾸로 말하기 | `reverse_speak_game.dart` | ★★★ | recording | 🔄 |
| WM-05 | 거꾸로 터치하기 | `reverse_touch_game.dart` | ★★☆ | sequencing | 🔄 |
| WM-06 | 숫자 폭 기억 | `digit_span_game.dart` | ★★☆ | recording | 🔄 이동 |
| WM-07 | 이중 과제 | `dual_task_game.dart` | ★★★ | multipleChoice | 📝 신규 |
| WM-08 | 업데이트 기억 | `updating_memory_game.dart` | ★★★ | recording | 📝 신규 |
| WM-09 | 위치 기억 | `location_memory_game.dart` | ★★☆ | multipleChoice | 📝 신규 |
| WM-10 | 복합 기억 폭 | `complex_span_game.dart` | ★★★ | recording | 📝 신규 |

**난이도 분포:** 쉬움 0개, 중간 5개, 어려움 5개

---

## 5️⃣ Attention (주의력) - 10개

| ID | 게임명 | 파일명 | 난이도 | 패턴 | 상태 |
|----|--------|--------|--------|------|------|
| AT-01 | 청각 주의력 | `auditory_attention_game.dart` | ★★☆ | goNoGo | 🔄 |
| AT-02 | 흐름 추적 | `flow_tracking_game.dart` | ★★★ | matching | 🔄 |
| AT-03 | 집중력 마라톤 | `focus_marathon_game.dart` | ★★★ | goNoGo | 🔄 |
| AT-04 | 스트룹 과제 | `stroop_game.dart` | ★★★ | multipleChoice | 🔄 |
| AT-05 | 목표 찾기 | `target_hunt_game.dart` | ★★☆ | matching | 🔄 |
| AT-06 | 선택적 주의 | `selective_attention_game.dart` | ★★☆ | multipleChoice | 📝 신규 |
| AT-07 | 분할 주의 | `divided_attention_game.dart` | ★★★ | multipleChoice | 📝 신규 |
| AT-08 | 지속적 주의 | `sustained_attention_game.dart` | ★★☆ | goNoGo | 📝 신규 |
| AT-09 | 시각 탐색 | `visual_search_game.dart` | ★★☆ | matching | 📝 신규 |
| AT-10 | Go/No-Go 기본 | `go_no_go_basic_game.dart` | ★☆☆ | goNoGo | 📝 신규 |

**난이도 분포:** 쉬움 1개, 중간 5개, 어려움 4개

---

## 📊 종합 통계

### 상태별 분포

| 상태 | 개수 | 비율 |
|------|------|------|
| ✅ JSON 기반 | 3개 | 6% |
| 🔄 하드코딩 (전환 필요) | 32개 | 64% |
| 📝 신규 설계 필요 | 15개 | 30% |
| **총계** | **50개** | **100%** |

### 난이도별 분포

| 난이도 | 개수 | 비율 |
|--------|------|------|
| ★☆☆ 쉬움 | 6개 | 12% |
| ★★☆ 중간 | 26개 | 52% |
| ★★★ 어려움 | 18개 | 36% |

### 게임 패턴별 분포

| 패턴 | 개수 | 게임 예시 |
|------|------|-----------|
| multipleChoice | 22개 | 같은 소리 찾기, 다른 소리 찾기 등 |
| sequencing | 6개 | 악기 순서, 소리 순서 등 |
| rhythmTap | 3개 | 리듬 따라하기, 박수 쪼개기 등 |
| matching | 8개 | 카드 매칭, 틀린 그림 찾기 등 |
| goNoGo | 6개 | Go/No-Go, 지속적 주의 등 |
| recording | 5개 | 음소 대치, 거꾸로 말하기 등 |

---

## 🗑️ 보류된 게임 (15개)

### Phonological에서 제외

**1단계 (3개):**
- emotion_detect_game
- intonation_game
- tempo_compare_game

**2단계 (3개):**
- alliteration_game
- word_boundary_game
- word_chain_game
- word_count_game

**3단계 (4개):**
- syllable_listen_merge_game
- syllable_drop_game
- syllable_replace_game
- syllable_reverse_game

**4단계 (4개):**
- phoneme_deletion_game
- phoneme_addition_game
- nonword_repetition_game
- word_span_game

**처리 방법:**
- 폴더 이동: `lib/features/training/presentation/modules/_archived/`
- 또는 주석 처리하여 보관

---

## 🔄 이동/재분류 (1개)

| 게임 | 원래 위치 | 새 위치 | 이유 |
|------|-----------|---------|------|
| digit_span_game | phonological4 | working_memory | 작업 기억 능력 측정에 더 적합 |

---

## 🚀 구현 로드맵

### Phase 1: 기존 게임 JSON 전환 (우선순위)

**Week 1-2 (10개):**
- P-02 different_sound_game
- P-03 rhythm_follow_game
- P-04 rhyme_game
- P-06 syllable_merge_game
- P-07 syllable_split_game
- P-08 onset_separation_game
- P-09 phoneme_synthesis_game
- P-10 phoneme_substitution_game
- A-01 animal_sound_story_game
- A-02 instrument_sequence_game

**Week 3-4 (10개):**
- A-03 rhythm_pattern_game
- A-04 simon_says_game
- A-05 sound_rule_game
- V-01 ~ V-06 (시각 처리 6개)

**Week 5-6 (12개):**
- WM-02 ~ WM-06 (작업 기억 5개)
- AT-01 ~ AT-05 (주의력 5개)

---

### Phase 2: 신규 게임 구현

**우선순위 1 (쉬운 것부터 - Week 7):**
- A-08 volume_comparison_game
- A-10 environmental_sound_game
- V-09 visual_tracking_game
- AT-10 go_no_go_basic_game

**우선순위 2 (중간 - Week 8-9):**
- A-07 pitch_discrimination_game
- V-07 visual_closure_game
- V-10 pattern_completion_game
- WM-09 location_memory_game
- AT-06 selective_attention_game
- AT-09 visual_search_game

**우선순위 3 (복잡 - Week 10-12):**
- A-06 sound_sequence_memory_game
- A-09 tempo_sequence_game
- V-08 figure_ground_game
- WM-07 dual_task_game
- WM-08 updating_memory_game
- WM-10 complex_span_game
- AT-07 divided_attention_game
- AT-08 sustained_attention_game

---

## 📁 파일 구조 재정리

### 현재 구조
```
lib/features/training/presentation/modules/
├── phonological/     (6개)
├── phonological2/    (5개)
├── phonological3/    (7개)
├── phonological4/    (7개)
├── auditory/         (5개)
├── visual/           (6개)
├── working_memory/   (5개)
└── attention/        (5개)
```

### 제안 구조 (깔끔하게)
```
lib/features/training/presentation/modules/
├── phonological/     (10개 확정)
│   ├── same_sound_game.dart
│   ├── different_sound_game.dart
│   ├── ... (총 10개)
│   └── _v2/ (JSON 기반)
│       ├── same_sound_game_v2.dart
│       └── syllable_clap_game_v2.dart
├── auditory/         (10개)
├── visual/           (10개)
├── working_memory/   (10개)
├── attention/        (10개)
└── _archived/        (보류된 15개)
    └── phonological_extras/
        ├── emotion_detect_game.dart
        └── ...
```

---

## 📈 문항 제작 계획

### 단계별 목표

**MVP (현재):**
- 3개 게임 × 평균 7개 = 21개 문항

**Beta (2주 후):**
- 10개 게임 × 50개 = 500개 문항

**정식 출시 (2개월):**
- 50개 게임 × 100개 = 5,000개 문항

**완전체 (6개월):**
- 50개 게임 × 300개 = 15,000개 문항

---

## 🎯 다음 단계

### 즉시 작업 (이번 주)

1. ✅ 50개 게임 확정 (완료)
2. ⏳ 보류 게임 폴더 이동
3. ⏳ digit_span_game을 working_memory로 이동
4. ⏳ 우선순위 1 게임 5개 JSON 전환 시작

### 다음 작업 순서

**A. 폴더 정리 및 게임 이동/보류**  
**B. 우선순위 높은 게임 5~10개 JSON 전환**  
**C. 신규 게임 우선순위 1 구현 (4개)**  
**D. 전체 게임 JSON 전환 완료**

---

**어떤 것부터 시작할까요?** 🚀

**추천:** B (우선순위 높은 기존 게임 5개 JSON 전환)

---

**작성일:** 2025-12-06  
**상태:** ✅ 50개 게임 확정 완료  
**다음:** 구현 시작
