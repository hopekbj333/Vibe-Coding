# 📋 구글 시트 템플릿: 다른 소리 찾기 (different_sound)

**게임명:** 다른 소리 찾기  
**파일명:** `different_sound.json`  
**패턴:** multipleChoice  
**난이도:** ★☆☆ (쉬움)

---

## 🎯 게임 설명

**목표:** 3개의 소리 중 다른 1개 찾기  
**학습 목표:** 음운 인식 - 차이점 구별하기

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_different_sound_batch1
moduleId	phonological_basic
type	phonological
pattern	multipleChoice
title	다른 소리 찾기 - 50문항
instruction	3개의 소리 중 다른 하나를 찾아 터치하세요
instructionAudioPath	audio/instructions/different_sound.mp3
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
ds_001	다른 소리를 찾으세요	audio/animals/find_different_1.mp3		opt2	고양이 소리가 다르네요!	audio/feedback/correct_different.mp3	1	animal
ds_002	다른 소리를 찾으세요	audio/animals/find_different_2.mp3		opt3	사자 소리가 다르네요!	audio/feedback/correct_different.mp3	1	animal
ds_003	다른 소리를 찾으세요	audio/instruments/find_different_1.mp3		opt1	바이올린 소리가 다르네요!	audio/feedback/correct_different.mp3	1	instrument
ds_004	다른 소리를 찾으세요	audio/instruments/find_different_2.mp3		opt2	트럼펫 소리가 다르네요!	audio/feedback/correct_different.mp3	1	instrument
ds_005	다른 소리를 찾으세요	audio/transport/find_different_1.mp3		opt3	비행기 소리가 다르네요!	audio/feedback/correct_different.mp3	2	transport
ds_006	다른 소리를 찾으세요	audio/transport/find_different_2.mp3		opt1	헬리콥터 소리가 다르네요!	audio/feedback/correct_different.mp3	2	transport
ds_007	다른 소리를 찾으세요	audio/nature/find_different_1.mp3		opt2	천둥 소리가 다르네요!	audio/feedback/correct_different.mp3	2	nature
ds_008	다른 소리를 찾으세요	audio/nature/find_different_2.mp3		opt3	파도 소리가 다르네요!	audio/feedback/correct_different.mp3	2	nature
ds_009	다른 소리를 찾으세요	audio/home/find_different_1.mp3		opt1	전화벨 소리가 다르네요!	audio/feedback/correct_different.mp3	3	home
ds_010	다른 소리를 찾으세요	audio/home/find_different_2.mp3		opt2	문 닫는 소리가 다르네요!	audio/feedback/correct_different.mp3	3	home
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (각 문항당 3개 선택지 - 2개는 같고 1개는 다름):**

```
ds_001	opt1	🐕 멍멍		audio/animals/dog1.mp3	{"soundType":"dog","isCorrect":false}
ds_001	opt2	🐱 야옹		audio/animals/cat1.mp3	{"soundType":"cat","isCorrect":true}
ds_001	opt3	🐕 멍멍		audio/animals/dog2.mp3	{"soundType":"dog","isCorrect":false}
ds_002	opt1	🦁 으르렁		audio/animals/lion1.mp3	{"soundType":"lion","isCorrect":false}
ds_002	opt2	🦁 으르렁		audio/animals/lion2.mp3	{"soundType":"lion","isCorrect":false}
ds_002	opt3	🐘 뿌우		audio/animals/elephant1.mp3	{"soundType":"elephant","isCorrect":true}
ds_003	opt1	🎻 바이올린		audio/instruments/violin1.mp3	{"soundType":"violin","isCorrect":true}
ds_003	opt2	🎹 피아노		audio/instruments/piano1.mp3	{"soundType":"piano","isCorrect":false}
ds_003	opt3	🎹 피아노		audio/instruments/piano2.mp3	{"soundType":"piano","isCorrect":false}
ds_004	opt1	🥁 북		audio/instruments/drum1.mp3	{"soundType":"drum","isCorrect":false}
ds_004	opt2	🎺 트럼펫		audio/instruments/trumpet1.mp3	{"soundType":"trumpet","isCorrect":true}
ds_004	opt3	🥁 북		audio/instruments/drum2.mp3	{"soundType":"drum","isCorrect":false}
ds_005	opt1	🚂 기차		audio/transport/train1.mp3	{"soundType":"train","isCorrect":false}
ds_005	opt2	🚂 기차		audio/transport/train2.mp3	{"soundType":"train","isCorrect":false}
ds_005	opt3	✈️ 비행기		audio/transport/plane1.mp3	{"soundType":"plane","isCorrect":true}
ds_006	opt1	🚁 헬리콥터		audio/transport/helicopter1.mp3	{"soundType":"helicopter","isCorrect":true}
ds_006	opt2	🚗 자동차		audio/transport/car1.mp3	{"soundType":"car","isCorrect":false}
ds_006	opt3	🚗 자동차		audio/transport/car2.mp3	{"soundType":"car","isCorrect":false}
ds_007	opt1	☔ 비		audio/nature/rain1.mp3	{"soundType":"rain","isCorrect":false}
ds_007	opt2	⚡ 천둥		audio/nature/thunder1.mp3	{"soundType":"thunder","isCorrect":true}
ds_007	opt3	☔ 비		audio/nature/rain2.mp3	{"soundType":"rain","isCorrect":false}
ds_008	opt1	🌪️ 바람		audio/nature/wind1.mp3	{"soundType":"wind","isCorrect":false}
ds_008	opt2	🌪️ 바람		audio/nature/wind2.mp3	{"soundType":"wind","isCorrect":false}
ds_008	opt3	🌊 파도		audio/nature/wave1.mp3	{"soundType":"wave","isCorrect":true}
ds_009	opt1	📞 따르릉		audio/home/phone1.mp3	{"soundType":"phone","isCorrect":true}
ds_009	opt2	⏰ 똑딱		audio/home/clock1.mp3	{"soundType":"clock","isCorrect":false}
ds_009	opt3	⏰ 똑딱		audio/home/clock2.mp3	{"soundType":"clock","isCorrect":false}
ds_010	opt1	🔔 딩동		audio/home/bell1.mp3	{"soundType":"bell","isCorrect":false}
ds_010	opt2	🚪 쾅		audio/home/door1.mp3	{"soundType":"door","isCorrect":true}
ds_010	opt3	🔔 딩동		audio/home/bell2.mp3	{"soundType":"bell","isCorrect":false}
```

---

## 📈 50개 문항 확장 가이드

### 카테고리별 분포 (권장)

| 카테고리 | 개수 | 난이도 | ID 범위 |
|---------|------|--------|---------|
| animal (동물) | 10개 | Level 1 | ds_001 ~ ds_010 |
| instrument (악기) | 10개 | Level 1-2 | ds_011 ~ ds_020 |
| transport (교통) | 10개 | Level 2 | ds_021 ~ ds_030 |
| nature (자연) | 10개 | Level 2-3 | ds_031 ~ ds_040 |
| home (생활) | 10개 | Level 3 | ds_041 ~ ds_050 |

### 추가 소재 아이디어

**동물 (animal):**
- 🐮 소 / 🐷 돼지 중 하나 다르게
- 🐔 닭 / 🐦 새 중 하나 다르게
- 🐸 개구리 / 🦆 오리 중 하나 다르게

**악기 (instrument):**
- 🎸 기타 / 🪕 밴조 중 하나 다르게
- 🪘 탬버린 / 🎼 실로폰 중 하나 다르게

**교통 (transport):**
- 🚲 자전거 / 🏍️ 오토바이 중 하나 다르게
- 🚢 배 / 🚤 보트 중 하나 다르게

**자연 (nature):**
- 🔥 불 / 💧 물 중 하나 다르게
- 🌳 숲 / 🏞️ 계곡 중 하나 다르게

**생활 (home):**
- 🚪 문 열기 / 닫기
- 💡 스위치 / 🔑 열쇠

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 완전히 다른 카테고리 소리
- 예: 강아지 2개 + 고양이 1개

**Level 2 (중간):**
- 같은 카테고리 내 다른 소리
- 예: 기차 2개 + 비행기 1개

**Level 3 (어려움):**
- 비슷한 소리의 미묘한 차이
- 예: 종소리 2개 + 알람 소리 1개

**Level 4-5 (매우 어려움):**
- 매우 유사한 소리
- 예: 빠른 시계 2개 + 느린 시계 1개

---

## 🎯 제작 팁

### 1. correctAnswer 형식

**다른 하나만 선택:**

```
correctAnswer: opt1
correctAnswer: opt2
correctAnswer: opt3
```

### 2. 정답 위치 균등 분포

**50개 문항에서:**
- opt1이 정답: 약 17개
- opt2가 정답: 약 17개
- opt3이 정답: 약 16개

### 3. 명확한 차이

- 2개는 확실히 같은 소리
- 1개는 명확하게 다른 소리
- 혼동 최소화

### 4. 오디오 품질

- 같은 소리는 다른 녹음/버전 사용
- 차이가 있는 소리는 명확히 구별

---

## 💡 주의사항

### 같은 소리의 의미

**물리적으로 같은 소리:**
- 같은 동물/사물
- 다른 녹음 또는 변형

**예시:**
```
🐕 멍멍 (녹음1) ✓
🐕 멍멍 (녹음2) ✓  → 같은 소리
🐱 야옹         ✗  → 다른 소리
```

### 비슷한 vs 다른

**다른 소리 (정답):**
- 완전히 다른 출처
- 명확히 구별 가능

**같은 소리:**
- 동일 출처의 변형
- 약간의 변이는 허용

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 150개 (50×3) 작성 완료
- [ ] itemId 중복 없음 (ds_001~ds_050)
- [ ] correctAnswer는 opt1/opt2/opt3 중 하나
- [ ] 정답 위치 균등 분포
- [ ] 각 문항에 명확한 차이 존재
- [ ] 난이도 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (ds_011 ~ ds_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/different_sound.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 2-3시간  
**난이도:** ⭐⭐☆☆☆ (보통)
