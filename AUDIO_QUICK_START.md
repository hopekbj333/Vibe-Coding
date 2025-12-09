# 🚀 오디오 파일 빠른 시작 가이드

**목적:** 30분 안에 테스트용 오디오 생성하기

---

## ⚡ 가장 빠른 방법: gTTS (무료)

### 1️⃣ **설치**
```bash
pip install gTTS
```

### 2️⃣ **실행**
```bash
cd c:\dev\literacy-assessment
python scripts\generate_tts_audio.py
```

### 3️⃣ **결과 확인**
```
assets/audio/
├── instructions/     ✅ 50개 파일 생성됨
└── feedback/         ✅ 8개 파일 생성됨
```

---

## 🎯 즉시 사용 가능한 방법

### **Option A: Web Speech API (브라우저 내장)**

Flutter 앱에서 직접 TTS 사용:

```dart
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts tts = FlutterTts();

await tts.setLanguage("ko-KR");
await tts.setSpeechRate(0.4);  // 느리게
await tts.speak("같은 소리를 찾아보세요");
```

**설치:**
```yaml
# pubspec.yaml
dependencies:
  flutter_tts: ^4.0.2
```

**장점:**
- 즉시 사용 가능
- 파일 불필요
- 무료

**단점:**
- 품질 낮음
- 플랫폼 의존적

---

### **Option B: 무료 음원 사이트 활용**

#### 동물 소리:
- https://freesound.org/ (무료 CC 라이선스)
- https://www.zapsplat.com/ (무료 음원)

#### 악기 소리:
- https://philharmonia.co.uk/resources/sound-samples/ (오케스트라 악기)

#### 환경 소리:
- https://www.soundjay.com/ (무료 효과음)

---

## 📦 미리 준비된 패키지 (추천)

**상용 음성 패키지:**
- **네이버 클로바**: 한국어 고품질 TTS
- **구글 Cloud TTS**: 다국어 지원
- **Amazon Polly**: AWS 통합

**가격:**
- 구글 TTS: 100만 글자 $16
- 네이버 클로바: 10만 글자 무료 → 유료
- Amazon Polly: 100만 글자 $4

---

## 🎬 직접 녹음 가이드

### **준비물:**
1. 마이크 (스마트폰도 가능)
2. 조용한 환경
3. Audacity (무료 프로그램)

### **녹음 설정:**
- 샘플레이트: 44.1kHz
- 비트레이트: 128kbps
- 포맷: MP3

### **녹음 팁:**
1. 아동 친화적 목소리 (여성 성우 권장)
2. 천천히, 또박또박
3. 따뜻하고 격려하는 톤
4. 배경 소음 최소화

---

## 🧪 테스트 방법

### 1. 샘플 오디오 1개만 생성
```bash
python -c "from gtts import gTTS; gTTS('잘했어요!', lang='ko').save('assets/audio/feedback/correct1.mp3')"
```

### 2. 앱에서 테스트
- JSON 파일의 audioPath 확인
- 게임 실행
- 🔊 버튼 클릭

### 3. 작동하면 전체 생성
```bash
python scripts\generate_tts_audio.py
```

---

## 📋 필수 오디오 파일 체크리스트

### 최소 필수 (10개):
- [ ] instructions/same_sound.mp3
- [ ] instructions/syllable_clap.mp3
- [ ] instructions/rhyme.mp3
- [ ] feedback/correct1.mp3
- [ ] feedback/incorrect1.mp3
- [ ] sounds/animals/dog.mp3
- [ ] sounds/animals/cat.mp3
- [ ] sounds/instruments/trombone.mp3
- [ ] sounds/instruments/trumpet.mp3
- [ ] sounds/environmental/rain.mp3

### 추가 권장 (50개):
- [ ] instructions/*.mp3 (50개 게임)
- [ ] feedback/*.mp3 (8개)

### 전체 완성 (2,700개):
- [ ] questions/*.mp3 (660개)
- [ ] sounds/*.mp3 (1,980개)

---

## 💡 현실적인 접근

### **Phase 1: MVP (지금)**
✅ 오디오 재생 버튼 구현 완료  
⏳ 피드백 8개만 생성 (gTTS)  
⏳ 지시문 50개 생성 (gTTS)

→ **약 1시간 소요**

### **Phase 2: 품질 개선**
- 전문 성우 녹음 (지시문 50개)
- 효과음 다운로드 (동물/악기/환경)

→ **약 1-2일 소요**

### **Phase 3: 완전 자동화**
- Google Cloud TTS로 전체 생성
- 자동화 스크립트 완성

→ **약 1일 소요 + $20**

---

## 🎯 지금 당장 시작하기

```bash
# 1. gTTS 설치
pip install gTTS

# 2. 스크립트 실행
cd c:\dev\literacy-assessment
python scripts\generate_tts_audio.py

# 3. 앱에서 테스트
flutter run -d chrome
r  # Hot Reload
```

---

**바로 시작하시겠어요?** 😊

*생성일: 2025-12-07*
