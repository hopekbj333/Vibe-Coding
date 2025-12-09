# 🎵 오디오 에셋 제작 가이드

**작성일:** 2025-12-07  
**목적:** Assessment & Training 게임용 오디오 파일 제작 및 관리

---

## 📊 오디오 파일 통계

### 필요한 오디오 타입:

| 카테고리 | 예상 파일 수 | 용도 |
|---------|------------|------|
| 지시문 (instructions) | 50개 | 각 게임 설명 |
| 문항 질문 (questions) | 660개 | 개별 문항 질문 |
| 선택지 소리 (options) | 1,980개 | 보기 소리 (3개×660) |
| 피드백 (feedback) | 10개 | 정답/오답 효과음 |
| 배경음악 (bgm) | 5개 | 게임별 배경음악 |
| **총계** | **~2,700개** | |

---

## 🗂️ 폴더 구조

```
assets/audio/
├── instructions/           # 게임 설명 (50개)
│   ├── same_sound.mp3
│   ├── syllable_clap.mp3
│   └── ...
├── questions/              # 문항 질문 (660개)
│   ├── phonological/
│   ├── auditory/
│   ├── visual/
│   ├── working_memory/
│   └── attention/
├── sounds/                 # 선택지 소리 (1,980개)
│   ├── animals/           # 동물 소리
│   ├── instruments/       # 악기 소리
│   ├── environmental/     # 환경 소리
│   ├── syllables/        # 음절 소리
│   └── phonemes/         # 음소 소리
├── feedback/              # 피드백 (10개)
│   ├── correct1.mp3
│   ├── correct2.mp3
│   ├── incorrect1.mp3
│   └── encouragement.mp3
└── bgm/                   # 배경음악 (5개)
    ├── game_light.mp3
    ├── game_focus.mp3
    └── result.mp3
```

---

## 🎙️ 녹음 우선순위

### **1순위: 지시문 (50개)** - 가장 중요!
```
각 게임 시작 시 재생되는 설명 음성
예시:
- "같은 소리를 찾아보세요"
- "박수로 음절을 쪼개보세요"
- "숨어있는 글자를 찾아보세요"

성우: 차분하고 친절한 여성 목소리 (권장)
길이: 각 3-5초
```

### **2순위: 피드백 (10개)**
```
정답/오답 시 재생
예시:
- 정답: "잘했어요!", "훌륭해요!", "멋져요!"
- 오답: "다시 한번 해볼까요?", "괜찮아요!"
- 격려: "조금만 더!", "거의 다 왔어요!"

길이: 각 1-2초
```

### **3순위: 선택지 소리 (1,980개)**
```
동물 소리: 강아지(멍멍), 고양이(야옹), 새(짹짹) 등
악기 소리: 트롬본, 트럼펫, 피아노, 드럼 등
환경 소리: 비, 바람, 물, 차 소리 등
음절/음소: 가, 나, 다, ㄱ, ㄴ, ㄷ 등

길이: 각 0.5-2초
```

---

## 🤖 TTS 활용 방법

### **Option 1: Google Cloud TTS (추천)**
- 고품질 한국어 음성
- WaveNet 음성 (자연스러움)
- 가격: 100만 글자 $16

**사용 예시:**
```python
from google.cloud import texttospeech

client = texttospeech.TextToSpeechClient()

text = "같은 소리를 찾아보세요"
synthesis_input = texttospeech.SynthesisInput(text=text)

voice = texttospeech.VoiceSelectionParams(
    language_code="ko-KR",
    name="ko-KR-Wavenet-A",  # 여성 목소리
)

audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.MP3,
    speaking_rate=0.9,  # 조금 느리게 (아동용)
)

response = client.synthesize_speech(
    input=synthesis_input,
    voice=voice,
    audio_config=audio_config,
)

with open("same_sound.mp3", "wb") as out:
    out.write(response.audio_content)
```

### **Option 2: 무료 TTS**
- **Google Translate TTS**: 간단하지만 품질 낮음
- **Web Speech API**: 브라우저 내장, 실시간 가능
- **gTTS (Python)**: 무료, Google Translate 기반

### **Option 3: 직접 녹음**
- Audacity (무료 녹음 프로그램)
- 조용한 환경에서 녹음
- 아동 친화적 목소리 (여성 성우 권장)

---

## 📝 우선순위 오디오 리스트

### **즉시 필요한 파일 (Top 10):**

```
1. audio/instructions/same_sound.mp3
   "같은 소리를 찾아보세요"

2. audio/instructions/syllable_clap.mp3
   "박수로 음절을 쪼개보세요"

3. audio/instructions/rhyme.mp3
   "같은 소리로 끝나는 것을 찾아보세요"

4. audio/feedback/correct1.mp3
   "잘했어요!"

5. audio/feedback/incorrect1.mp3
   "다시 한번 해볼까요?"

6. audio/sounds/animals/dog.mp3
   강아지 소리 (멍멍)

7. audio/sounds/animals/cat.mp3
   고양이 소리 (야옹)

8. audio/sounds/instruments/trombone.mp3
   트롬본 소리

9. audio/sounds/instruments/trumpet.mp3
   트럼펫 소리

10. audio/sounds/environmental/rain.mp3
    빗소리
```

---

## 🛠️ 빠른 시작: 테스트용 샘플 오디오

임시로 **무음 파일** 또는 **비프음**으로 테스트할 수 있습니다:

<function_calls>
<invoke name="Shell">
<parameter name="command">if (-not (Test-Path "c:\dev\literacy-assessment\assets\audio\feedback")) { New-Item -ItemType Directory -Path "c:\dev\literacy-assessment\assets\audio\feedback" -Force }