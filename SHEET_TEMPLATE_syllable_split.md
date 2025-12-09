# 📋 구글 시트 템플릿: 음절 분리 (syllable_split)

**게임명:** 음절 분리  
**파일명:** `syllable_split.json`  
**패턴:** multipleChoice  
**난이도:** ★★★ (어려움)

---

## 🎯 게임 설명

**목표:** 단어를 듣고 올바르게 쪼개진 음절 선택하기  
**학습 목표:** 음절 분리 - 하나의 단어를 음절로 나누기

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_syllable_split_batch1
moduleId	phonological_advanced
type	phonological
pattern	multipleChoice
title	음절 분리 - 50문항
instruction	단어를 쪼개면 어떻게 될까요?
instructionAudioPath	audio/instructions/syllable_split.mp3
difficultyLevel	3
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
ss_001	'사과'를 쪼개면?	audio/words/apple.mp3	images/fruits/apple.png	opt2	맞아요! '사-과'예요!	audio/feedback/split_correct_1.mp3	1	fruit
ss_002	'바나나'를 쪼개면?	audio/words/banana.mp3	images/fruits/banana.png	opt3	맞아요! '바-나-나'예요!	audio/feedback/split_correct_2.mp3	2	fruit
ss_003	'강아지'를 쪼개면?	audio/words/dog.mp3	images/animals/dog.png	opt1	맞아요! '강-아-지'예요!	audio/feedback/split_correct_3.mp3	2	animal
ss_004	'코끼리'를 쪼개면?	audio/words/elephant.mp3	images/animals/elephant.png	opt2	맞아요! '코-끼-리'예요!	audio/feedback/split_correct_4.mp3	2	animal
ss_005	'자동차'를 쪼개면?	audio/words/car.mp3	images/vehicles/car.png	opt3	맞아요! '자-동-차'예요!	audio/feedback/split_correct_5.mp3	2	vehicle
ss_006	'비행기'를 쪼개면?	audio/words/plane.mp3	images/vehicles/plane.png	opt1	맞아요! '비-행-기'예요!	audio/feedback/split_correct_6.mp3	2	vehicle
ss_007	'무지개'를 쪼개면?	audio/words/rainbow.mp3	images/nature/rainbow.png	opt2	맞아요! '무-지-개'예요!	audio/feedback/split_correct_7.mp3	3	nature
ss_008	'나비'를 쪼개면?	audio/words/butterfly.mp3	images/animals/butterfly.png	opt3	맞아요! '나-비'예요!	audio/feedback/split_correct_8.mp3	1	animal
ss_009	'연필통'을 쪼개면?	audio/words/pencil_case.mp3	images/objects/pencil_case.png	opt1	맞아요! '연-필-통'이에요!	audio/feedback/split_correct_9.mp3	3	object
ss_010	'컴퓨터'를 쪼개면?	audio/words/computer.mp3	images/objects/computer.png	opt2	맞아요! '컴-퓨-터'예요!	audio/feedback/split_correct_10.mp3	3	object
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (각 문항당 3개 선택지 - 올바른 분리와 잘못된 분리):**

```
ss_001	opt1	사 - 가		audio/syllables/sa_ga.mp3	{"syllables":["사","가"],"isCorrect":false}
ss_001	opt2	사 - 과		audio/syllables/sa_gwa.mp3	{"syllables":["사","과"],"isCorrect":true}
ss_001	opt3	사과 (안쪼개짐)		audio/words/apple.mp3	{"syllables":["사과"],"isCorrect":false}
ss_002	opt1	바 - 나 - 나		audio/syllables/ba_na_na.mp3	{"syllables":["바","나","나"],"isCorrect":true}
ss_002	opt2	바나 - 나		audio/syllables/bana_na.mp3	{"syllables":["바나","나"],"isCorrect":false}
ss_002	opt3	바 - 나나		audio/syllables/ba_nana.mp3	{"syllables":["바","나나"],"isCorrect":false}
ss_003	opt1	강 - 아 - 지		audio/syllables/gang_a_ji.mp3	{"syllables":["강","아","지"],"isCorrect":true}
ss_003	opt2	강아 - 지		audio/syllables/ganga_ji.mp3	{"syllables":["강아","지"],"isCorrect":false}
ss_003	opt3	강 - 아지		audio/syllables/gang_aji.mp3	{"syllables":["강","아지"],"isCorrect":false}
ss_004	opt1	코 - 끼 - 리		audio/syllables/ko_kki_ri.mp3	{"syllables":["코","끼","리"],"isCorrect":true}
ss_004	opt2	코끼 - 리		audio/syllables/kokki_ri.mp3	{"syllables":["코끼","리"],"isCorrect":false}
ss_004	opt3	코 - 끼리		audio/syllables/ko_kkiri.mp3	{"syllables":["코","끼리"],"isCorrect":false}
ss_005	opt1	자 - 동차		audio/syllables/ja_dongcha.mp3	{"syllables":["자","동차"],"isCorrect":false}
ss_005	opt2	자동 - 차		audio/syllables/jadong_cha.mp3	{"syllables":["자동","차"],"isCorrect":false}
ss_005	opt3	자 - 동 - 차		audio/syllables/ja_dong_cha.mp3	{"syllables":["자","동","차"],"isCorrect":true}
ss_006	opt1	비 - 행 - 기		audio/syllables/bi_haeng_gi.mp3	{"syllables":["비","행","기"],"isCorrect":true}
ss_006	opt2	비행 - 기		audio/syllables/bihaeng_gi.mp3	{"syllables":["비행","기"],"isCorrect":false}
ss_006	opt3	비 - 행기		audio/syllables/bi_haenggi.mp3	{"syllables":["비","행기"],"isCorrect":false}
ss_007	opt1	무지 - 개		audio/syllables/muji_gae.mp3	{"syllables":["무지","개"],"isCorrect":false}
ss_007	opt2	무 - 지 - 개		audio/syllables/mu_ji_gae.mp3	{"syllables":["무","지","개"],"isCorrect":true}
ss_007	opt3	무 - 지개		audio/syllables/mu_jigae.mp3	{"syllables":["무","지개"],"isCorrect":false}
ss_008	opt1	나 - 비		audio/syllables/na_bi.mp3	{"syllables":["나","비"],"isCorrect":true}
ss_008	opt2	나비 (안쪼개짐)		audio/words/butterfly.mp3	{"syllables":["나비"],"isCorrect":false}
ss_008	opt3	나 - 비이		audio/syllables/na_bii.mp3	{"syllables":["나","비이"],"isCorrect":false}
ss_009	opt1	연 - 필 - 통		audio/syllables/yeon_pil_tong.mp3	{"syllables":["연","필","통"],"isCorrect":true}
ss_009	opt2	연필 - 통		audio/syllables/yeonpil_tong.mp3	{"syllables":["연필","통"],"isCorrect":false}
ss_009	opt3	연 - 필통		audio/syllables/yeon_piltong.mp3	{"syllables":["연","필통"],"isCorrect":false}
ss_010	opt1	컴 - 퓨터		audio/syllables/keom_pyuteo.mp3	{"syllables":["컴","퓨터"],"isCorrect":false}
ss_010	opt2	컴 - 퓨 - 터		audio/syllables/keom_pyu_teo.mp3	{"syllables":["컴","퓨","터"],"isCorrect":true}
ss_010	opt3	컴퓨 - 터		audio/syllables/keopyu_teo.mp3	{"syllables":["컴퓨","터"],"isCorrect":false}
```

---

## 📈 50개 문항 확장 가이드

### 음절 수별 분포 (권장)

| 음절 수 | 개수 | 난이도 | ID 범위 | 예시 |
|---------|------|--------|---------|------|
| 2음절 | 15개 | Level 1-2 | ss_001~015 | 사과, 나비 |
| 3음절 | 25개 | Level 2-3 | ss_016~040 | 바나나, 강아지 |
| 4음절 | 8개 | Level 3-4 | ss_041~048 | 자동판매기 |
| 5음절 | 2개 | Level 4-5 | ss_049~050 | 국립중앙박물관 |

### 카테고리별 분포

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| fruit (과일) | 10개 | 사과, 바나나, 딸기 |
| animal (동물) | 12개 | 강아지, 코끼리, 나비 |
| vehicle (탈것) | 8개 | 자동차, 비행기, 기차 |
| nature (자연) | 10개 | 무지개, 구름, 별 |
| object (사물) | 10개 | 연필통, 컴퓨터, 책 |

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 2음절 단어
- 명확한 분리
- 예: 사과 → 사-과

**Level 2 (중간):**
- 3음절 단어
- 일상적인 단어
- 예: 바나나 → 바-나-나

**Level 3 (어려움):**
- 3~4음절 복합어
- 혼동 가능한 분리
- 예: 무지개 → 무-지-개 (X 무지-개)

**Level 4-5 (매우 어려움):**
- 4~5음절 긴 단어
- 복잡한 복합어
- 예: 컴퓨터 → 컴-퓨-터 (X 컴퓨-터)

---

## 🎯 제작 팁

### 1. 오답 선택지 전략

**Type A: 잘못 붙인 음절**
```
바나나 → 바나-나 (X)
바나나 → 바-나나 (X)
바나나 → 바-나-나 (O)
```

**Type B: 안 쪼개진 것**
```
사과 → 사과 (X)
사과 → 사-과 (O)
```

**Type C: 잘못 쪼갠 것**
```
강아지 → 강-아-지이 (X)
강아지 → 강-아-지 (O)
```

### 2. label 표기 방법

**권장 형식:**
```
사 - 과
강 - 아 - 지
안쪼개짐 (1음절 단어의 경우)
```

### 3. audioPath 중요

**각 선택지마다 오디오 필요:**
- 올바른 분리 소리
- 잘못된 분리 소리

### 4. 정답 위치 균등

**50개 문항에서:**
- opt1이 정답: 약 17개
- opt2가 정답: 약 17개
- opt3이 정답: 약 16개

---

## 💡 음절 분리 규칙

### 한글 음절 원칙

**기본 규칙:**
- 한글 1글자 = 1음절
- 받침도 같은 음절

**예시:**
```
사과 = 사 + 과 = 2음절
강아지 = 강 + 아 + 지 = 3음절
```

### 자주 틀리는 경우

**복합어:**
```
자동차 ≠ 자동-차 (X)
자동차 = 자-동-차 (O)

연필통 ≠ 연필-통 (X)
연필통 = 연-필-통 (O)
```

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 150개 (50×3) 작성 완료
- [ ] itemId 중복 없음 (ss_001~ss_050)
- [ ] 각 선택지에 오디오 포함
- [ ] correctAnswer 정확 (올바른 분리)
- [ ] 오답 선택지 다양 (Type A/B/C)
- [ ] 정답 위치 균등 분포
- [ ] 음절 수 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (ss_011 ~ ss_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/syllable_split.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 3-4시간  
**난이도:** ⭐⭐⭐⭐☆ (어려움)
