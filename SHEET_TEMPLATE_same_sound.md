# 📋 구글 시트 템플릿: 같은 소리 찾기 (same_sound)

**게임명:** 같은 소리 찾기  
**파일명:** `same_sound.json`  
**패턴:** multipleChoice  
**난이도:** ★☆☆ (쉬움)

---

## 🎯 게임 설명

**목표:** 3개의 소리 중 같은 소리 2개를 찾아 터치  
**학습 목표:** 음운 인식의 기초 - 같은 소리 구별하기

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_same_sound_batch1
moduleId	phonological_basic
type	phonological
pattern	multipleChoice
title	같은 소리 찾기 - 50문항
instruction	3개의 소리 중 같은 2개를 찾아 터치하세요
instructionAudioPath	audio/instructions/same_sound.mp3
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
ss_001	같은 소리를 찾으세요	audio/animals/dog_question.mp3		opt1,opt3	같은 강아지 소리를 찾았어요!	audio/feedback/correct_dog.mp3	1	animal
ss_002	같은 소리를 찾으세요	audio/animals/cat_question.mp3		opt1,opt2	같은 고양이 소리를 찾았어요!	audio/feedback/correct_cat.mp3	1	animal
ss_003	같은 소리를 찾으세요	audio/instruments/piano_question.mp3		opt2,opt3	같은 피아노 소리를 찾았어요!	audio/feedback/correct_piano.mp3	1	instrument
ss_004	같은 소리를 찾으세요	audio/instruments/drum_question.mp3		opt1,opt3	같은 북 소리를 찾았어요!	audio/feedback/correct_drum.mp3	1	instrument
ss_005	같은 소리를 찾으세요	audio/transport/car_question.mp3		opt1,opt2	같은 자동차 소리를 찾았어요!	audio/feedback/correct_car.mp3	2	transport
ss_006	같은 소리를 찾으세요	audio/transport/train_question.mp3		opt2,opt3	같은 기차 소리를 찾았어요!	audio/feedback/correct_train.mp3	2	transport
ss_007	같은 소리를 찾으세요	audio/nature/rain_question.mp3		opt1,opt3	같은 비 소리를 찾았어요!	audio/feedback/correct_rain.mp3	2	nature
ss_008	같은 소리를 찾으세요	audio/nature/wind_question.mp3		opt1,opt2	같은 바람 소리를 찾았어요!	audio/feedback/correct_wind.mp3	2	nature
ss_009	같은 소리를 찾으세요	audio/home/bell_question.mp3		opt2,opt3	같은 종소리를 찾았어요!	audio/feedback/correct_bell.mp3	3	home
ss_010	같은 소리를 찾으세요	audio/home/clock_question.mp3		opt1,opt3	같은 시계 소리를 찾았어요!	audio/feedback/correct_clock.mp3	3	home
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (각 문항당 3개 선택지):**

```
ss_001	opt1	🐕 멍멍		audio/animals/dog1.mp3	{"soundType":"dog","variant":"bark1"}
ss_001	opt2	🐱 야옹		audio/animals/cat1.mp3	{"soundType":"cat","variant":"meow1"}
ss_001	opt3	🐕 멍멍		audio/animals/dog2.mp3	{"soundType":"dog","variant":"bark2"}
ss_002	opt1	🐱 야옹		audio/animals/cat1.mp3	{"soundType":"cat","variant":"meow1"}
ss_002	opt2	🐱 야옹		audio/animals/cat2.mp3	{"soundType":"cat","variant":"meow2"}
ss_002	opt3	🐕 멍멍		audio/animals/dog1.mp3	{"soundType":"dog","variant":"bark1"}
ss_003	opt1	🥁 북		audio/instruments/drum1.mp3	{"soundType":"drum","variant":"beat1"}
ss_003	opt2	🎹 피아노		audio/instruments/piano1.mp3	{"soundType":"piano","variant":"note1"}
ss_003	opt3	🎹 피아노		audio/instruments/piano2.mp3	{"soundType":"piano","variant":"note2"}
ss_004	opt1	🥁 북		audio/instruments/drum1.mp3	{"soundType":"drum","variant":"beat1"}
ss_004	opt2	🎻 바이올린		audio/instruments/violin1.mp3	{"soundType":"violin","variant":"note1"}
ss_004	opt3	🥁 북		audio/instruments/drum2.mp3	{"soundType":"drum","variant":"beat2"}
ss_005	opt1	🚗 부릉		audio/transport/car1.mp3	{"soundType":"car","variant":"engine1"}
ss_005	opt2	🚗 부릉		audio/transport/car2.mp3	{"soundType":"car","variant":"engine2"}
ss_005	opt3	🚂 칙칙폭폭		audio/transport/train1.mp3	{"soundType":"train","variant":"whistle1"}
ss_006	opt1	✈️ 슝		audio/transport/plane1.mp3	{"soundType":"plane","variant":"fly1"}
ss_006	opt2	🚂 칙칙폭폭		audio/transport/train1.mp3	{"soundType":"train","variant":"whistle1"}
ss_006	opt3	🚂 칙칙폭폭		audio/transport/train2.mp3	{"soundType":"train","variant":"whistle2"}
ss_007	opt1	☔ 빗소리		audio/nature/rain1.mp3	{"soundType":"rain","variant":"light"}
ss_007	opt2	🌪️ 바람		audio/nature/wind1.mp3	{"soundType":"wind","variant":"blow1"}
ss_007	opt3	☔ 빗소리		audio/nature/rain2.mp3	{"soundType":"rain","variant":"heavy"}
ss_008	opt1	🌪️ 바람		audio/nature/wind1.mp3	{"soundType":"wind","variant":"blow1"}
ss_008	opt2	🌪️ 바람		audio/nature/wind2.mp3	{"soundType":"wind","variant":"blow2"}
ss_008	opt3	⚡ 천둥		audio/nature/thunder1.mp3	{"soundType":"thunder","variant":"rumble"}
ss_009	opt1	📢 알람		audio/home/alarm1.mp3	{"soundType":"alarm","variant":"beep"}
ss_009	opt2	🔔 딩동		audio/home/bell1.mp3	{"soundType":"bell","variant":"ring1"}
ss_009	opt3	🔔 딩동		audio/home/bell2.mp3	{"soundType":"bell","variant":"ring2"}
ss_010	opt1	⏰ 똑딱		audio/home/clock1.mp3	{"soundType":"clock","variant":"tick1"}
ss_010	opt2	📞 따르릉		audio/home/phone1.mp3	{"soundType":"phone","variant":"ring"}
ss_010	opt3	⏰ 똑딱		audio/home/clock2.mp3	{"soundType":"clock","variant":"tick2"}
```

---

## 📈 50개 문항 확장 가이드

### 카테고리별 분포 (권장)

| 카테고리 | 개수 | 난이도 | ID 범위 |
|---------|------|--------|---------|
| animal (동물) | 10개 | Level 1 | ss_001 ~ ss_010 |
| instrument (악기) | 10개 | Level 1-2 | ss_011 ~ ss_020 |
| transport (교통) | 10개 | Level 2 | ss_021 ~ ss_030 |
| nature (자연) | 10개 | Level 2-3 | ss_031 ~ ss_040 |
| home (생활) | 10개 | Level 3 | ss_041 ~ ss_050 |

### 추가 소재 아이디어

**동물 (animal):**
- 🐮 소, 🐷 돼지, 🐔 닭, 🐦 새, 🐸 개구리, 🦁 사자, 🐘 코끼리

**악기 (instrument):**
- 🎺 트럼펫, 🎸 기타, 🪘 탬버린, 🎼 실로폰, 🥁 징

**교통 (transport):**
- 🚁 헬리콥터, 🚢 배, 🚲 자전거 벨, 🏍️ 오토바이

**자연 (nature):**
- 🌊 파도, 🔥 불, ⛈️ 폭풍, 🍃 나뭇잎 바스락

**생활 (home):**
- 🚪 문 여닫기, 💧 물소리, 🍽️ 그릇 부딪히기, 🔑 열쇠

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 명확하게 다른 소리
- 익숙한 소재
- 예: 개(멍멍) vs 고양이(야옹)

**Level 2 (중간):**
- 같은 카테고리 내 다른 소리
- 예: 피아노 vs 바이올린

**Level 3 (어려움):**
- 비슷한 소리의 미묘한 차이
- 예: 다른 종류의 종소리

**Level 4-5 (매우 어려움):**
- 추상적인 소리
- 예: 다른 템포의 시계 소리

---

## 🎯 제작 팁

### 1. 일관성 유지

- ID 형식: `ss_XXX` (001~050)
- 오디오 경로: `audio/[카테고리]/[소리명].mp3`
- correctAnswer: 항상 `opt1,opt2` 또는 `opt1,opt3` 또는 `opt2,opt3`

### 2. 정답 위치 균등 분포

- opt1,opt2: 약 17개
- opt1,opt3: 약 17개
- opt2,opt3: 약 16개

### 3. 카테고리 균형

- 각 카테고리 최소 8~10개
- 너무 한쪽에 치우치지 않게

### 4. 이모지 활용

- 시각적으로 구별하기 쉽게
- 아이들이 직관적으로 이해 가능

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 150개 (50×3) 작성 완료
- [ ] itemId 중복 없음 (ss_001~ss_050)
- [ ] correctAnswer 형식 확인 (opt1,opt2 등)
- [ ] 난이도 분포 균등 (Level 1~3)
- [ ] 카테고리 다양성 확보 (5개 카테고리)
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (ss_011 ~ ss_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/same_sound.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 2-3시간  
**난이도:** ⭐⭐☆☆☆ (보통)
