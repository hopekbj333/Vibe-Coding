# 📋 구글 시트 템플릿: 카드 짝 맞추기 (card_match)

**게임명:** 카드 짝 맞추기  
**파일명:** `card_match.json`  
**패턴:** matching  
**난이도:** ★★☆ (중간)

---

## 🎯 게임 설명

**목표:** 뒤집힌 카드를 2장씩 뒤집어 같은 그림 찾기  
**학습 목표:** 작업 기억 - 시각적 정보 단기 기억

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	working_memory_card_match_batch1
moduleId	working_memory_basic
type	working_memory
pattern	matching
title	카드 짝 맞추기 - 50문항
instruction	같은 그림 카드를 찾아 짝을 맞춰보세요
instructionAudioPath	audio/instructions/card_match.mp3
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
cm_001	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	1	animal
cm_002	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	1	animal
cm_003	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	1	fruit
cm_004	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	1	fruit
cm_005	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	2	shape
cm_006	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	2	shape
cm_007	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	2	color
cm_008	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	2	color
cm_009	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8,opt9,opt10	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	3	vehicle
cm_010	같은 그림을 찾아보세요			opt1,opt2,opt3,opt4,opt5,opt6,opt7,opt8,opt9,opt10	짝을 모두 맞췄어요!	audio/feedback/match_success.mp3	3	vehicle
```

---

## 🎨 시트 3: Options

**헤더 (첫 번째 행):**

```
itemId	optionId	label	imagePath	audioPath	optionData
```

**샘플 데이터 (문항별로 카드 쌍 정의):**

```
cm_001	opt1	🐕 강아지	images/cards/dog.png		{"pairId":"pair1","cardType":"animal"}
cm_001	opt2	🐕 강아지	images/cards/dog.png		{"pairId":"pair1","cardType":"animal"}
cm_001	opt3	🐱 고양이	images/cards/cat.png		{"pairId":"pair2","cardType":"animal"}
cm_001	opt4	🐱 고양이	images/cards/cat.png		{"pairId":"pair2","cardType":"animal"}
cm_001	opt5	🐰 토끼	images/cards/rabbit.png		{"pairId":"pair3","cardType":"animal"}
cm_001	opt6	🐰 토끼	images/cards/rabbit.png		{"pairId":"pair3","cardType":"animal"}
cm_002	opt1	🦁 사자	images/cards/lion.png		{"pairId":"pair1","cardType":"animal"}
cm_002	opt2	🦁 사자	images/cards/lion.png		{"pairId":"pair1","cardType":"animal"}
cm_002	opt3	🐘 코끼리	images/cards/elephant.png		{"pairId":"pair2","cardType":"animal"}
cm_002	opt4	🐘 코끼리	images/cards/elephant.png		{"pairId":"pair2","cardType":"animal"}
cm_002	opt5	🦒 기린	images/cards/giraffe.png		{"pairId":"pair3","cardType":"animal"}
cm_002	opt6	🦒 기린	images/cards/giraffe.png		{"pairId":"pair3","cardType":"animal"}
cm_003	opt1	🍎 사과	images/cards/apple.png		{"pairId":"pair1","cardType":"fruit"}
cm_003	opt2	🍎 사과	images/cards/apple.png		{"pairId":"pair1","cardType":"fruit"}
cm_003	opt3	🍌 바나나	images/cards/banana.png		{"pairId":"pair2","cardType":"fruit"}
cm_003	opt4	🍌 바나나	images/cards/banana.png		{"pairId":"pair2","cardType":"fruit"}
cm_003	opt5	🍇 포도	images/cards/grape.png		{"pairId":"pair3","cardType":"fruit"}
cm_003	opt6	🍇 포도	images/cards/grape.png		{"pairId":"pair3","cardType":"fruit"}
cm_004	opt1	🍓 딸기	images/cards/strawberry.png		{"pairId":"pair1","cardType":"fruit"}
cm_004	opt2	🍓 딸기	images/cards/strawberry.png		{"pairId":"pair1","cardType":"fruit"}
cm_004	opt3	🍉 수박	images/cards/watermelon.png		{"pairId":"pair2","cardType":"fruit"}
cm_004	opt4	🍉 수박	images/cards/watermelon.png		{"pairId":"pair2","cardType":"fruit"}
cm_004	opt5	🍑 복숭아	images/cards/peach.png		{"pairId":"pair3","cardType":"fruit"}
cm_004	opt6	🍑 복숭아	images/cards/peach.png		{"pairId":"pair3","cardType":"fruit"}
cm_005	opt1	🔴 빨강 원	images/cards/red_circle.png		{"pairId":"pair1","cardType":"shape"}
cm_005	opt2	🔴 빨강 원	images/cards/red_circle.png		{"pairId":"pair1","cardType":"shape"}
cm_005	opt3	🔵 파랑 사각	images/cards/blue_square.png		{"pairId":"pair2","cardType":"shape"}
cm_005	opt4	🔵 파랑 사각	images/cards/blue_square.png		{"pairId":"pair2","cardType":"shape"}
cm_005	opt5	🟢 초록 삼각	images/cards/green_triangle.png		{"pairId":"pair3","cardType":"shape"}
cm_005	opt6	🟢 초록 삼각	images/cards/green_triangle.png		{"pairId":"pair3","cardType":"shape"}
cm_005	opt7	🟡 노랑 별	images/cards/yellow_star.png		{"pairId":"pair4","cardType":"shape"}
cm_005	opt8	🟡 노랑 별	images/cards/yellow_star.png		{"pairId":"pair4","cardType":"shape"}
cm_006	opt1	🟣 보라 하트	images/cards/purple_heart.png		{"pairId":"pair1","cardType":"shape"}
cm_006	opt2	🟣 보라 하트	images/cards/purple_heart.png		{"pairId":"pair1","cardType":"shape"}
cm_006	opt3	🟠 주황 육각	images/cards/orange_hexagon.png		{"pairId":"pair2","cardType":"shape"}
cm_006	opt4	🟠 주황 육각	images/cards/orange_hexagon.png		{"pairId":"pair2","cardType":"shape"}
cm_006	opt5	⚫ 검정 마름	images/cards/black_diamond.png		{"pairId":"pair3","cardType":"shape"}
cm_006	opt6	⚫ 검정 마름	images/cards/black_diamond.png		{"pairId":"pair3","cardType":"shape"}
cm_006	opt7	⚪ 흰색 오각	images/cards/white_pentagon.png		{"pairId":"pair4","cardType":"shape"}
cm_006	opt8	⚪ 흰색 오각	images/cards/white_pentagon.png		{"pairId":"pair4","cardType":"shape"}
cm_007	opt1	🔴 빨강	images/cards/red.png		{"pairId":"pair1","cardType":"color"}
cm_007	opt2	🔴 빨강	images/cards/red.png		{"pairId":"pair1","cardType":"color"}
cm_007	opt3	🔵 파랑	images/cards/blue.png		{"pairId":"pair2","cardType":"color"}
cm_007	opt4	🔵 파랑	images/cards/blue.png		{"pairId":"pair2","cardType":"color"}
cm_007	opt5	🟢 초록	images/cards/green.png		{"pairId":"pair3","cardType":"color"}
cm_007	opt6	🟢 초록	images/cards/green.png		{"pairId":"pair3","cardType":"color"}
cm_007	opt7	🟡 노랑	images/cards/yellow.png		{"pairId":"pair4","cardType":"color"}
cm_007	opt8	🟡 노랑	images/cards/yellow.png		{"pairId":"pair4","cardType":"color"}
cm_008	opt1	🟣 보라	images/cards/purple.png		{"pairId":"pair1","cardType":"color"}
cm_008	opt2	🟣 보라	images/cards/purple.png		{"pairId":"pair1","cardType":"color"}
cm_008	opt3	🟠 주황	images/cards/orange.png		{"pairId":"pair2","cardType":"color"}
cm_008	opt4	🟠 주황	images/cards/orange.png		{"pairId":"pair2","cardType":"color"}
cm_008	opt5	🟤 갈색	images/cards/brown.png		{"pairId":"pair3","cardType":"color"}
cm_008	opt6	🟤 갈색	images/cards/brown.png		{"pairId":"pair3","cardType":"color"}
cm_008	opt7	⚫ 검정	images/cards/black.png		{"pairId":"pair4","cardType":"color"}
cm_008	opt8	⚫ 검정	images/cards/black.png		{"pairId":"pair4","cardType":"color"}
cm_009	opt1	🚗 자동차	images/cards/car.png		{"pairId":"pair1","cardType":"vehicle"}
cm_009	opt2	🚗 자동차	images/cards/car.png		{"pairId":"pair1","cardType":"vehicle"}
cm_009	opt3	🚂 기차	images/cards/train.png		{"pairId":"pair2","cardType":"vehicle"}
cm_009	opt4	🚂 기차	images/cards/train.png		{"pairId":"pair2","cardType":"vehicle"}
cm_009	opt5	✈️ 비행기	images/cards/plane.png		{"pairId":"pair3","cardType":"vehicle"}
cm_009	opt6	✈️ 비행기	images/cards/plane.png		{"pairId":"pair3","cardType":"vehicle"}
cm_009	opt7	🚢 배	images/cards/ship.png		{"pairId":"pair4","cardType":"vehicle"}
cm_009	opt8	🚢 배	images/cards/ship.png		{"pairId":"pair4","cardType":"vehicle"}
cm_009	opt9	🚁 헬리콥터	images/cards/helicopter.png		{"pairId":"pair5","cardType":"vehicle"}
cm_009	opt10	🚁 헬리콥터	images/cards/helicopter.png		{"pairId":"pair5","cardType":"vehicle"}
cm_010	opt1	🚲 자전거	images/cards/bicycle.png		{"pairId":"pair1","cardType":"vehicle"}
cm_010	opt2	🚲 자전거	images/cards/bicycle.png		{"pairId":"pair1","cardType":"vehicle"}
cm_010	opt3	🏍️ 오토바이	images/cards/motorcycle.png		{"pairId":"pair2","cardType":"vehicle"}
cm_010	opt4	🏍️ 오토바이	images/cards/motorcycle.png		{"pairId":"pair2","cardType":"vehicle"}
cm_010	opt5	🚌 버스	images/cards/bus.png		{"pairId":"pair3","cardType":"vehicle"}
cm_010	opt6	🚌 버스	images/cards/bus.png		{"pairId":"pair3","cardType":"vehicle"}
cm_010	opt7	🚕 택시	images/cards/taxi.png		{"pairId":"pair4","cardType":"vehicle"}
cm_010	opt8	🚕 택시	images/cards/taxi.png		{"pairId":"pair4","cardType":"vehicle"}
cm_010	opt9	🚙 SUV	images/cards/suv.png		{"pairId":"pair5","cardType":"vehicle"}
cm_010	opt10	🚙 SUV	images/cards/suv.png		{"pairId":"pair5","cardType":"vehicle"}
```

---

## 📈 50개 문항 확장 가이드

### 카드 쌍 수별 분포 (권장)

| 카드 쌍 수 | 총 카드 수 | 개수 | 난이도 | ID 범위 |
|-----------|----------|------|--------|---------|
| 3쌍 | 6장 | 15개 | Level 1 | cm_001~cm_015 |
| 4쌍 | 8장 | 20개 | Level 2 | cm_016~cm_035 |
| 5쌍 | 10장 | 10개 | Level 3 | cm_036~cm_045 |
| 6쌍 | 12장 | 5개 | Level 4 | cm_046~cm_050 |

### 카테고리별 분포

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| animal (동물) | 12개 | 강아지, 고양이, 토끼 |
| fruit (과일) | 10개 | 사과, 바나나, 포도 |
| shape (도형) | 8개 | 원, 사각형, 삼각형 |
| color (색상) | 8개 | 빨강, 파랑, 초록 |
| vehicle (탈것) | 12개 | 자동차, 비행기, 배 |

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 3쌍 (6장)
- 명확하게 다른 이미지
- 친숙한 주제

**Level 2 (중간):**
- 4쌍 (8장)
- 비슷한 카테고리
- 약간의 혼동 가능

**Level 3 (어려움):**
- 5쌍 (10장)
- 비슷한 이미지
- 복잡한 패턴

**Level 4-5 (매우 어려움):**
- 6쌍 이상 (12장+)
- 매우 비슷한 이미지
- 복잡한 색상/패턴

---

## 🎯 제작 팁

### 1. correctAnswer 형식

**matching 패턴은 모든 옵션을 나열:**

```
correctAnswer: opt1,opt2,opt3,opt4,opt5,opt6
```

### 2. pairId 일관성

**optionData의 pairId로 쌍 정의:**

```json
{"pairId":"pair1","cardType":"animal"}
{"pairId":"pair1","cardType":"animal"}  // 같은 pair1
```

### 3. 이미지 필수

- 모든 카드에 이미지 필요
- 동일한 이미지 경로 사용 (같은 쌍)

### 4. 시각적 명확성

- 충분히 구별 가능한 이미지
- 색상 대비 고려
- 아이콘 크기 일관성

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 작성 (문항당 6~12개)
- [ ] itemId 중복 없음 (cm_001~cm_050)
- [ ] 각 문항의 카드 쌍이 명확함
- [ ] pairId가 올바르게 매칭됨
- [ ] 모든 카드에 이미지 경로 포함
- [ ] 난이도 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (cm_011 ~ cm_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/card_match.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 3-4시간  
**난이도:** ⭐⭐⭐⭐☆ (어려움)
