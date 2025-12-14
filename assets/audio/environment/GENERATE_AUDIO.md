# 테스트 오디오 파일 생성 가이드

## 빠른 시작

### 1. 필수 패키지 설치

```bash
pip install numpy pydub
```

**참고**: `pydub`는 MP3 변환을 위해 `ffmpeg`가 필요합니다.
- Windows: https://ffmpeg.org/download.html 에서 다운로드
- 또는 `pip install ffmpeg-python` (시도해볼 수 있지만 권장하지 않음)

### 2. 스크립트 실행

```bash
cd c:\dev\literacy-assessment
python scripts\generate_test_audio.py
```

### 3. 결과 확인

`assets/audio/environment/` 폴더에 다음 파일들이 생성됩니다:
- `rain.mp3` - 비 소리 (테스트용)
- `car.mp3` - 자동차 소리 (테스트용)

## 대안: 간단한 방법

pydub가 없거나 ffmpeg 설치가 어렵다면:

1. **온라인 오디오 생성기 사용**
   - https://www.audacityteam.org/ (무료 오디오 에디터)
   - 노이즈 생성 기능 사용

2. **무료 사이트에서 다운로드**
   - https://orangefreesounds.com/raining-sound/
   - https://www.chosic.com/download-audio/28297/

## 주의사항

⚠️ 생성된 파일은 **테스트용**입니다. 실제 환경음과는 다릅니다.
실제 검사에는 고품질 오디오 파일 사용을 권장합니다.

