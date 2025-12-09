# 📊 현재 게임 목록 정리 (47개)

**작성일:** 2025-12-06  
**목적:** 5개 분야 × 10개 게임 = 50개 표준 구조 만들기

---

## 🎯 분야별 현황

| 분야 | 영문명 | 현재 개수 | 목표 개수 | 작업 |
|------|--------|-----------|-----------|------|
| 음운 인식 | Phonological | **25개** | 10개 | ✂️ 15개 축소 |
| 청각 처리 | Auditory | 5개 | 10개 | ➕ 5개 추가 |
| 시각 처리 | Visual | 6개 | 10개 | ➕ 4개 추가 |
| 작업 기억 | Working Memory | 5개 | 10개 | ➕ 5개 추가 |
| 주의력 | Attention | 5개 | 10개 | ➕ 5개 추가 |
| **총계** | | **46개** | **50개** | **-15개, +19개** |

---

## 1️⃣ Phonological (음운 인식) - 25개 → 10개 선정 필요

### 1-1단계 (6개)
1. `same_sound_game.dart` - 같은 소리 찾기 ⭐ **필수**
2. `different_sound_game.dart` - 다른 소리 찾기 ⭐ **필수**
3. `emotion_detect_game.dart` - 감정 감지
4. `intonation_game.dart` - 억양/강세 식별
5. `rhythm_follow_game.dart` - 리듬 따라하기 ⭐ **필수**
6. `tempo_compare_game.dart` - 빠르기 비교

### 1-2단계 (5개)
7. `alliteration_game.dart` - 두운(첫소리) 찾기 ⭐ **필수**
8. `rhyme_game.dart` - 각운(끝소리) 찾기 ⭐ **필수**
9. `word_boundary_game.dart` - 단어 경계 인식
10. `word_chain_game.dart` - 끝말잇기
11. `word_count_game.dart` - 단어 개수 세기

### 1-3단계 (7개)
12. `syllable_clap_game.dart` - 박수로 음절 쪼개기 ⭐ **필수**
13. `syllable_split_game.dart` - 음절 분리
14. `syllable_merge_game.dart` - 음절 합성 ⭐ **필수**
15. `syllable_listen_merge_game.dart` - 듣고 음절 합치기
16. `syllable_drop_game.dart` - 음절 탈락
17. `syllable_replace_game.dart` - 음절 대치
18. `syllable_reverse_game.dart` - 음절 뒤집기

### 1-4단계 (7개)
19. `onset_separation_game.dart` - 초성 분리 ⭐ **필수**
20. `phoneme_synthesis_game.dart` - 음소 합성 ⭐ **필수**
21. `phoneme_deletion_game.dart` - 음소 탈락
22. `phoneme_addition_game.dart` - 음소 추가
23. `phoneme_substitution_game.dart` - 음소 대치 ⭐ **필수**
24. `nonword_repetition_game.dart` - 비단어 따라말하기
25. `word_span_game.dart` - 단어 폭 기억
26. `digit_span_game.dart` - 숫자 폭 기억

### 🎯 선정 기준 (10개 선정)

**난이도별 균형:**
- 1단계 (쉬움): 2~3개
- 2단계 (중간): 3~4개
- 3단계 (음절): 2~3개
- 4단계 (음소): 2개

**추천 10개:**
1. ⭐ same_sound_game (같은 소리 찾기)
2. ⭐ different_sound_game (다른 소리 찾기)
3. ⭐ rhythm_follow_game (리듬 따라하기)
4. ⭐ alliteration_game (두운 찾기)
5. ⭐ rhyme_game (각운 찾기)
6. ⭐ syllable_clap_game (음절 쪼개기)
7. ⭐ syllable_merge_game (음절 합성)
8. ⭐ onset_separation_game (초성 분리)
9. ⭐ phoneme_synthesis_game (음소 합성)
10. ⭐ phoneme_substitution_game (음소 대치)

---

## 2️⃣ Auditory (청각 처리) - 5개 → 10개 (5개 추가)

### 현재 5개:
1. `animal_sound_story_game.dart` - 동물 소리 이야기
2. `instrument_sequence_game.dart` - 악기 순서 기억
3. `rhythm_pattern_game.dart` - 리듬 패턴
4. `simon_says_game.dart` - 사이먼 가라사대
5. `sound_rule_game.dart` - 소리 규칙 찾기

### 추가 필요 5개:
6. 📝 `sound_sequence_memory_game` - 소리 순서 기억 (난이도 ↑)
7. 📝 `pitch_discrimination_game` - 음높이 구별
8. 📝 `volume_comparison_game` - 크기 비교
9. 📝 `tempo_sequence_game` - 빠르기 순서
10. 📝 `environmental_sound_game` - 환경음 식별

---

## 3️⃣ Visual (시각 처리) - 6개 → 10개 (4개 추가)

### 현재 6개:
1. `hidden_letter_game.dart` - 숨은 글자 찾기
2. `letter_direction_game.dart` - 글자 방향 구별
3. `mirror_symmetry_game.dart` - 좌우 대칭
4. `puzzle_game.dart` - 퍼즐
5. `shape_rotation_game.dart` - 도형 회전
6. `spot_difference_game.dart` - 틀린 그림 찾기

### 추가 필요 4개:
7. 📝 `visual_closure_game` - 부분으로 전체 추측
8. 📝 `figure_ground_game` - 배경-전경 구별
9. 📝 `visual_tracking_game` - 시각 추적
10. 📝 `pattern_completion_game` - 패턴 완성

---

## 4️⃣ Working Memory (작업 기억) - 5개 → 10개 (5개 추가)

### 현재 5개:
1. `card_match_game.dart` - 카드 짝 맞추기
2. `instruction_follow_game.dart` - 지시 따르기
3. `n_back_game.dart` - N-back
4. `reverse_speak_game.dart` - 거꾸로 말하기
5. `reverse_touch_game.dart` - 거꾸로 터치하기

### 추가 필요 5개:
6. 📝 `dual_task_game` - 이중 과제
7. 📝 `updating_memory_game` - 업데이트 기억
8. 📝 `mental_calculation_game` - 간단한 암산
9. 📝 `location_memory_game` - 위치 기억
10. 📝 `complex_span_game` - 복합 기억 폭

---

## 5️⃣ Attention (주의력) - 5개 → 10개 (5개 추가)

### 현재 5개:
1. `auditory_attention_game.dart` - 청각 주의력
2. `flow_tracking_game.dart` - 흐름 추적
3. `focus_marathon_game.dart` - 집중력 마라톤
4. `stroop_game.dart` - 스트룹 과제
5. `target_hunt_game.dart` - 목표 찾기

### 추가 필요 5개:
6. 📝 `selective_attention_game` - 선택적 주의
7. 📝 `divided_attention_game` - 분할 주의
8. 📝 `sustained_attention_game` - 지속적 주의
9. 📝 `visual_search_game` - 시각 탐색
10. 📝 `alertness_game` - 각성 수준

---

## 📋 작업 우선순위

### Phase 1: 정리 (1일)
- ✅ 현재 게임 목록 작성 (완료)
- ⏳ Phonological 10개 선정
- ⏳ 나머지 분야별 10개 확정

### Phase 2: 부족한 게임 설계 (2일)
- 19개 신규 게임 설계
- 간단한 프로토타입 구현

### Phase 3: JSON 전환 (3일)
- 50개 게임 모두 JSON 기반으로
- 각 게임당 10~20개 샘플 문항

### Phase 4: 대량 제작 (1주)
- 구글 시트로 각 게임당 50~100개
- 총 2,500~5,000개 문항

---

## 🤔 중요한 결정 사항

### Phonological 25개 → 10개 축소 시:

**옵션 A: 난이도별 균등 선택**
- 1단계: 2개
- 2단계: 2개
- 3단계: 3개
- 4단계: 3개

**옵션 B: 핵심 기능 중심 선택** (추천)
- 소리 변별: 2개 (same, different)
- 운율 인식: 2개 (rhythm, alliteration/rhyme)
- 음절 조작: 3개 (clap, merge, split)
- 음소 조작: 3개 (onset, synthesis, substitution)

---

**다음 단계:** Phonological 10개를 정확히 선정하고 나머지는 보류 처리

**계속 진행할까요?** 🚀
