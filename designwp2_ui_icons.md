# 🎨 Design WP D2: UI 아이콘 (UI Icons)

**우선순위**: **High** (MVP 필수)  
**예상 소요**: 3일  
**담당**: UI 디자이너  

---

## 📋 에셋 목록

### 기본 UI 아이콘 (6개)

| 파일명 | 용도 | 사이즈 | 형식 |
|--------|------|--------|------|
| `star.png` | 점수, 즐겨찾기 | 128x128 px | PNG |
| `checkmark.png` | 정답 표시 | 128x128 px | PNG |
| `retry.png` | 재시도 버튼 | 128x128 px | PNG |
| `play.png` | 게임 시작 | 128x128 px | PNG |
| `pause.png` | 일시정지 | 128x128 px | PNG |
| `home.png` | 홈으로 이동 | 128x128 px | PNG |

### 배지 아이콘 (9개) - WP 3.6 장기 추적

| 파일명 | 설명 | 사이즈 | 형식 |
|--------|------|--------|------|
| `badge_bronze.png` | 브론즈 배지 | 256x256 px | PNG |
| `badge_silver.png` | 실버 배지 | 256x256 px | PNG |
| `badge_gold.png` | 골드 배지 | 256x256 px | PNG |
| `badge_first_complete.png` | 첫 완료 배지 | 256x256 px | PNG |
| `badge_perfect.png` | 만점 배지 | 256x256 px | PNG |
| `badge_speed.png` | 빠른 완료 배지 | 256x256 px | PNG |
| `badge_streak.png` | 연속 학습 배지 | 256x256 px | PNG |
| `badge_master.png` | 마스터 배지 | 256x256 px | PNG |
| `badge_champion.png` | 챔피언 배지 | 256x256 px | PNG |

**총 15개**

---

## 🎨 디자인 가이드

### 아이콘 스타일
- **타입**: Flat Design (플랫 디자인)
- **라인**: 둥글고 부드러운 라운드 코너
- **색상**: 명확하고 밝은 색상
- **그림자**: 최소 또는 없음
- **두께**: 라인 두께 8~10px (명확하게 보이도록)

### 색상 가이드

#### 기본 UI 아이콘
```
- star.png: 밝은 노란색 (#FADB14)
- checkmark.png: 밝은 초록색 (#52C41A)
- retry.png: 밝은 파란색 (#4A90E2)
- play.png: 밝은 초록색 (#52C41A)
- pause.png: 밝은 주황색 (#FA8C16)
- home.png: 밝은 파란색 (#4A90E2)
```

#### 배지 아이콘
```
- Bronze: #CD7F32 (구리색)
- Silver: #C0C0C0 (은색)
- Gold: #FFD700 (금색)
- 기타: 배지 목적에 맞는 색상 (예: 스피드 = 빨강, 연속 = 불꽃)
```

### 크기 및 여백
- **아이콘 영역**: 전체 캔버스의 70%
- **여백**: 상하좌우 15% (터치 영역 확보)
- **라운드 코너**: 10~15px

---

## 📐 기술 사양

### 파일 형식
- **기본**: PNG-24 (투명 배경)
- **대안**: SVG (벡터, 확장성 좋음)
- **최적화**: < 50KB/파일

### 해상도
- @1x: 64x64 px (기본 아이콘)
- @2x: 128x128 px (UI 아이콘)
- @3x: 256x256 px (배지)

### 내보내기
```
Figma:
1. 각 아이콘 선택
2. Export → PNG
3. Scale: 1x, 2x, 3x
4. Suffix: @2x, @3x
5. Compress: Enabled
```

---

## 📂 파일 경로 매핑

| 코드 위치 | 파일 경로 | 사용 위치 |
|----------|----------|----------|
| `asset_loader_service.dart:78` | `assets/images/star.png` | 점수, 배지 |
| `asset_loader_service.dart:79` | `assets/images/checkmark.png` | 정답 표시 |
| `asset_loader_service.dart:80` | `assets/images/retry.png` | 재시도 버튼 |
| `feedback_widget.dart` | `assets/images/play.png` | 게임 시작 |
| `badge_collection_widget.dart` | `assets/images/badge_*.png` | 배지 시스템 |

---

## ✅ 디자이너 체크리스트

### 제작 전
- [ ] 아이콘 스타일 가이드 검토
- [ ] 색상 팔레트 확인
- [ ] 참고 이미지 수집 (Duolingo, Khan Academy Kids 등)

### 제작 중 (기본 아이콘 6개)
- [ ] star.png 제작
- [ ] checkmark.png 제작
- [ ] retry.png 제작
- [ ] play.png 제작
- [ ] pause.png 제작
- [ ] home.png 제작

### 제작 중 (배지 아이콘 9개)
- [ ] badge_bronze.png 제작
- [ ] badge_silver.png 제작
- [ ] badge_gold.png 제작
- [ ] badge_first_complete.png 제작
- [ ] badge_perfect.png 제작
- [ ] badge_speed.png 제작
- [ ] badge_streak.png 제작
- [ ] badge_master.png 제작
- [ ] badge_champion.png 제작

### 최적화
- [ ] PNG 최적화 (< 50KB)
- [ ] 투명 배경 확인
- [ ] @1x, @2x, @3x 생성

### 전달
- [ ] 15개 파일 모두 전달 (45개 파일 - 해상도별)
- [ ] Figma/Sketch 원본 파일 공유
- [ ] 사용 가이드 문서 작성

---

## 🎯 테스트 시나리오

### T1: 인식성
- [ ] 6세 아동이 각 아이콘의 의미를 이해할 수 있는가?
- [ ] 아이콘만 봐도 기능을 추측할 수 있는가?

### T2: 일관성
- [ ] 모든 아이콘이 같은 스타일인가?
- [ ] 크기 비율이 일관적인가?

### T3: 가독성
- [ ] 작은 화면(스마트폰)에서도 명확한가?
- [ ] 배경색이 바뀌어도 잘 보이는가?

---

## 💡 디자이너를 위한 팁

1. **명확한 실루엣**: 윤곽선만 봐도 의미 파악 가능
2. **충분한 크기**: 아이의 손가락(약 10mm)이 정확히 터치할 수 있도록
3. **대비**: 배경과 아이콘의 명도 차이 최소 4.5:1 (WCAG AA)
4. **테스트**: 실제 6세 아동에게 보여주고 "이게 뭐야?"라고 물어보기

---

**작성일**: 2025-12-05  
**상태**: 제작 대기

