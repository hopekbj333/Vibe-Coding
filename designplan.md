# 🎨 디자인 에셋 제작 플랜 (Design Asset Production Plan)

**프로젝트**: Literacy Assessment (문해력 기초 검사)  
**대상 사용자**: 만 6~7세 아동 (경계선지능 아동, 한글 미해득 유아)  
**작성일**: 2025-12-05  
**상태**: 준비 완료

---

## 📋 전체 개요

### 목적
글을 못 읽는 아이를 위한 **Zero-Text Interface**를 구현하기 위해 모든 UI 요소를 이미지, 아이콘, 음성으로 대체합니다.

### 핵심 디자인 철학 (agents.md 기준)
1. **Zero-Text Interface**: 텍스트 최소화, 이미지/아이콘 중심
2. **Cognitive Ease**: 명확하고 단순한 시각적 요소
3. **Gamification**: 친근하고 놀이 같은 분위기
4. **Slow Animation**: 일반 앱보다 1.5배 느린 애니메이션

---

## 🎯 전체 목표

### 정량적 목표
| 항목 | 목표 |
|------|------|
| 캐릭터 이미지 | 5개 |
| UI 아이콘/이미지 | 15개 |
| 게임 에셋 (이미지) | 100개+ |
| 효과음 | 10개 |
| 음성 안내 | 50개+ |
| 배경음악 | 3개 |

### 정성적 목표
- 아동 친화적 (밝고 따뜻한 색감)
- 명확한 시각적 구분 (큰 아이콘, 높은 대비)
- 부드럽고 격려하는 사운드
- 일관된 스타일 (캐릭터, 아이콘)

---

## 📊 Work Package 구조

| WP | 이름 | 우선순위 | 예상 소요 | 에셋 개수 |
|----|----|---------|----------|----------|
| WP D1 | 캐릭터 디자인 | **High** | 1주 | 5개 |
| WP D2 | UI 아이콘 | **High** | 3일 | 15개 |
| WP D3 | 게임 에셋 - 음운 인식 | **High** | 2주 | 50개 |
| WP D4 | 게임 에셋 - 감각/인지 | Medium | 2주 | 50개 |
| WP D5 | 사운드 에셋 | Medium | 1주 | 60개 |
| WP D6 | 애니메이션 리소스 | Low | 1주 | 10개 |

**총 예상 기간**: 6~8주 (병렬 작업 시 4주)

---

## 🎨 디자인 가이드라인

### 색상 팔레트 (DesignSystem 기준)
```
기본 색상:
- Primary Blue: #4A90E2
- Primary Green: #52C41A
- Primary Red: #F5222D
- Primary Orange: #FA8C16
- Primary Yellow: #FADB14

아동 친화적 색상:
- Child Blue: #1890FF
- Child Green: #52C41A
- Child Red: #FF4D4F
- Child Yellow: #FFC53D
- Child Purple: #9254DE
```

### 타이포그래피
- 텍스트 최소 사용 (부모 모드에서만)
- 아동 모드: 이미지/아이콘으로 대체
- 필요 시: 고딕체, Bold, 24pt 이상

### 애니메이션 원칙
- 지속 시간: 300~450ms (일반 앱의 1.5배)
- 커브: Ease-in-out (부드럽게)
- 바운스 효과: 최소화 (과도한 자극 방지)

### 버튼 크기
- 최소: 80x80 dp
- 권장: 100x100 dp
- 간격: 최소 16dp

---

## 📂 에셋 폴더 구조

```
assets/
├── characters/          # WP D1: 캐릭터 (5개)
│   ├── character_happy.png
│   ├── character_neutral.png
│   ├── character_thinking.png
│   ├── character_sad.png
│   └── character_excited.png
│
├── images/             # WP D2: UI 아이콘 (15개)
│   ├── star.png
│   ├── checkmark.png
│   ├── retry.png
│   ├── badge_*.png (10개)
│   └── icon_*.png
│
├── games/              # WP D3~D4: 게임 에셋 (100개+)
│   ├── phonological/   # 음운 인식 (50개)
│   │   ├── animals/    # 동물 (10개)
│   │   ├── objects/    # 사물 (20개)
│   │   └── syllables/  # 음절 카드 (20개)
│   │
│   ├── sensory/        # 감각 처리 (30개)
│   │   ├── instruments/ # 악기 (10개)
│   │   ├── shapes/     # 도형 (10개)
│   │   └── patterns/   # 패턴 (10개)
│   │
│   └── executive/      # 인지 제어 (20개)
│       ├── numbers/    # 숫자 (10개)
│       └── colors/     # 색상 카드 (10개)
│
└── audio/              # WP D5: 사운드 (60개)
    ├── effects/        # 효과음 (10개)
    │   ├── correct.mp3
    │   ├── incorrect.mp3
    │   ├── button_click.mp3
    │   ├── level_up.mp3
    │   └── ...
    │
    ├── voice/          # 음성 안내 (50개)
    │   ├── instructions/ # 지시문
    │   └── encouragement/ # 격려
    │
    └── music/          # 배경음악 (3개)
        ├── game_bgm.mp3
        ├── result_bgm.mp3
        └── menu_bgm.mp3
```

---

## 🚀 작업 로드맵

### Phase 1: MVP 에셋 (4주) - 앱 출시 최소 요건
```
Week 1-2: WP D1 (캐릭터) + WP D2 (UI 아이콘)
Week 3-4: WP D3 (음운 인식 게임 에셋)
```

### Phase 2: 확장 에셋 (2주) - 전체 기능 지원
```
Week 5-6: WP D4 (감각/인지 게임 에셋)
```

### Phase 3: 완성도 향상 (2주) - 출시 준비
```
Week 7: WP D5 (사운드 에셋)
Week 8: WP D6 (애니메이션 리소스)
```

---

## 📦 Work Package 상세

| WP | 문서 | 설명 |
|----|------|------|
| WP D1 | `designwp1_characters.md` | 캐릭터 5종 (표정별) |
| WP D2 | `designwp2_ui_icons.md` | UI 아이콘 15개 |
| WP D3 | `designwp3_phonological.md` | 음운 인식 게임 에셋 50개 |
| WP D4 | `designwp4_sensory_executive.md` | 감각/인지 게임 에셋 50개 |
| WP D5 | `designwp5_sound.md` | 사운드 에셋 60개 |
| WP D6 | `designwp6_animation.md` | 애니메이션 리소스 10개 |

---

## 🔧 기술 사양

### 이미지
- **형식**: PNG (투명 배경 필요), SVG (아이콘)
- **해상도**: 
  - 캐릭터: 512x512 px (@2x), 1024x1024 px (@3x)
  - UI 아이콘: 128x128 px (@2x), 256x256 px (@3x)
  - 게임 에셋: 256x256 px (@2x), 512x512 px (@3x)
- **색상 모드**: RGBA
- **용량**: 이미지당 < 100KB (최적화 필수)

### 오디오
- **형식**: MP3 (호환성) 또는 AAC (품질)
- **비트레이트**: 128 kbps
- **샘플레이트**: 44.1 kHz
- **채널**: Mono (효과음), Stereo (음악)
- **지속 시간**:
  - 효과음: 0.5~2초
  - 음성 안내: 3~10초
  - 배경음악: 1~2분 (루프)
- **용량**: 파일당 < 500KB

---

## 👥 협업 프로세스

### 디자이너 → 개발자
1. WP별 에셋 제작
2. 디자이너 체크리스트 완료
3. 에셋 전달 (Figma, Google Drive 등)
4. 개발자 검토 및 피드백
5. 수정 후 최종 전달

### 개발자 → 디자이너
1. 에셋 요구사항 전달 (이 문서)
2. 참고 자료 제공 (스타일 가이드)
3. 피드백 제공
4. 코드 통합 후 테스트 결과 공유

---

## ✅ 체크리스트

### Phase 1 (MVP)
- [ ] WP D1: 캐릭터 디자인 완료
- [ ] WP D2: UI 아이콘 완료
- [ ] WP D3: 음운 인식 게임 에셋 완료
- [ ] 개발자 코드 통합 완료
- [ ] MVP 테스트 완료

### Phase 2 (확장)
- [ ] WP D4: 감각/인지 게임 에셋 완료
- [ ] 개발자 코드 통합 완료
- [ ] 전체 기능 테스트 완료

### Phase 3 (완성)
- [ ] WP D5: 사운드 에셋 완료
- [ ] WP D6: 애니메이션 리소스 완료
- [ ] 최종 통합 테스트 완료
- [ ] 앱 스토어 제출 준비 완료

---

## 📚 참고 문서

- `agents.md` - 핵심 디자인 철학
- `milestone2.md`, `milestone3.md` - 기능 요구사항
- `lib/core/design/design_system.dart` - 색상, 타이포그래피
- `lib/core/widgets/README.md` - UI 컴포넌트 가이드

---

**다음**: WP D1~D6 상세 문서 작성

*Last Updated: 2025-12-05*

