# 📋 구글 시트 템플릿: 각운 찾기 (rhyme)

**게임명:** 각운 찾기  
**파일명:** `rhyme.json`  
**패턴:** multipleChoice  
**난이도:** ★★☆ (중간)

---

## 🎯 게임 설명

**목표:** 제시된 단어와 끝소리가 같은 단어 찾기  
**학습 목표:** 음운 인식 - 각운(rhyme) 인식

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_rhyme_batch1
moduleId	phonological_basic
type	phonological
pattern	multipleChoice
title	각운 찾기 - 50문항
instruction	단어를 듣고 끝소리가 같은 것을 찾으세요
instructionAudioPath	audio/instructions/rhyme.mp3
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
rh_001	'사과'와 끝소리가 같은 것은?	audio/words/apple.mp3	images/fruits/apple.png	opt2	'바다'도 '-다'로 끝나요!	audio/feedback/rhyme_correct_1.mp3	1	simple
rh_002	'나무'와 끝소리가 같은 것은?	audio/words/tree.mp3	images/nature/tree.png	opt3	'누구'도 '-구'로 끝나요!	audio/feedback/rhyme_correct_2.mp3	1	simple
rh_003	'고양이'와 끝소리가 같은 것은?	audio/words/cat.mp3	images/animals/cat.png	opt1	'강아지'도 '-지'로 끝나요!	audio/feedback/rhyme_correct_3.mp3	2	animal
rh_004	'바나나'와 끝소리가 같은 것은?	audio/words/banana.mp3	images/fruits/banana.png	opt2	'하나'도 '-나'로 끝나요!	audio/feedback/rhyme_correct_4.mp3	2	simple
rh_005	'공책'과 끝소리가 같은 것은?	audio/words/notebook.mp3	images/objects/notebook.png	opt3	'식빵'도 '-앵'으로 끝나요!	audio/feedback/rhyme_correct_5.mp3	2	object
rh_006	'자동차'와 끝소리가 같은 것은?	audio/words/car.mp3	images/vehicles/car.png	opt1	'오토바이'... 아니 '차'는 '-차'로 끝나요!	audio/feedback/rhyme_correct_6.mp3	3	vehicle
rh_007	'하늘'과 끝소리가 같은 것은?	audio/words/sky.mp3	images/nature/sky.png	opt2	'구름'... 아니죠, 비슷한 소리를 찾아요	audio/feedback/rhyme_correct_7.mp3	3	nature
rh_008	'연필'과 끝소리가 같은 것은?	audio/words/pencil.mp3	images/objects/pencil.png	opt3	'지우개'... 아니 '-필'로 끝나는...	audio/feedback/rhyme_correct_8.mp3	3	object
rh_009	'토끼'와 끝소리가 같은 것은?	audio/words/rabbit.mp3	images/animals/rabbit.png	opt1	'여우기'... 음, '-끼'로 끝나요	audio/feedback/rhyme_correct_9.mp3	3	animal
rh_010	'별'과 끝소리가 같은 것은?	audio/words/star.mp3	images/nature/star.png	opt2	'달'도 '-ㄹ'로 끝나요!	audio/feedback/rhyme_correct_10.mp3	2	nature
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (각 문항당 3개 선택지):**

```
rh_001	opt1	🐕 강아지	images/animals/dog.png	audio/words/dog.mp3	{"rhymePattern":"지","correctRhyme":false}
rh_001	opt2	🌊 바다	images/nature/sea.png	audio/words/sea.mp3	{"rhymePattern":"다","correctRhyme":true}
rh_001	opt3	🏀 공	images/objects/ball.png	audio/words/ball.mp3	{"rhymePattern":"공","correctRhyme":false}
rh_002	opt1	🌸 꽃	images/nature/flower.png	audio/words/flower.mp3	{"rhymePattern":"꽃","correctRhyme":false}
rh_002	opt2	☀️ 해	images/nature/sun.png	audio/words/sun.mp3	{"rhymePattern":"해","correctRhyme":false}
rh_002	opt3	❓ 누구	images/icons/who.png	audio/words/who.mp3	{"rhymePattern":"구","correctRhyme":true}
rh_003	opt1	🐕 강아지	images/animals/dog.png	audio/words/dog.mp3	{"rhymePattern":"지","correctRhyme":true}
rh_003	opt2	🐰 토끼	images/animals/rabbit.png	audio/words/rabbit.mp3	{"rhymePattern":"끼","correctRhyme":false}
rh_003	opt3	🐘 코끼리	images/animals/elephant.png	audio/words/elephant.mp3	{"rhymePattern":"리","correctRhyme":false}
rh_004	opt1	🌙 달	images/nature/moon.png	audio/words/moon.mp3	{"rhymePattern":"달","correctRhyme":false}
rh_004	opt2	1️⃣ 하나	images/numbers/one.png	audio/words/one.mp3	{"rhymePattern":"나","correctRhyme":true}
rh_004	opt3	👦 남자	images/people/boy.png	audio/words/boy.mp3	{"rhymePattern":"자","correctRhyme":false}
rh_005	opt1	📚 책	images/objects/book.png	audio/words/book.mp3	{"rhymePattern":"책","correctRhyme":false}
rh_005	opt2	✏️ 연필	images/objects/pencil.png	audio/words/pencil.mp3	{"rhymePattern":"필","correctRhyme":false}
rh_005	opt3	🍞 식빵	images/food/bread.png	audio/words/bread.mp3	{"rhymePattern":"앵","correctRhyme":true}
rh_006	opt1	🚗 차	images/vehicles/car_simple.png	audio/words/car_simple.mp3	{"rhymePattern":"차","correctRhyme":true}
rh_006	opt2	🚌 버스	images/vehicles/bus.png	audio/words/bus.mp3	{"rhymePattern":"스","correctRhyme":false}
rh_006	opt3	✈️ 비행기	images/vehicles/plane.png	audio/words/plane.mp3	{"rhymePattern":"기","correctRhyme":false}
rh_007	opt1	⭐ 별	images/nature/star.png	audio/words/star.mp3	{"rhymePattern":"별","correctRhyme":false}
rh_007	opt2	☁️ 구름	images/nature/cloud.png	audio/words/cloud.mp3	{"rhymePattern":"름","correctRhyme":true}
rh_007	opt3	🌈 무지개	images/nature/rainbow.png	audio/words/rainbow.mp3	{"rhymePattern":"개","correctRhyme":false}
rh_008	opt1	📖 책	images/objects/book.png	audio/words/book.mp3	{"rhymePattern":"책","correctRhyme":false}
rh_008	opt2	✂️ 가위	images/objects/scissors.png	audio/words/scissors.mp3	{"rhymePattern":"위","correctRhyme":false}
rh_008	opt3	🩹 밴드	images/objects/bandaid.png	audio/words/bandaid.mp3	{"rhymePattern":"드","correctRhyme":true}
rh_009	opt1	🌾 벼	images/nature/rice.png	audio/words/rice.mp3	{"rhymePattern":"벼","correctRhyme":true}
rh_009	opt2	🐻 곰	images/animals/bear.png	audio/words/bear.mp3	{"rhymePattern":"곰","correctRhyme":false}
rh_009	opt3	🐸 개구리	images/animals/frog.png	audio/words/frog.mp3	{"rhymePattern":"리","correctRhyme":false}
rh_010	opt1	🌙 달	images/nature/moon.png	audio/words/moon.mp3	{"rhymePattern":"ㄹ","correctRhyme":true}
rh_010	opt2	🔥 불	images/nature/fire.png	audio/words/fire.mp3	{"rhymePattern":"ㄹ","correctRhyme":false}
rh_010	opt3	⛰️ 산	images/nature/mountain.png	audio/words/mountain.mp3	{"rhymePattern":"ㄴ","correctRhyme":false}
```

---

## 📈 50개 문항 확장 가이드

### 각운 패턴별 분포 (권장)

| 각운 유형 | 개수 | 난이도 | ID 범위 | 예시 |
|----------|------|--------|---------|------|
| 단모음 끝 (-아, -오) | 10개 | Level 1 | rh_001~010 | 사과-바다 |
| 이중모음 끝 (-애, -의) | 10개 | Level 2 | rh_011~020 | 애기-거래 |
| 받침 끝 (-악, -억) | 15개 | Level 2-3 | rh_021~035 | 공책-식빵 |
| 복잡한 받침 | 10개 | Level 3-4 | rh_036~045 | 연필-밴드 |
| 복합어 각운 | 5개 | Level 4-5 | rh_046~050 | 자동차-차 |

### 카테고리별 분포

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| simple (단순어) | 15개 | 사과, 나무, 바다 |
| animal (동물) | 10개 | 고양이, 토끼, 강아지 |
| object (사물) | 10개 | 연필, 책, 공책 |
| nature (자연) | 10개 | 별, 하늘, 구름 |
| vehicle (탈것) | 5개 | 자동차, 버스, 비행기 |

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 명확한 각운
- 2음절 단어
- 예: 사과(-과) - 바다(-다)

**Level 2 (중간):**
- 받침 있는 각운
- 3음절 단어
- 예: 바나나(-나) - 하나(-나)

**Level 3 (어려움):**
- 복잡한 받침
- 긴 단어
- 예: 공책(-앵) - 식빵(-앵)

**Level 4-5 (매우 어려움):**
- 복합어
- 미묘한 차이
- 예: 자동차(-차) - 차(-차)

---

## 🎯 제작 팁

### 1. 한국어 각운의 특성

**각운(Rhyme)이란:**
- 단어의 끝소리가 같거나 비슷한 것
- 한국어는 주로 끝 음절 또는 끝 받침이 같은 경우

**예시:**
```
사과 (sa-gwa) → -과 (gwa)
바다 (ba-da)  → -다 (da)
❌ 각운 아님

나무 (na-mu)  → -무 (mu)
누구 (nu-gu)  → -구 (gu)
✓ 비슷한 각운 (모음 u 공유)
```

### 2. correctAnswer 형식

**한 개만 정답:**

```
correctAnswer: opt1
correctAnswer: opt2
correctAnswer: opt3
```

### 3. 오답 선택지 만들기

**전략:**
- 의미적으로 연관되지만 각운 다름
- 예: 고양이 → 강아지(각운O), 토끼(각운X), 코끼리(각운X)

### 4. 시각적 힌트

- 이미지로 단어 이해 돕기
- 글 못 읽는 아이도 사용 가능

---

## 💡 한국어 각운 패턴

### 쉬운 각운 (-다, -나, -가)

```
사과 - 바다 (-a로 끝)
바나나 - 하나 (-na로 끝)
```

### 중간 각운 (-지, -리, -기)

```
고양이 - 강아지 (-지)
코끼리 - 개구리 (-리)
```

### 어려운 각운 (받침 각운)

```
공책 - 식빵 (받침 ㅇ)
별 - 달 (받침 ㄹ)
```

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 150개 (50×3) 작성 완료
- [ ] itemId 중복 없음 (rh_001~rh_050)
- [ ] correctAnswer 각운 패턴 정확
- [ ] 정답 위치 균등 분포
- [ ] 모든 문항에 이미지 포함
- [ ] 각운 패턴 다양성 확보
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (rh_011 ~ rh_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/rhyme.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 3-4시간  
**난이도:** ⭐⭐⭐☆☆ (중간-어려움)
