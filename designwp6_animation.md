# ✨ Design WP D6: 애니메이션 리소스 (Animation Resources)

**우선순위**: Low (완성도 향상용)  
**예상 소요**: 1주  
**담당**: 모션 디자이너  

---

## 📋 에셋 목록 개요

| 카테고리 | 개수 | 용도 |
|---------|------|------|
| 캐릭터 애니메이션 | 5개 | 캐릭터 움직임 |
| 파티클 효과 | 3개 | 정답, 레벨업 효과 |
| 로딩 애니메이션 | 2개 | 로딩, 전환 |
| **총 10개** | | |

---

## 🎭 카테고리 1: 캐릭터 애니메이션 (5개)

**형식**: Lottie JSON 또는 GIF 또는 스프라이트 시트

| 파일명 | 애니메이션 | 지속 시간 | 반복 |
|--------|-----------|----------|------|
| `char_idle.json` | 숨쉬기, 깜빡이기 | 2초 | Loop |
| `char_happy.json` | 점프하며 기뻐함 | 1.5초 | Once |
| `char_thinking.json` | 고개 갸웃, 생각 중 | 2초 | Loop |
| `char_sad.json` | 고개 숙임, 위로 | 2초 | Once |
| `char_excited.json` | 팔 흔들며 환호 | 2초 | Once |

**파일 경로**: `assets/animations/characters/`

---

## ✨ 카테고리 2: 파티클 효과 (3개)

| 파일명 | 효과 | 용도 | 형식 |
|--------|------|------|------|
| `particle_stars.json` | 반짝이는 별 | 정답 시 | Lottie |
| `particle_confetti.json` | 색종이 폭죽 | 레벨업 시 | Lottie |
| `particle_sparkle.json` | 반짝임 | 배지 획득 시 | Lottie |

**파일 경로**: `assets/animations/particles/`

---

## ⏳ 카테고리 3: 로딩 애니메이션 (2개)

| 파일명 | 애니메이션 | 용도 | 형식 |
|--------|-----------|------|------|
| `loading_spinner.json` | 회전하는 별 | 로딩 중 | Lottie |
| `transition_wipe.json` | 화면 전환 효과 | 화면 이동 | Lottie |

**파일 경로**: `assets/animations/ui/`

---

## 🎨 디자인 가이드

### 애니메이션 원칙 (agents.md 기준)
1. **느린 속도**: 일반 앱보다 1.5배 느리게 (300~450ms)
2. **부드러움**: Ease-in-out 커브 사용
3. **과장 최소**: 바운스, 오버슈트 최소화
4. **명확성**: 애니메이션 의도가 즉시 파악 가능

### 캐릭터 애니메이션
- **Idle**: 미세한 움직임 (숨쉬기, 깜빡이기)
- **Happy**: 위로 점프, 양손 들기
- **Thinking**: 고개 갸웃, 손을 턱에
- **Sad**: 고개 살짝 숙임, 위로하는 제스처
- **Excited**: 팔 흔들기, 점프하며 환호

### 파티클 효과
- **Stars**: 작은 별이 반짝이며 사라짐
- **Confetti**: 색종이가 위에서 떨어짐
- **Sparkle**: 반짝임이 퍼져나감

---

## 🔧 기술 사양

### Lottie JSON
- **도구**: Adobe After Effects + Bodymovin
- **프레임레이트**: 30 FPS (60 FPS X - 성능 고려)
- **해상도**: 512x512 px
- **용량**: < 100KB/파일
- **레이어**: 최소화 (성능)

### 스프라이트 시트 (대안)
- **형식**: PNG
- **해상도**: 512x512 px/프레임
- **프레임 수**: 10~20 프레임
- **배치**: 가로 10 프레임 x 세로 2~4 프레임
- **용량**: < 500KB/파일

### GIF (비추천 - 용량 문제)
- **해상도**: 256x256 px
- **프레임레이트**: 15 FPS
- **색상**: 256 colors
- **용량**: < 200KB/파일

---

## 📂 파일 경로 매핑

| 코드 위치 | 파일 경로 | 사용 위치 |
|----------|----------|----------|
| `feedback_widget.dart` (추가 필요) | `assets/animations/characters/char_happy.json` | 정답 피드백 |
| `feedback_widget.dart` (추가 필요) | `assets/animations/particles/particle_stars.json` | 정답 효과 |
| `level_display_widget.dart` (추가 필요) | `assets/animations/particles/particle_confetti.json` | 레벨업 |
| `badge_collection_widget.dart` (추가 필요) | `assets/animations/particles/particle_sparkle.json` | 배지 획득 |
| 로딩 화면 | `assets/animations/ui/loading_spinner.json` | 로딩 |

---

## ✅ 디자이너 체크리스트

### 제작 전
- [ ] Lottie vs 스프라이트 시트 결정
- [ ] After Effects 프로젝트 설정
- [ ] 샘플 애니메이션 1개 제작 (피드백용)

### 캐릭터 애니메이션 (5개)
- [ ] char_idle.json 제작
- [ ] char_happy.json 제작
- [ ] char_thinking.json 제작
- [ ] char_sad.json 제작
- [ ] char_excited.json 제작

### 파티클 효과 (3개)
- [ ] particle_stars.json 제작
- [ ] particle_confetti.json 제작
- [ ] particle_sparkle.json 제작

### 로딩 애니메이션 (2개)
- [ ] loading_spinner.json 제작
- [ ] transition_wipe.json 제작

### 최적화
- [ ] Lottie 최적화 (< 100KB)
- [ ] 프레임레이트 확인 (30 FPS)
- [ ] 레이어 수 최소화

### 전달
- [ ] 10개 파일 전달
- [ ] After Effects 원본 파일 공유
- [ ] 재생 가이드 작성

---

## 🎯 테스트 시나리오

### T1: 성능
- [ ] 모바일 기기에서 버벅임 없이 재생되는가?
- [ ] 메모리 사용량이 적절한가?
- [ ] 배터리 소모가 적은가?

### T2: 적절성
- [ ] 애니메이션이 너무 빠르지 않은가?
- [ ] 아동이 이해하기 쉬운가?
- [ ] 집중을 방해하지 않는가?

### T3: 일관성
- [ ] 캐릭터 스타일이 일관적인가?
- [ ] 속도가 일정한가?
- [ ] 색상이 디자인 시스템과 일치하는가?

---

## 💡 디자이너를 위한 팁

### Lottie 최적화
1. **레이어 병합**: 불필요한 레이어 합치기
2. **이미지 임베드 회피**: 벡터만 사용
3. **키프레임 최소화**: 필수 키프레임만 유지
4. **Bodymovin 설정**: "Simplify paths" 활성화

### 애니메이션 타이밍
- **Idle**: 2초 루프 (느긋하게)
- **Happy/Excited**: 1.5초 (빠르지만 과하지 않게)
- **Thinking**: 2초 루프 (생각하는 동작)
- **Sad**: 2초 (천천히, 부드럽게)

### 파티클 효과
- **Stars**: 5~10개 별, 랜덤 위치에서 반짝
- **Confetti**: 20~30개 색종이, 위에서 떨어짐
- **Sparkle**: 중앙에서 퍼져나가는 빛

---

## 🔄 대안: 코드 애니메이션

애니메이션 파일 없이 Flutter 코드로 구현 가능:

```dart
// 현재 구현된 코드 애니메이션 (파일 불필요)
- FeedbackWidget: 정답/오답 애니메이션 (코드 기반)
- ShakeAnimation: 흔들림 효과 (코드 기반)
- ScaleAnimation: 크기 변화 (코드 기반)
```

**결론**: WP D6는 선택사항입니다. 코드 기반 애니메이션으로 충분할 수 있습니다.

---

**작성일**: 2025-12-05  
**상태**: 제작 대기 (선택사항)

