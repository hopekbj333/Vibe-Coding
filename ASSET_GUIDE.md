# 🎨 에셋 가이드: 무료 오픈소스 리소스 활용

**프로젝트**: Literacy Assessment  
**목적**: 무예산으로 데모/프로토타입 제작  
**작성일**: 2025-12-05

---

## 📂 에셋 폴더 구조

```
assets/
├── characters/          # 캐릭터 5종 (감정별)
├── images/             # UI 아이콘 15개
├── games/              # 게임 에셋
│   └── phonological/   # 음운 인식 게임
│       ├── animals/    # 동물 10개
│       ├── objects/    # 사물 20개
│       └── syllables/  # 음절 카드 20개
└── audio/              # 오디오 에셋
    ├── effects/        # 효과음 10개
    ├── voice/          # 음성 안내 50개+
    └── music/          # 배경음악 3개
```

---

## 🆓 무료 오픈소스 리소스 사이트

### 🎭 1. 캐릭터 이미지 (WP D1)

#### Freepik (무료 + 유료)
- 🌐 https://www.freepik.com/
- 🔍 검색어: "cute character", "kids mascot", "friendly robot"
- 📜 **라이선스**: 무료 플랜 (출처 표시 필요)
- 💰 프리미엄: $9.99/월 (출처 표시 불필요)

#### Flaticon (아이콘/캐릭터)
- 🌐 https://www.flaticon.com/
- 🔍 검색어: "happy face", "thinking emoji", "excited character"
- 📜 **라이선스**: 무료 (출처 표시 필요)

#### Storyset (일러스트)
- 🌐 https://storyset.com/
- 🔍 카테고리: Education, Kids
- 📜 **라이선스**: 무료 (출처 표시 필요)
- ⭐ **추천**: 아동 친화적 스타일

#### OpenGameArt (게임용)
- 🌐 https://opengameart.org/
- 🔍 검색어: "character sprite", "mascot"
- 📜 **라이선스**: CC0, CC-BY (확인 필수)

---

### 🎨 2. UI 아이콘 (WP D2)

#### Material Icons (Google)
- 🌐 https://fonts.google.com/icons
- 📦 Flutter: `Icons.star`, `Icons.check`, etc.
- 📜 **라이선스**: Apache 2.0 (무료 상업 이용)
- ⭐ **추천**: 이미 Flutter에 포함됨!

#### Heroicons
- 🌐 https://heroicons.com/
- 📜 **라이선스**: MIT (무료 상업 이용)
- 💾 다운로드: SVG 파일

#### Feather Icons
- 🌐 https://feathericons.com/
- 📜 **라이선스**: MIT
- 💾 다운로드: SVG 파일

#### Phosphor Icons
- 🌐 https://phosphoricons.com/
- 📜 **라이선스**: MIT
- ⭐ **추천**: 아동용으로 적합한 둥근 스타일

---

### 🐾 3. 게임 에셋 (WP D3)

#### 동물 이미지
**Freepik**
- 🔍 검색어: "cartoon animal", "cute animal icon"
- 📂 카테고리: Animals, Nature

**Vecteezy**
- 🌐 https://www.vecteezy.com/
- 🔍 검색어: "animal illustration"
- 📜 **라이선스**: 무료 (출처 표시 필요)

**OpenClipArt**
- 🌐 https://openclipart.org/
- 📜 **라이선스**: CC0 (Public Domain)
- ⭐ **추천**: 출처 표시 불필요!

#### 사물 이미지
**Noun Project**
- 🌐 https://thenounproject.com/
- 🔍 검색어: "apple", "book", "car", etc.
- 📜 **라이선스**: 무료 (출처 표시 필요)

**Flaticon**
- 다양한 사물 아이콘
- PNG, SVG 지원

---

### 🔊 4. 오디오 에셋 (WP D5)

#### 효과음
**Freesound**
- 🌐 https://freesound.org/
- 🔍 검색어: "correct", "wrong", "button click", "level up"
- 📜 **라이선스**: CC0, CC-BY (확인 필수)

**Zapsplat**
- 🌐 https://www.zapsplat.com/
- 📦 카테고리: Game Sounds, UI Sounds
- 📜 **라이선스**: 무료 (출처 표시 필요)

**Mixkit**
- 🌐 https://mixkit.co/free-sound-effects/
- 📜 **라이선스**: Mixkit License (무료 상업 이용)
- ⭐ **추천**: 출처 표시 불필요!

#### 배경음악
**Bensound**
- 🌐 https://www.bensound.com/
- 📦 카테고리: Acoustic, Kids
- 📜 **라이선스**: 무료 (출처 표시 필요)

**Incompetech**
- 🌐 https://incompetech.com/music/
- 📜 **라이선스**: CC-BY 4.0
- 🎵 Kevin MacLeod의 무료 음악

#### 음성 안내 (TTS)
**Google Cloud TTS** (무료 할당량)
- 🌐 https://cloud.google.com/text-to-speech
- 💰 무료: 월 100만 자
- ⭐ **추천**: 한국어 품질 우수

**네이버 Clova Voice** (무료)
- 🌐 https://www.ncloud.com/product/aiService/clovaVoice
- 💰 무료: 월 100만 자
- ⭐ **추천**: 한국어 자연스러움

---

## 📝 라이선스 요구사항

### 출처 표시가 필요한 경우
앱 내 "크레딧" 또는 "정보" 화면에 다음과 같이 표시:

```
사용된 리소스:
- 캐릭터 이미지: Freepik (www.freepik.com)
- 아이콘: Flaticon (www.flaticon.com)
- 효과음: Freesound (www.freesound.org)
```

### 출처 표시가 불필요한 경우
- Material Icons (Google)
- CC0 (Public Domain) 라이선스
- Mixkit License
- 프리미엄 플랜 (Freepik Premium 등)

---

## 🚀 빠른 시작 가이드

### Phase 1: 필수 에셋 (1일)

#### 1️⃣ 캐릭터 5종 다운로드
```
검색: Freepik "cute character emotions"
다운로드: PNG, 512x512 px
저장: assets/characters/character_[emotion].png
```

#### 2️⃣ UI 아이콘 (Flutter 기본 아이콘 사용)
```dart
// 코드에서 Material Icons 사용 (다운로드 불필요)
Icon(Icons.star)
Icon(Icons.check_circle)
Icon(Icons.refresh)
```

#### 3️⃣ 게임 에셋 다운로드
```
동물: Flaticon "cartoon animals" (10개)
사물: Noun Project "fruit", "object" (20개)
음절 카드: Figma/Canva로 직접 제작 (20개) - 아래 참고
```

---

## 🎨 음절 카드 직접 제작 (Canva 무료)

### Canva 템플릿
1. 🌐 https://www.canva.com/ 접속 (무료 계정)
2. "200 x 200 px" 디자인 생성
3. 배경: 색상 선택 (파랑, 초록, 노랑, 빨강, 보라)
4. 텍스트: 한글 음절 입력 (가, 나, 다...)
   - 폰트: 고딕체 Bold
   - 크기: 120pt
   - 색상: 흰색 또는 검정
5. 테두리: 라운드 코너 적용
6. 다운로드: PNG, 투명 배경

### 일괄 제작 팁
1. 첫 카드 완성
2. 복사 → 색상/텍스트만 변경
3. 20개 일괄 다운로드

---

## 💻 Placeholder 위젯 사용법

에셋이 준비되기 전에는 코드 기반 Placeholder를 사용하세요.

### 사용 예시

#### 캐릭터 표시
```dart
import 'package:literacy_assessment/core/widgets/placeholder_image_widget.dart';

// 기쁜 캐릭터
CharacterPlaceholder(
  emotion: CharacterEmotion.happy,
  size: 200,
)

// 생각하는 캐릭터
CharacterPlaceholder(
  emotion: CharacterEmotion.thinking,
  size: 150,
)
```

#### 게임 에셋 표시
```dart
GameAssetPlaceholder(
  label: '고양이',
  size: 150,
)

GameAssetPlaceholder(
  label: '사과',
  size: 120,
)
```

#### UI 아이콘 표시
```dart
IconPlaceholder(
  label: '별',
  size: 80,
)

BadgePlaceholder(
  label: '골드 배지',
  size: 120,
)
```

### 실제 에셋으로 교체
```dart
// Before (Placeholder)
CharacterPlaceholder(emotion: CharacterEmotion.happy)

// After (실제 에셋)
Image.asset(
  'assets/characters/character_happy.png',
  width: 200,
  height: 200,
)
```

---

## ✅ 체크리스트: MVP 에셋 다운로드 (1일 작업)

### WP D1: 캐릭터 (5개)
- [ ] character_happy.png - Freepik 다운로드
- [ ] character_neutral.png - Freepik 다운로드
- [ ] character_thinking.png - Freepik 다운로드
- [ ] character_sad.png - Freepik 다운로드
- [ ] character_excited.png - Freepik 다운로드

### WP D2: UI 아이콘 (6개 - Material Icons 사용)
- [ ] 코드에서 Material Icons 사용 (다운로드 불필요)

### WP D2: 배지 (9개)
- [ ] badge_bronze.png - Flaticon 다운로드
- [ ] badge_silver.png - Flaticon 다운로드
- [ ] badge_gold.png - Flaticon 다운로드
- [ ] badge_first_complete.png
- [ ] badge_perfect.png
- [ ] badge_speed.png
- [ ] badge_streak.png
- [ ] badge_master.png
- [ ] badge_champion.png

### WP D3: 동물 (10개)
- [ ] animal_cat.png - Flaticon
- [ ] animal_dog.png
- [ ] animal_bird.png
- [ ] animal_pig.png
- [ ] animal_cow.png
- [ ] animal_duck.png
- [ ] animal_frog.png
- [ ] animal_lion.png
- [ ] animal_elephant.png
- [ ] animal_rabbit.png

### WP D3: 사물 (20개)
- [ ] object_apple.png - Noun Project
- [ ] object_banana.png
- [ ] (나머지 18개...)

### WP D3: 음절 카드 (20개)
- [ ] syllable_가.png - Canva 제작
- [ ] syllable_나.png
- [ ] (나머지 18개...)

### WP D5: 효과음 (10개)
- [ ] correct.mp3 - Mixkit
- [ ] incorrect.mp3
- [ ] button_click.mp3
- [ ] level_up.mp3
- [ ] (나머지 6개...)

---

## 🎯 다음 단계

### 지금 바로 (오늘)
1. ✅ 폴더 구조 생성 완료
2. ✅ Placeholder 위젯 생성 완료
3. 🔄 **Freepik에서 캐릭터 5종 다운로드**
4. 🔄 **Flaticon에서 동물 10개 다운로드**

### 내일
5. Canva로 음절 카드 20개 제작
6. Noun Project에서 사물 20개 다운로드
7. Mixkit에서 효과음 10개 다운로드

### 3일 후
8. 모든 에셋 최적화 (< 100KB/파일)
9. assets/ 폴더에 배치
10. 앱 실행 및 테스트

---

## 📞 도움이 필요하면?

### 에셋 검색이 어려운 경우
```
검색 팁:
- 영어 키워드 사용 (cartoon, cute, kids)
- 필터: PNG, Transparent Background
- 정렬: Popular, Free
```

### 라이선스 확인 방법
1. 다운로드 페이지에서 "License" 확인
2. CC0 (Public Domain) = 출처 표시 불필요
3. CC-BY = 출처 표시 필요
4. 상업 이용(Commercial Use) 가능 확인

### 파일 최적화 도구
- **TinyPNG**: https://tinypng.com/ (PNG 최적화)
- **SVGOMG**: https://jakearchibald.github.io/svgomg/ (SVG 최적화)
- **Online Audio Converter**: https://online-audio-converter.com/ (오디오 변환)

---

**작성일**: 2025-12-05  
**버전**: 1.0  
**상태**: 사용 가능

