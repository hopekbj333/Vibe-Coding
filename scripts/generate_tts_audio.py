#!/usr/bin/env python3
"""
TTS를 사용하여 오디오 파일 자동 생성
Google Cloud TTS 또는 gTTS 사용
"""

import os
from pathlib import Path

# Option 1: Google Cloud TTS (고품질)
try:
    from google.cloud import texttospeech
    USE_GOOGLE_TTS = True
except ImportError:
    USE_GOOGLE_TTS = False
    print("⚠️ Google Cloud TTS 미설치. gTTS 사용 권장: pip install gTTS")

# Option 2: gTTS (무료)
try:
    from gtts import gTTS
    USE_GTTS = True
except ImportError:
    USE_GTTS = False
    print("⚠️ gTTS 미설치: pip install gTTS")

# 출력 디렉토리
BASE_DIR = Path(__file__).parent.parent
AUDIO_DIR = BASE_DIR / "assets" / "audio"

# 1. 지시문 (Instructions) - 최우선
INSTRUCTIONS = {
    "same_sound.mp3": "같은 소리를 찾아보세요",
    "different_sound.mp3": "다른 소리를 찾아보세요",
    "syllable_clap.mp3": "박수로 음절을 쪼개보세요",
    "rhyme.mp3": "같은 소리로 끝나는 것을 찾아보세요",
    "syllable_merge.mp3": "음절을 합쳐서 단어를 만드세요",
    "syllable_split.mp3": "단어를 음절로 나눠보세요",
    "rhythm_follow.mp3": "리듬을 따라 박수를 쳐보세요",
    "onset_separation.mp3": "첫 소리를 분리해보세요",
    "phoneme_synthesis.mp3": "소리를 합쳐서 단어를 만드세요",
    "phoneme_substitution.mp3": "소리를 바꿔서 새로운 단어를 만드세요",
    "animal_sound_story.mp3": "동물 소리 이야기를 들어보세요",
    "environmental_sound.mp3": "주변 소리를 구별해보세요",
    "volume_comparison.mp3": "더 큰 소리를 찾아보세요",
    "pitch_discrimination.mp3": "더 높은 소리를 찾아보세요",
    "hidden_letter.mp3": "숨어있는 글자를 찾아보세요",
    "letter_direction.mp3": "방향이 다른 글자를 찾아보세요",
    "mirror_symmetry.mp3": "대칭인 글자를 찾아보세요",
    "card_match.mp3": "같은 카드를 찾아보세요",
    "digit_span.mp3": "숫자를 순서대로 기억하세요",
    "reverse_speak.mp3": "거꾸로 말해보세요",
    "go_no_go_basic.mp3": "지시한 것만 터치하세요",
    "stroop.mp3": "색깔 이름을 말해보세요",
    "target_hunt.mp3": "목표를 빠르게 찾아보세요",
}

# 2. 피드백 (Feedback)
FEEDBACK = {
    "correct1.mp3": "잘했어요!",
    "correct2.mp3": "훌륭해요!",
    "correct3.mp3": "멋져요!",
    "correct4.mp3": "완벽해요!",
    "incorrect1.mp3": "다시 한번 해볼까요?",
    "incorrect2.mp3": "괜찮아요!",
    "encouragement1.mp3": "조금만 더!",
    "encouragement2.mp3": "거의 다 왔어요!",
}

def generate_with_google_tts(text: str, output_path: Path):
    """Google Cloud TTS로 생성"""
    client = texttospeech.TextToSpeechClient()
    
    synthesis_input = texttospeech.SynthesisInput(text=text)
    
    voice = texttospeech.VoiceSelectionParams(
        language_code="ko-KR",
        name="ko-KR-Wavenet-A",  # 여성 목소리
        ssml_gender=texttospeech.SsmlVoiceGender.FEMALE,
    )
    
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3,
        speaking_rate=0.85,  # 아동용으로 느리게
        pitch=2.0,  # 조금 높은 톤
    )
    
    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice,
        audio_config=audio_config,
    )
    
    with open(output_path, "wb") as out:
        out.write(response.audio_content)
    
    print(f"✅ {output_path.name}")

def generate_with_gtts(text: str, output_path: Path):
    """gTTS로 생성 (무료)"""
    tts = gTTS(text=text, lang='ko', slow=True)  # slow=True: 느리게
    tts.save(str(output_path))
    print(f"✅ {output_path.name}")

def main():
    """메인 실행 함수"""
    
    # 폴더 생성
    (AUDIO_DIR / "instructions").mkdir(parents=True, exist_ok=True)
    (AUDIO_DIR / "feedback").mkdir(parents=True, exist_ok=True)
    
    # 지시문 생성
    print("\n📝 지시문 생성 중...")
    for filename, text in INSTRUCTIONS.items():
        output_path = AUDIO_DIR / "instructions" / filename
        
        if USE_GOOGLE_TTS:
            generate_with_google_tts(text, output_path)
        elif USE_GTTS:
            generate_with_gtts(text, output_path)
        else:
            print(f"❌ TTS 라이브러리 없음: {filename}")
    
    # 피드백 생성
    print("\n🎉 피드백 생성 중...")
    for filename, text in FEEDBACK.items():
        output_path = AUDIO_DIR / "feedback" / filename
        
        if USE_GOOGLE_TTS:
            generate_with_google_tts(text, output_path)
        elif USE_GTTS:
            generate_with_gtts(text, output_path)
        else:
            print(f"❌ TTS 라이브러리 없음: {filename}")
    
    print(f"\n✅ 완료! 총 {len(INSTRUCTIONS) + len(FEEDBACK)}개 파일 생성")
    print(f"📁 위치: {AUDIO_DIR}")

if __name__ == "__main__":
    # 설치 안내
    if not USE_GOOGLE_TTS and not USE_GTTS:
        print("\n⚠️ TTS 라이브러리를 설치하세요:")
        print("  pip install gTTS  # 무료")
        print("  pip install google-cloud-texttospeech  # 고품질 (유료)")
        exit(1)
    
    main()
