# 📋 구글 시트 템플릿: 음절 합성 (syllable_merge)

**게임명:** 음절 합성  
**파일명:** `syllable_merge.json`  
**패턴:** multipleChoice  
**난이도:** ★★★ (어려움)

---

## 🎯 게임 설명

**목표:** 쪼개진 음절을 듣고 합쳐서 단어 만들기  
**학습 목표:** 음절 합성 - 분리된 음절을 하나의 단어로 조합

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_syllable_merge_batch1
moduleId	phonological_advanced
type	phonological
pattern	multipleChoice
title	음절 합성 - 50문항
instruction	쪼개진 소리를 합치면 어떤 단어가 될까요?
instructionAudioPath	audio/instructions/syllable_merge.mp3
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
sm_001	'사 - 과' 합치면?	audio/syllables/sa_gwa.mp3		opt2	맞아요! '사과'예요!	audio/feedback/merge_correct_1.mp3	1	fruit
sm_002	'바 - 나 - 나' 합치면?	audio/syllables/ba_na_na.mp3		opt3	맞아요! '바나나'예요!	audio/feedback/merge_correct_2.mp3	2	fruit
sm_003	'강 - 아 - 지' 합치면?	audio/syllables/gang_a_ji.mp3		opt1	맞아요! '강아지'예요!	audio/feedback/merge_correct_3.mp3	2	animal
sm_004	'코 - 끼 - 리' 합치면?	audio/syllables/ko_kki_ri.mp3		opt2	맞아요! '코끼리'예요!	audio/feedback/merge_correct_4.mp3	2	animal
sm_005	'자 - 동 - 차' 합치면?	audio/syllables/ja_dong_cha.mp3		opt3	맞아요! '자동차'예요!	audio/feedback/merge_correct_5.mp3	2	vehicle
sm_006	'비 - 행 - 기' 합치면?	audio/syllables/bi_haeng_gi.mp3		opt1	맞아요! '비행기'예요!	audio/feedback/merge_correct_6.mp3	2	vehicle
sm_007	'무 - 지 - 개' 합치면?	audio/syllables/mu_ji_gae.mp3		opt2	맞아요! '무지개'예요!	audio/feedback/merge_correct_7.mp3	3	nature
sm_008	'나 - 비' 합치면?	audio/syllables/na_bi.mp3		opt3	맞아요! '나비'예요!	audio/feedback/merge_correct_8.mp3	1	animal
sm_009	'연 - 필 - 통' 합치면?	audio/syllables/yeon_pil_tong.mp3		opt1	맞아요! '연필통'예요!	audio/feedback/merge_correct_9.mp3	3	object
sm_010	'컴 - 퓨 - 터' 합치면?	audio/syllables/keom_pyu_teo.mp3		opt2	맞아요! '컴퓨터'예요!	audio/feedback/merge_correct_10.mp3	3	object
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (각 문항당 3개 선택지):**

```
sm_001	opt1	🍌 바나나	images/fruits/banana.png	audio/words/banana.mp3	{"word":"바나나","isCorrect":false}
sm_001	opt2	🍎 사과	images/fruits/apple.png	audio/words/apple.mp3	{"word":"사과","isCorrect":true}
sm_001	opt3	🍇 포도	images/fruits/grape.png	audio/words/grape.mp3	{"word":"포도","isCorrect":false}
sm_002	opt1	🍎 사과	images/fruits/apple.png	audio/words/apple.mp3	{"word":"사과","isCorrect":false}
sm_002	opt2	🍓 딸기	images/fruits/strawberry.png	audio/words/strawberry.mp3	{"word":"딸기","isCorrect":false}
sm_002	opt3	🍌 바나나	images/fruits/banana.png	audio/words/banana.mp3	{"word":"바나나","isCorrect":true}
sm_003	opt1	🐕 강아지	images/animals/dog.png	audio/words/dog.mp3	{"word":"강아지","isCorrect":true}
sm_003	opt2	🐱 고양이	images/animals/cat.png	audio/words/cat.mp3	{"word":"고양이","isCorrect":false}
sm_003	opt3	🐰 토끼	images/animals/rabbit.png	audio/words/rabbit.mp3	{"word":"토끼","isCorrect":false}
sm_004	opt1	🐕 강아지	images/animals/dog.png	audio/words/dog.mp3	{"word":"강아지","isCorrect":false}
sm_004	opt2	🐘 코끼리	images/animals/elephant.png	audio/words/elephant.mp3	{"word":"코끼리","isCorrect":true}
sm_004	opt3	🦒 기린	images/animals/giraffe.png	audio/words/giraffe.mp3	{"word":"기린","isCorrect":false}
sm_005	opt1	🚌 버스	images/vehicles/bus.png	audio/words/bus.mp3	{"word":"버스","isCorrect":false}
sm_005	opt2	✈️ 비행기	images/vehicles/plane.png	audio/words/plane.mp3	{"word":"비행기","isCorrect":false}
sm_005	opt3	🚗 자동차	images/vehicles/car.png	audio/words/car.mp3	{"word":"자동차","isCorrect":true}
sm_006	opt1	✈️ 비행기	images/vehicles/plane.png	audio/words/plane.mp3	{"word":"비행기","isCorrect":true}
sm_006	opt2	🚂 기차	images/vehicles/train.png	audio/words/train.mp3	{"word":"기차","isCorrect":false}
sm_006	opt3	🚁 헬리콥터	images/vehicles/helicopter.png	audio/words/helicopter.mp3	{"word":"헬리콥터","isCorrect":false}
sm_007	opt1	☁️ 구름	images/nature/cloud.png	audio/words/cloud.mp3	{"word":"구름","isCorrect":false}
sm_007	opt2	🌈 무지개	images/nature/rainbow.png	audio/words/rainbow.mp3	{"word":"무지개","isCorrect":true}
sm_007	opt3	⭐ 별	images/nature/star.png	audio/words/star.mp3	{"word":"별","isCorrect":false}
sm_008	opt1	🐝 벌	images/animals/bee.png	audio/words/bee.mp3	{"word":"벌","isCorrect":false}
sm_008	opt2	🐦 새	images/animals/bird.png	audio/words/bird.mp3	{"word":"새","isCorrect":false}
sm_008	opt3	🦋 나비	images/animals/butterfly.png	audio/words/butterfly.mp3	{"word":"나비","isCorrect":true}
sm_009	opt1	✏️ 연필통	images/objects/pencil_case.png	audio/words/pencil_case.mp3	{"word":"연필통","isCorrect":true}
sm_009	opt2	✂️ 가위	images/objects/scissors.png	audio/words/scissors.mp3	{"word":"가위","isCorrect":false}
sm_009	opt3	📚 책	images/objects/book.png	audio/words/book.mp3	{"word":"책","isCorrect":false}
sm_010	opt1	📱 핸드폰	images/objects/phone.png	audio/words/phone.mp3	{"word":"핸드폰","isCorrect":false}
sm_010	opt2	💻 컴퓨터	images/objects/computer.png	audio/words/computer.mp3	{"word":"컴퓨터","isCorrect":true}
sm_010	opt3	📺 텔레비전	images/objects/tv.png	audio/words/tv.mp3	{"word":"텔레비전","isCorrect":false}
```

---

## 📈 50개 문항 확장 가이드

### 음절 수별 분포 (권장)

| 음절 수 | 개수 | 난이도 | ID 범위 | 예시 |
|---------|------|--------|---------|------|
| 2음절 | 15개 | Level 1-2 | sm_001~015 | 사-과, 나-비 |
| 3음절 | 25개 | Level 2-3 | sm_016~040 | 바-나-나, 강-아-지 |
| 4음절 | 8개 | Level 3-4 | sm_041~048 | 자-동-판-매-기 |
| 5음절 | 2개 | Level 4-5 | sm_049~050 | 국-립-중-앙-박-물-관 |

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
- 명확한 음절 구분
- 예: 사-과, 나-비

**Level 2 (중간):**
- 3음절 단어
- 일상적인 단어
- 예: 바-나-나, 강-아-지

**Level 3 (어려움):**
- 3~4음절 복합어
- 받침이 많은 단어
- 예: 무-지-개, 연-필-통

**Level 4-5 (매우 어려움):**
- 4~5음절 긴 단어
- 추상적인 단어
- 예: 컴-퓨-터, 자-동-판-매-기

---

## 🎯 제작 팁

### 1. questionAudioPath 중요!

**음절을 분리해서 녹음:**
- 각 음절 사이에 0.5초 간격
- 명확한 발음
- 예: "사... 과" (sa... gwa)

### 2. 오답 선택지 만들기

**전략:**
- 같은 카테고리의 단어
- 비슷한 음절 수
- 예: 사-과 → 포도(X), 바나나(X)

### 3. 이미지 필수

- 아동이 글을 못 읽으므로 이미지로 확인
- 명확한 그림 사용

### 4. 정답 위치 균등

**50개 문항에서:**
- opt1이 정답: 약 17개
- opt2가 정답: 약 17개
- opt3이 정답: 약 16개

---

## 💡 음절 분리 규칙

### 한글 음절 단위

**기본 원칙:**
- 한글 1글자 = 1음절
- 받침도 같은 음절에 포함

**예시:**
```
사과 = 사(1) + 과(2) = 2음절
강아지 = 강(1) + 아(2) + 지(3) = 3음절
```

### 오디오 녹음 방법

**권장 형식:**
```
"사... 과"
각 음절 사이 0.5초 휴지(pause)
```

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 150개 (50×3) 작성 완료
- [ ] itemId 중복 없음 (sm_001~sm_050)
- [ ] questionAudioPath에 분리된 음절 녹음
- [ ] correctAnswer 정확
- [ ] 정답 위치 균등 분포
- [ ] 모든 옵션에 이미지 포함
- [ ] 음절 수 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (sm_011 ~ sm_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/syllable_merge.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 3-4시간  
**난이도:** ⭐⭐⭐⭐☆ (어려움)
