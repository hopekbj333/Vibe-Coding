# 📋 구글 시트 템플릿: 리듬 따라하기 (rhythm_follow)

**게임명:** 리듬 따라하기  
**파일명:** `rhythm_follow.json`  
**패턴:** rhythmTap  
**난이도:** ★★☆ (중간)

---

## 🎯 게임 설명

**목표:** 들려주는 리듬 패턴을 듣고 똑같이 터치하기  
**학습 목표:** 청각 처리 - 리듬 패턴 인식 및 재현

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_rhythm_follow_batch1
moduleId	phonological_basic
type	phonological
pattern	rhythmTap
title	리듬 따라하기 - 50문항
instruction	리듬을 잘 듣고 똑같이 터치해보세요
instructionAudioPath	audio/instructions/rhythm_follow.mp3
difficultyLevel	2
version	1.0.0
author	제작자이름
```

---

## 📝 시트 2: Items

**헤더 (첫 번째 행):**

```
itemId	question	questionAudioPath	questionImagePath	correctAnswer	explanation	explanationAudioPath	level	category
```

**샘플 데이터 (10개):**

```
rf_001	리듬을 따라해보세요	audio/rhythms/pattern_2beat.mp3		2	짝짝! 2번이에요!	audio/feedback/rhythm_correct_2.mp3	1	simple
rf_002	리듬을 따라해보세요	audio/rhythms/pattern_3beat.mp3		3	짝짝짝! 3번이에요!	audio/feedback/rhythm_correct_3.mp3	1	simple
rf_003	리듬을 따라해보세요	audio/rhythms/pattern_4beat.mp3		4	짝짝짝짝! 4번이에요!	audio/feedback/rhythm_correct_4.mp3	2	simple
rf_004	리듬을 따라해보세요	audio/rhythms/pattern_slow_fast.mp3		2-1-2	느림-빠름-느림!	audio/feedback/rhythm_correct_varied.mp3	2	varied
rf_005	리듬을 따라해보세요	audio/rhythms/pattern_fast_slow.mp3		1-2-1	빠름-느림-빠름!	audio/feedback/rhythm_correct_varied.mp3	2	varied
rf_006	리듬을 따라해보세요	audio/rhythms/pattern_group_22.mp3		2-2	짝짝... 짝짝!	audio/feedback/rhythm_correct_grouped.mp3	3	grouped
rf_007	리듬을 따라해보세요	audio/rhythms/pattern_group_33.mp3		3-3	짝짝짝... 짝짝짝!	audio/feedback/rhythm_correct_grouped.mp3	3	grouped
rf_008	리듬을 따라해보세요	audio/rhythms/pattern_group_23.mp3		2-3	짝짝... 짝짝짝!	audio/feedback/rhythm_correct_grouped.mp3	3	grouped
rf_009	리듬을 따라해보세요	audio/rhythms/pattern_syncopation.mp3		1-2-1-2	당-당당-당-당당!	audio/feedback/rhythm_correct_complex.mp3	4	complex
rf_010	리듬을 따라해보세요	audio/rhythms/pattern_triplet.mp3		3-3-3	다다다 다다다 다다다!	audio/feedback/rhythm_correct_complex.mp3	4	complex
```

---

## 🎨 시트 3: Options

**참고:** rhythmTap 패턴은 선택지가 없으므로 **Options 시트는 비워두거나 헤더만 작성합니다.**

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**내용:** (비어있음)

---

## 📈 50개 문항 확장 가이드

### 패턴 유형별 분포 (권장)

| 패턴 유형 | 개수 | 난이도 | ID 범위 | 예시 |
|----------|------|--------|---------|------|
| 단순 반복 (Simple) | 15개 | Level 1-2 | rf_001~015 | 짝짝, 짝짝짝 |
| 속도 변화 (Varied) | 10개 | Level 2 | rf_016~025 | 느림-빠름 |
| 그룹핑 (Grouped) | 15개 | Level 3 | rf_026~040 | 짝짝...짝짝 |
| 복잡한 패턴 (Complex) | 10개 | Level 4-5 | rf_041~050 | 싱코페이션 |

### 박자 수별 분포

| 박자 수 | 개수 | 난이도 | 예시 |
|---------|------|--------|------|
| 2박자 | 8개 | Level 1 | 짝짝 |
| 3박자 | 8개 | Level 1-2 | 짝짝짝 |
| 4박자 | 10개 | Level 2 | 짝짝짝짝 |
| 5박자 이상 | 8개 | Level 3 | 짝짝짝짝짝 |
| 그룹/복합 | 16개 | Level 3-5 | 짝짝...짝짝짝 |

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 2~3박자
- 일정한 속도
- 예: 짝-짝 또는 짝-짝-짝

**Level 2 (중간):**
- 4박자
- 약간의 속도 변화
- 예: 짝-짝-짝-짝 또는 느림-빠름

**Level 3 (어려움):**
- 5박자 이상
- 그룹핑 (휴지 포함)
- 예: 짝짝...짝짝짝 (2+3)

**Level 4-5 (매우 어려움):**
- 복잡한 패턴
- 싱코페이션
- 예: 당-당당-당-당당

---

## 🎯 제작 팁

### 1. correctAnswer 형식

**rhythmTap 패턴에서 정답 형식:**

**단순 반복:**
```
correctAnswer: 2
correctAnswer: 3
correctAnswer: 4
```

**그룹핑 (하이픈으로 구분):**
```
correctAnswer: 2-2
correctAnswer: 2-3
correctAnswer: 3-3
```

**복잡한 패턴 (숫자로 표현):**
```
correctAnswer: 1-2-1-2
correctAnswer: 3-3-3
```

### 2. 오디오 제작 가이드

**박자 간격:**
- Level 1: 0.5초 간격
- Level 2: 0.4초 간격
- Level 3: 0.3초 간격 (그룹 사이는 1초)

**음원:**
- 손뼉 소리 (clap.mp3)
- 북 소리 (drum.mp3)
- 탬버린 소리 (tambourine.mp3)

### 3. 시각적 표현 (선택)

**이미지는 선택사항이지만, 있으면 도움:**
- 박자 그림 (점 개수로 표현)
- 예: ●●...●●● (2+3 패턴)

### 4. 피드백

**정답 후 재생할 피드백:**
- 같은 리듬을 한 번 더 재생
- 캐릭터가 박수치는 애니메이션

---

## 💡 리듬 패턴 아이디어

### Simple (단순 반복)

**2박자:**
- 짝 짝
- 당 당

**3박자:**
- 짝 짝 짝
- 당 당 당

**4박자:**
- 짝 짝 짝 짝
- 당 당 당 당

**5박자:**
- 짝 짝 짝 짝 짝

---

### Varied (속도 변화)

**느림-빠름:**
- 짝... 짝짝

**빠름-느림:**
- 짝짝... 짝

**느림-빠름-느림:**
- 짝... 짝짝... 짝

---

### Grouped (그룹핑)

**2+2:**
- 짝짝 ... 짝짝

**3+3:**
- 짝짝짝 ... 짝짝짝

**2+3:**
- 짝짝 ... 짝짝짝

**3+2:**
- 짝짝짝 ... 짝짝

**2+2+2:**
- 짝짝 ... 짝짝 ... 짝짝

---

### Complex (복잡한 패턴)

**싱코페이션:**
- 당 당당 당 당당

**트리플렛:**
- 다다다 다다다 다다다

**폴리리듬:**
- 짝짝짝 동시에 당-당

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 시트 비워두기 (또는 헤더만)
- [ ] itemId 중복 없음 (rf_001~rf_050)
- [ ] correctAnswer 형식 정확 (숫자 또는 하이픈 구분)
- [ ] questionAudioPath에 리듬 오디오
- [ ] 패턴 유형 다양성 확보
- [ ] 난이도 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (rf_011 ~ rf_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/rhythm_follow.json`에 저장
6. ✅ 앱에서 테스트

---

## 🎵 오디오 제작 도구 추천

**무료 도구:**
- Audacity (오디오 편집)
- GarageBand (Mac)
- Online Sequencer (웹)

**리듬 생성:**
- 메트로놈 앱 사용
- 손뼉 직접 녹음
- 리듬 시퀀서 프로그램

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 3-4시간  
**난이도:** ⭐⭐⭐⭐☆ (어려움 - 오디오 제작)
