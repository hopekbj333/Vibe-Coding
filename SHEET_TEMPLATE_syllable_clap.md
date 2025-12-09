# 📋 구글 시트 템플릿: 박수로 음절 쪼개기 (syllable_clap)

**게임명:** 박수로 음절 쪼개기  
**파일명:** `syllable_clap.json`  
**패턴:** rhythmTap  
**난이도:** ★★☆ (중간)

---

## 🎯 게임 설명

**목표:** 단어를 듣고 음절 수만큼 박수 치기  
**학습 목표:** 음절 인식 - 단어를 음절로 분리하는 능력

---

## 📊 시트 1: Content Info

**복사하여 구글 시트에 붙여넣기:**

```
필드명	값
contentId	phonological_syllable_clap_batch1
moduleId	phonological_basic
type	phonological
pattern	rhythmTap
title	박수로 음절 쪼개기 - 50문항
instruction	단어를 듣고 음절 수만큼 박수를 쳐보세요
instructionAudioPath	audio/instructions/syllable_clap.mp3
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
sc_001	'사과'는 음절이 몇 개일까요?	audio/words/apple.mp3	images/fruits/apple.png	2	'사-과'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	1	fruit
sc_002	'바나나'는 음절이 몇 개일까요?	audio/words/banana.mp3	images/fruits/banana.png	3	'바-나-나'는 음절이 3개예요!	audio/feedback/syllable_3.mp3	1	fruit
sc_003	'포도'는 음절이 몇 개일까요?	audio/words/grape.mp3	images/fruits/grape.png	2	'포-도'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	1	fruit
sc_004	'수박'은 음절이 몇 개일까요?	audio/words/watermelon.mp3	images/fruits/watermelon.png	2	'수-박'은 음절이 2개예요!	audio/feedback/syllable_2.mp3	1	fruit
sc_005	'딸기'는 음절이 몇 개일까요?	audio/words/strawberry.mp3	images/fruits/strawberry.png	2	'딸-기'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	1	fruit
sc_006	'코끼리'는 음절이 몇 개일까요?	audio/words/elephant.mp3	images/animals/elephant.png	3	'코-끼-리'는 음절이 3개예요!	audio/feedback/syllable_3.mp3	2	animal
sc_007	'토끼'는 음절이 몇 개일까요?	audio/words/rabbit.mp3	images/animals/rabbit.png	2	'토-끼'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	2	animal
sc_008	'강아지'는 음절이 몇 개일까요?	audio/words/puppy.mp3	images/animals/puppy.png	3	'강-아-지'는 음절이 3개예요!	audio/feedback/syllable_3.mp3	2	animal
sc_009	'나비'는 음절이 몇 개일까요?	audio/words/butterfly.mp3	images/animals/butterfly.png	2	'나-비'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	2	animal
sc_010	'개미'는 음절이 몇 개일까요?	audio/words/ant.mp3	images/animals/ant.png	2	'개-미'는 음절이 2개예요!	audio/feedback/syllable_2.mp3	2	animal
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

### 음절 수별 분포 (권장)

| 음절 수 | 개수 | 난이도 | ID 범위 |
|---------|------|--------|---------|
| 2음절 | 20개 | Level 1-2 | sc_001~sc_020 |
| 3음절 | 20개 | Level 2-3 | sc_021~sc_040 |
| 4음절 | 8개 | Level 3-4 | sc_041~sc_048 |
| 5음절 | 2개 | Level 4-5 | sc_049~sc_050 |

### 카테고리별 분포

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| fruit (과일) | 10개 | 사과, 바나나, 포도 |
| animal (동물) | 10개 | 강아지, 코끼리, 토끼 |
| object (사물) | 10개 | 연필, 지우개, 공책 |
| vehicle (탈것) | 10개 | 자동차, 비행기, 기차 |
| nature (자연) | 10개 | 하늘, 바다, 구름 |

### 추가 단어 아이디어

**2음절 (쉬움):**
- 과일: 배, 밤, 귤, 감
- 동물: 곰, 말, 소, 닭
- 사물: 책, 컵, 공, 연
- 탈것: 차, 배, 버스
- 자연: 별, 달, 꽃, 나무

**3음절 (중간):**
- 과일: 오렌지, 자두, 키위
- 동물: 다람쥐, 고양이, 거북이
- 사물: 연필통, 가위, 풀
- 탈것: 자전거, 오토바이
- 자연: 무지개, 태양

**4음절 (어려움):**
- 과일: 파인애플, 체리
- 동물: 악어, 타조
- 사물: 컴퓨터, 텔레비전
- 탈것: 헬리콥터

**5음절 (매우 어려움):**
- 복합어: 자동판매기, 편의점

---

## ⚙️ 난이도 조정 방법

**Level 1 (쉬움):**
- 2음절 명사
- 일상적인 단어
- 명확한 음절 구분
- 예: 사-과, 바-나-나

**Level 2 (중간):**
- 2~3음절 명사
- 받침이 있는 단어
- 예: 강-아-지, 토-끼

**Level 3 (어려움):**
- 3~4음절
- 복합어
- 예: 연-필-통

**Level 4-5 (매우 어려움):**
- 4~5음절
- 긴 복합어
- 예: 자-동-판-매-기

---

## 🎯 제작 팁

### 1. correctAnswer 형식

**rhythmTap 패턴은 correctAnswer에 음절 수를 숫자로 입력:**

```
correctAnswer: 2
correctAnswer: 3
correctAnswer: 4
```

### 2. 이미지 필수

- 아동이 글을 읽지 못하므로 이미지 필수
- 경로: `images/[카테고리]/[단어].png`

### 3. 명확한 발음

- 음절 경계가 명확한 단어 선택
- 받침 처리 주의 (예: "닭" = 1음절)

### 4. 피드백

- 각 음절 수별 피드백 오디오 준비
- `audio/feedback/syllable_2.mp3`
- `audio/feedback/syllable_3.mp3`

---

## 💡 주의사항

### 음절 계산 규칙

**한글 음절:**
- "사과" = 사 + 과 = 2음절
- "바나나" = 바 + 나 + 나 = 3음절
- "강아지" = 강 + 아 + 지 = 3음절

**받침 처리:**
- "닭" = 1음절 (한 글자 = 1음절)
- "달님" = 달 + 님 = 2음절

**복합어:**
- "연필통" = 연 + 필 + 통 = 3음절
- "자동차" = 자 + 동 + 차 = 3음절

---

## ✅ 완성 체크리스트

- [ ] Content Info 작성 완료
- [ ] Items 50개 작성 완료
- [ ] Options 시트 비워두기 (또는 헤더만)
- [ ] itemId 중복 없음 (sc_001~sc_050)
- [ ] correctAnswer는 숫자만 (2, 3, 4, 5)
- [ ] 모든 문항에 이미지 경로 포함
- [ ] 음절 수 정확히 계산
- [ ] 난이도 분포 균등
- [ ] Apps Script 검증 통과
- [ ] JSON 내보내기 성공

---

## 📤 다음 단계

1. ✅ 이 템플릿을 구글 시트에 복사
2. ✅ 샘플 10개 확인
3. ✅ 나머지 40개 작성 (sc_011 ~ sc_050)
4. ✅ JSON 내보내기
5. ✅ `assets/questions/training/syllable_clap.json`에 저장
6. ✅ 앱에서 테스트

---

**작성일:** 2025-12-06  
**예상 소요 시간:** 2-3시간  
**난이도:** ⭐⭐⭐☆☆ (중간-어려움)
