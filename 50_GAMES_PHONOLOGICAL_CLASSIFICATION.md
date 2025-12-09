# 🎯 50개 게임: 음운인식 vs 음운처리 분류

**작성일:** 2025-12-08  
**목적:** 5개 분야 50개 게임을 음운인식(Phonological Awareness)과 음운처리(Phonological Processing)로 분류  
**기준:** 39개 능력 체계의 Part 1 (음운인식)과 Part 2 (음운처리) 기준

---

## 📊 전체 요약

| 분류 | 게임 수 | 문항 수 | 비율 |
|------|---------|---------|------|
| **음운인식** | 20개 | 387문항 | 58.5% |
| **음운처리** | 30개 | 274문항 | 41.5% |
| **총계** | **50개** | **661문항** | **100%** |

---

## 🎯 음운인식 (Phonological Awareness) - 20개 게임

**정의**: 소리를 인식하고 조작하는 능력 (Part 1에 해당)  
**특징**: 음절/음소 분리, 합성, 변별, 탈락 등의 조작 능력

### 1. Phonological 분야 (10개) - 모두 음운인식

| # | 게임명 | 파일명 | 문항 | 난이도 | 능력 매핑 |
|---|--------|--------|------|--------|----------|
| 1 | 같은 소리 찾기 | `same_sound_game_v2.dart` | 50 | ★☆☆ | 음절 변별 (1.4) |
| 2 | 다른 소리 찾기 | `different_sound_game_v2.dart` | 50 | ★☆☆ | 음절 변별 (1.4) |
| 3 | 박수로 음절 쪼개기 | `syllable_clap_game_v2.dart` | 50 | ★★☆ | 음절 분절 (1.2) |
| 4 | 각운 찾기 | `rhyme_game_v2.dart` | 50 | ★★☆ | 음절 변별 (1.4) |
| 5 | 음절 합성 | `syllable_merge_game_v2.dart` | 50 | ★★★ | 음절 합성 (1.3) |
| 6 | 음절 분리 | `syllable_split_game_v2.dart` | 50 | ★★★ | 음절 분절 (1.2) |
| 7 | 리듬 따라하기 | `rhythm_follow_game_v2.dart` | 50 | ★★☆ | 음절 수 세기 (1.1) |
| 8 | 초성 분리 | `onset_separation_game_v2.dart` | 50 | ★★★ | 초성 인식 (2.1) |
| 9 | 음소 합성 | `phoneme_synthesis_game_v2.dart` | 50 | ★★★ | 음소 합성 (3.2) |
| 10 | 음소 대치 | `phoneme_substitution_game_v2.dart` | 2 | ★★★ | 음소 대치 (3.3) |

**소계: 10개 게임, 452문항**

---

### 2. Auditory 분야 중 음운인식 관련 (10개)

| # | 게임명 | 파일명 | 문항 | 난이도 | 능력 매핑 |
|---|--------|--------|------|--------|----------|
| 1 | 동물 소리 이야기 | `animal_sound_story_game_v2.dart` | 50 | ★☆☆ | 환경음 식별 (0.1) |
| 2 | 소리 규칙 찾기 | `sound_rule_game_v2.dart` | 10 | ★★★ | 음소 변별 (3.4) |
| 3 | 음높이 구별 | `pitch_discrimination_game_v2.dart` | 3 | ★★☆ | 소리 크기/높이 변별 (0.2) |
| 4 | 소리 크기 비교 | `volume_comparison_game_v2.dart` | 5 | ★☆☆ | 소리 크기/높이 변별 (0.2) |
| 5 | 환경음 식별 | `environmental_sound_game_v2.dart` | 6 | ★★☆ | 환경음 식별 (0.1) |
| 6 | 악기 순서 기억 | `instrument_sequence_game_v2.dart` | 3 | ★★☆ | 음절 수 세기 (1.1) |
| 7 | 리듬 패턴 | `rhythm_pattern_game_v2.dart` | 3 | ★★☆ | 음절 수 세기 (1.1) |
| 8 | 사이먼 가라사대 | `simon_says_game_v2.dart` | 2 | ★★★ | 음절 분절 (1.2) |
| 9 | 소리 순서 기억 | `sound_sequence_memory_game_v2.dart` | 2 | ★★☆ | 음절 수 세기 (1.1) |
| 10 | 빠르기 순서 | `tempo_sequence_game_v2.dart` | 1 | ★★★ | 음절 변별 (1.4) |

**소계: 10개 게임, 85문항**

---

**음운인식 총계: 20개 게임, 537문항**

---

## ⚡ 음운처리 (Phonological Processing) - 30개 게임

**정의**: 음운 기억과 빠른 이름 대기 능력 (Part 2에 해당)  
**특징**: 소리 정보를 기억하고 빠르게 인출하는 능력

### 1. Working Memory 분야 중 음운처리 관련 (10개)

| # | 게임명 | 파일명 | 문항 | 난이도 | 능력 매핑 |
|---|--------|--------|------|--------|----------|
| 1 | 거꾸로 말하기 | `reverse_speak_game_v2.dart` | 2 | ★★★ | 비단어 반복 (PM2) |
| 2 | 숫자 외우기 | `digit_span_game_v2.dart` | 2 | ★★☆ | 숫자 폭 (PM3) |
| 3 | 카드 짝 맞추기 | `card_match_game_v2.dart` | 16 | ★★☆ | 단어 반복 (PM1) |
| 4 | 지시 따르기 | `instruction_follow_game_v2.dart` | 2 | ★★☆ | 단어 반복 (PM1) |
| 5 | N-Back | `n_back_game_v2.dart` | 2 | ★★★ | 음운 기억 (PM1-3) |
| 6 | 거꾸로 터치하기 | `reverse_touch_game_v2.dart` | 2 | ★★☆ | 음운 기억 (PM1-3) |
| 7 | 이중 과제 | `dual_task_game_v2.dart` | 1 | ★★★ | 음운 기억 (PM1-3) |
| 8 | 위치 기억 | `location_memory_game_v2.dart` | 1 | ★★☆ | 음운 기억 (PM1-3) |
| 9 | 업데이트 기억 | `updating_memory_game_v2.dart` | 1 | ★★★ | 음운 기억 (PM1-3) |
| 10 | 복합 기억 폭 | `complex_span_game_v2.dart` | 1 | ★★★ | 음운 기억 (PM1-3) |

**소계: 10개 게임, 30문항**

---

### 2. Visual 분야 중 음운처리 관련 (10개) - RAN 관련

| # | 게임명 | 파일명 | 문항 | 난이도 | 능력 매핑 |
|---|--------|--------|------|--------|----------|
| 1 | 숨은 글자 찾기 | `hidden_letter_game_v2.dart` | 6 | ★★☆ | 문자 빠른 이름대기 (RAN4) |
| 2 | 글자 방향 구별 | `letter_direction_game_v2.dart` | 50 | ★★☆ | 문자 빠른 이름대기 (RAN4) |
| 3 | 거울 대칭 | `mirror_symmetry_game_v2.dart` | 10 | ★★☆ | 시각 처리 + RAN |
| 4 | 퍼즐 | `puzzle_game_v2.dart` | 1 | ★★★ | 시각 처리 + RAN |
| 5 | 도형 회전 | `shape_rotation_game_v2.dart` | 1 | ★★★ | 시각 처리 + RAN |
| 6 | 틀린 그림 찾기 | `spot_difference_game_v2.dart` | 1 | ★★☆ | 사물 빠른 이름대기 (RAN1) |
| 7 | 부분으로 전체 추측 | `visual_closure_game_v2.dart` | 1 | ★★☆ | 사물 빠른 이름대기 (RAN1) |
| 8 | 배경-전경 구별 | `figure_ground_game_v2.dart` | 1 | ★★★ | 사물 빠른 이름대기 (RAN1) |
| 9 | 시각 추적 | `visual_tracking_game_v2.dart` | 6 | ★☆☆ | 색상 빠른 이름대기 (RAN2) |
| 10 | 패턴 완성 | `pattern_completion_game_v2.dart` | 3 | ★★☆ | 시각 처리 + RAN |

**소계: 10개 게임, 80문항**

---

### 3. Attention 분야 중 음운처리 관련 (10개) - RAN 속도 관련

| # | 게임명 | 파일명 | 문항 | 난이도 | 능력 매핑 |
|---|--------|--------|------|--------|----------|
| 1 | 청각 주의력 | `auditory_attention_game_v2.dart` | 1 | ★★☆ | 음운 기억 (PM1-3) |
| 2 | 흐름 추적 | `flow_tracking_game_v2.dart` | 1 | ★★★ | 빠른 이름 대기 (RAN) |
| 3 | 집중력 마라톤 | `focus_marathon_game_v2.dart` | 1 | ★★★ | 빠른 이름 대기 (RAN) |
| 4 | 스트룹 과제 | `stroop_game_v2.dart` | 1 | ★★★ | 빠른 이름 대기 (RAN) |
| 5 | 목표 찾기 | `target_hunt_game_v2.dart` | 1 | ★★☆ | 빠른 이름 대기 (RAN) |
| 6 | Go/No-Go 기본 | `go_no_go_basic_game_v2.dart` | 5 | ★☆☆ | 빠른 이름 대기 (RAN) |
| 7 | 선택적 주의 | `selective_attention_game_v2.dart` | 1 | ★★☆ | 빠른 이름 대기 (RAN) |
| 8 | 분할 주의 | `divided_attention_game_v2.dart` | 1 | ★★★ | 빠른 이름 대기 (RAN) |
| 9 | 지속적 주의 | `sustained_attention_game_v2.dart` | 1 | ★★☆ | 빠른 이름 대기 (RAN) |
| 10 | 시각 탐색 | `visual_search_game_v2.dart` | 1 | ★★☆ | 빠른 이름 대기 (RAN) |

**소계: 10개 게임, 14문항**

---

**음운처리 총계: 30개 게임, 124문항**

---

## 📋 분류 기준 설명

### 음운인식 (Phonological Awareness)
- **정의**: 소리를 인식하고 조작하는 능력
- **특징**: 
  - 음절/음소 분리, 합성, 변별, 탈락 등의 조작 능력
  - Part 1 능력에 해당 (15개 능력)
- **예시**: "가방"을 "가"와 "방"으로 나누기, "가"와 "방"을 합쳐서 "가방" 만들기

### 음운처리 (Phonological Processing)
- **정의**: 음운 기억과 빠른 이름 대기 능력
- **특징**:
  - **음운 기억(Phonological Memory)**: 소리 정보를 기억하고 유지하는 능력
  - **빠른 이름 대기(RAN)**: 시각적 자극을 빠르게 인식하고 명명하는 능력
  - Part 2 능력에 해당 (7개 능력)
- **예시**: 단어를 듣고 따라 말하기, 그림을 보고 빠르게 이름 말하기

---

## 🎯 39개 능력 체계와의 매핑

### Part 1: 음운 인식 (15개 능력) → 음운인식 게임 20개
- Stage 0: 기초 청각 (2개) → Auditory 게임 5개
- Stage 1: 음절 인식 (5개) → Phonological 게임 7개
- Stage 2: 본체-종성 인식 (4개) → Phonological 게임 1개
- Stage 3: 음소 인식 (4개) → Phonological 게임 2개

### Part 2: 음운 처리 (7개 능력) → 음운처리 게임 30개
- 음운 기억 (3개) → Working Memory 게임 10개
- 빠른 이름 대기 (4개) → Visual + Attention 게임 20개

---

## 💡 주요 인사이트

1. **음운인식 게임 (20개)**: 소리를 조작하는 능력에 집중
   - Phonological 분야 전체 + Auditory 분야 일부

2. **음운처리 게임 (30개)**: 소리 정보를 기억하고 빠르게 인출하는 능력에 집중
   - Working Memory 분야 전체 + Visual/Attention 분야 일부

3. **균형잡힌 구성**: 음운인식 20개 vs 음운처리 30개로 적절한 비율

4. **실용적 분류**: 이론적 구분을 실제 게임 구현에 적용

---

**마지막 업데이트**: 2025-12-08

