#!/usr/bin/env python3
"""
테스트용 오디오 파일 생성 스크립트
비 소리, 자동차 소리 등의 환경음 테스트 파일 생성
"""

import os
import sys
import numpy as np
from pathlib import Path

# 출력 디렉토리
BASE_DIR = Path(__file__).parent.parent
ENVIRONMENT_AUDIO_DIR = BASE_DIR / "assets" / "audio" / "environment"

def generate_rain_sound(output_path: Path, duration: float = 3.0, sample_rate: int = 44100):
    """
    비 소리 비슷한 테스트 오디오 생성
    여러 주파수의 화이트 노이즈를 조합하여 비소리처럼 들리게 함
    """
    print(f"🌧️ 비 소리 생성 중: {output_path}")
    
    # 시간 배열
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    
    # 여러 주파수의 노이즈를 조합
    # 비소리는 주로 낮은 주파수(500-2000Hz)에서 발생
    noise = np.random.normal(0, 0.3, len(t))
    
    # 주파수 필터 적용 (비소리처럼 들리게)
    for freq in [500, 1000, 1500, 2000]:
        sine_component = 0.1 * np.sin(2 * np.pi * freq * t)
        noise += sine_component
    
    # 진폭 조절 (너무 크지 않게)
    noise = noise * 0.5
    noise = np.clip(noise, -1.0, 1.0)
    
    # 16-bit PCM으로 변환
    audio_pcm = np.int16(noise * 32767)
    
    # WAV로 저장
    import wave
    with wave.open(str(output_path.with_suffix('.wav')), 'wb') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_pcm.tobytes())
    
    # MP3로 변환 (pydub 사용 가능한 경우)
    try:
        from pydub import AudioSegment
        audio = AudioSegment.from_wav(str(output_path.with_suffix('.wav')))
        audio.export(str(output_path), format='mp3')
        # 임시 WAV 파일 삭제
        output_path.with_suffix('.wav').unlink()
        print(f"✅ 생성 완료: {output_path}")
    except ImportError:
        print(f"⚠️ pydub 미설치. WAV 파일로 저장: {output_path.with_suffix('.wav')}")
        print("   MP3 변환을 원하면: pip install pydub")
        print("   또는 WAV 파일을 MP3로 변환해주세요.")
    except Exception as e:
        print(f"⚠️ MP3 변환 실패: {e}")
        print(f"   WAV 파일 사용: {output_path.with_suffix('.wav')}")

def generate_car_sound(output_path: Path, duration: float = 2.0, sample_rate: int = 44100):
    """
    자동차 소리 비슷한 테스트 오디오 생성
    """
    print(f"🚗 자동차 소리 생성 중: {output_path}")
    
    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    
    # 자동차 엔진 소리는 낮은 주파수
    noise = np.random.normal(0, 0.2, len(t))
    for freq in [200, 400, 600]:
        sine_component = 0.15 * np.sin(2 * np.pi * freq * t)
        noise += sine_component
    
    noise = noise * 0.6
    noise = np.clip(noise, -1.0, 1.0)
    
    audio_pcm = np.int16(noise * 32767)
    
    import wave
    with wave.open(str(output_path.with_suffix('.wav')), 'wb') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_pcm.tobytes())
    
    try:
        from pydub import AudioSegment
        audio = AudioSegment.from_wav(str(output_path.with_suffix('.wav')))
        audio.export(str(output_path), format='mp3')
        output_path.with_suffix('.wav').unlink()
        print(f"✅ 생성 완료: {output_path}")
    except ImportError:
        print(f"⚠️ pydub 미설치. WAV 파일로 저장: {output_path.with_suffix('.wav')}")
    except Exception as e:
        print(f"⚠️ MP3 변환 실패: {e}")

def main():
    """메인 함수"""
    # 디렉토리 생성
    ENVIRONMENT_AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    
    # 필요한 라이브러리 확인
    try:
        import numpy as np
    except ImportError:
        print("❌ numpy가 설치되지 않았습니다.")
        print("설치: pip install numpy")
        sys.exit(1)
    
    try:
        import wave
    except ImportError:
        print("❌ wave 모듈을 찾을 수 없습니다. (표준 라이브러리인데 이상합니다)")
        sys.exit(1)
    
    print("🎵 테스트 오디오 파일 생성 시작...\n")
    
    # 비 소리 생성
    rain_path = ENVIRONMENT_AUDIO_DIR / "rain.mp3"
    generate_rain_sound(rain_path, duration=3.0)
    
    # 자동차 소리 생성
    car_path = ENVIRONMENT_AUDIO_DIR / "car.mp3"
    generate_car_sound(car_path, duration=2.0)
    
    print("\n✨ 생성 완료!")
    print(f"📁 위치: {ENVIRONMENT_AUDIO_DIR}")
    print("\n⚠️ 참고: 이 파일들은 테스트용입니다.")
    print("   실제 환경음과는 다를 수 있습니다.")

if __name__ == "__main__":
    main()

