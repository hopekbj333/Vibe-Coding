# 🎭 Design WP D1: 캐릭터 디자인 (Character Design)

**우선순위**: **High** (MVP 필수)  
**예상 소요**: 1주  
**담당**: 캐릭터 디자이너  

---

## 📋 에셋 목록

| 파일명 | 용도 | 사이즈 | 형식 | 감정 표현 |
|--------|------|--------|------|----------|
| `character_happy.png` | 정답 피드백 | 512x512 px | PNG | 😊 기쁨 |
| `character_neutral.png` | 기본 상태 | 512x512 px | PNG | 😐 중립 |
| `character_thinking.png` | 문제 제시 | 512x512 px | PNG | 🤔 생각 |
| `character_sad.png` | 오답 피드백 | 512x512 px | PNG | 😢 슬픔 |
| `character_excited.png` | 레벨업 | 512x512 px | PNG | 🤩 신남 |

**해상도 요구사항:**
- @1x: 256x256 px (ldpi, mdpi)
- @2x: 512x512 px (hdpi, xhdpi)
- @3x: 1024x1024 px (xxhdpi, xxxhdpi)

**파일 경로:**
```
assets/characters/
├── character_happy.png
├── character_happy@2x.png
├── character_happy@3x.png
├── character_neutral.png
├── character_neutral@2x.png
├── character_neutral@3x.png
└── ...
```

---

## 🎨 디자인 가이드

### 캐릭터 콘셉트
- **나이**: 6~7세 아동과 친근한 느낌
- **성별**: 중성적 (남녀 구분 없음)
- **스타일**: 귀엽고 친근한 캐릭터 (동물, 로봇, 또는 아동형 캐릭터)
- **분위기**: 따뜻하고 격려하는 친구 같은 존재

### 표정별 가이드

#### 1. Happy (기쁨) - `character_happy.png`
**사용 시점**: 정답 선택 시
- 표정: 활짝 웃는 얼굴, 눈이 초승달 모양
- 포즈: 양손을 들어 박수 또는 엄지척
- 이펙트: 반짝이는 별 또는 하트
- 색상: 밝고 따뜻한 톤

#### 2. Neutral (중립) - `character_neutral.png`
**사용 시점**: 문제 대기, 로딩
- 표정: 편안한 미소, 눈 동그랗게
- 포즈: 서 있거나 손 흔들기
- 이펙트: 없음
- 색상: 기본 톤

#### 3. Thinking (생각) - `character_thinking.png`
**사용 시점**: 문제 제시, 생각할 시간 제공
- 표정: 입을 살짝 다물고 눈 위로 (생각 중)
- 포즈: 손을 턱에 대거나 고개 갸웃
- 이펙트: 머리 위 물음표 또는 생각 구름
- 색상: 기본 톤

#### 4. Sad (슬픔) - `character_sad.png`
**사용 시점**: 오답 선택 시 (격려 필요)
- 표정: 살짝 슬픈 얼굴, 하지만 과하지 않게
- 포즈: 손을 내밀어 위로하는 제스처
- 이펙트: 부드러운 색상
- **중요**: 아이가 좌절하지 않도록 너무 슬프지 않게!

#### 5. Excited (신남) - `character_excited.png`
**사용 시점**: 레벨업, 연속 정답, 완료
- 표정: 매우 기쁜 얼굴, 눈 반짝반짝
- 포즈: 점프하거나 팔벌려 환호
- 이펙트: 폭죽, 무지개, 별빛
- 색상: 매우 밝고 화려한 톤

---

## 🎨 스타일 레퍼런스

### 추천 스타일
1. **카툰 스타일**: 둥글고 부드러운 라인
2. **플랫 디자인**: 그림자 최소, 명확한 실루엣
3. **밝은 색감**: 파스텔보다는 선명한 색상

### 피해야 할 스타일
- ❌ 사실적인 인물 (무서울 수 있음)
- ❌ 날카로운 라인 (위협적으로 보일 수 있음)
- ❌ 어두운 색감 (우울하게 보일 수 있음)
- ❌ 복잡한 디테일 (집중력 분산)

### 참고 이미지 (예시)
- Duolingo 캐릭터 (Duo)
- Khan Academy Kids 캐릭터
- PBS Kids 캐릭터

---

## ✅ 디자이너 체크리스트

### 제작 전
- [ ] 캐릭터 콘셉트 스케치 3안 제시
- [ ] 개발자/기획자 피드백 수렴
- [ ] 최종 콘셉트 선정

### 제작 중
- [ ] 5가지 표정 모두 제작
- [ ] @1x, @2x, @3x 해상도 생성
- [ ] PNG 최적화 (< 100KB/파일)
- [ ] 투명 배경 확인

### 제작 후
- [ ] 5개 파일 모두 전달
- [ ] Figma/Sketch 원본 파일 백업
- [ ] 사용 가이드 작성 (표정별 사용 시점)

---

## 📂 파일 경로 매핑 (코드 ↔ 에셋)

| 코드 위치 | 파일 경로 | 사용 시점 |
|----------|----------|----------|
| `asset_loader_service.dart:75` | `assets/characters/character_happy.png` | 정답 시 |
| `asset_loader_service.dart:76` | `assets/characters/character_neutral.png` | 기본 |
| `asset_loader_service.dart:77` | `assets/characters/character_thinking.png` | 문제 제시 |
| `feedback_widget.dart` (추가 필요) | `assets/characters/character_sad.png` | 오답 시 |
| `feedback_widget.dart` (추가 필요) | `assets/characters/character_excited.png` | 레벨업 |

---

## 📐 기술 사양

### 파일 형식
- **기본**: PNG-24 (투명 배경)
- **최적화**: TinyPNG 또는 ImageOptim 사용
- **색상**: RGBA

### 캔버스 사이즈
- **작업 캔버스**: 1024x1024 px
- **캐릭터 영역**: 80% (여백 10% 확보)
- **배경**: 투명

### 내보내기 설정
```
Figma/Sketch/Illustrator:
- Format: PNG
- Scale: 1x, 2x, 3x
- Compression: Lossy (80% quality)
- Background: Transparent
```

---

## 🎯 테스트 시나리오

### T1: 감정 표현 명확성
- [ ] 6세 아동이 각 표정을 구분할 수 있는가?
- [ ] Happy와 Excited의 차이가 명확한가?
- [ ] Sad가 너무 슬프지 않은가?

### T2: 일관성
- [ ] 5개 캐릭터가 모두 같은 스타일인가?
- [ ] 색상 톤이 일관적인가?
- [ ] 크기 비율이 동일한가?

### T3: 기술 요구사항
- [ ] 투명 배경이 적용되었는가?
- [ ] 파일 크기가 100KB 이하인가?
- [ ] 해상도가 요구사항을 충족하는가?

---

## 💡 디자이너를 위한 팁

1. **표정은 과장되게**: 미묘한 표정은 아이들이 구분하기 어려움
2. **단순하게**: 복잡한 디테일은 작은 화면에서 안 보임
3. **명확한 실루엣**: 윤곽선만 봐도 구분 가능하도록
4. **테스트**: 실제 6세 아동에게 보여주고 피드백 받기

---

**작성일**: 2025-12-05  
**상태**: 제작 대기

