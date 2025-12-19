import 'package:freezed_annotation/freezed_annotation.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

enum QuestionType {
  choice, // 선택형 (O/X, N지선다)
  ordering, // 순서 배열
  recording, // 녹음 (따라 말하기)
  soundIdentification, // 소리 식별 (S 1.4.1)
  rhythmTap, // 리듬 따라하기 (S 1.4.2)
  intonation, // 억양/강세 식별 (S 1.4.3)
  wordBoundary, // 단어 경계 인식 (S 1.4.4)
  rhyme, // 각운/두운 찾기 (S 1.4.5)
  syllableBlending, // 음절 합성 (S 1.4.6)
  syllableDeletion, // 음절 탈락 (S 1.4.7)
  syllableReverse, // 음절 뒤집기 (S 1.4.8) - 음성 녹음
  phonemeInitial, // 초성 분리 (S 1.4.9) - 음성 녹음
  phonemeBlending, // 음소 합성/분할 (S 1.4.10)
  phonemeSubstitution, // 음소 대치/추가 (S 1.4.11) - 음성 녹음
  nonwordRepeat, // 비단어 따라말하기 (S 1.4.12) - 음성 녹음
  memorySpan, // 숫자/단어 폭 기억 (S 1.4.13) - 음성 녹음
  
  // WP 1.5: 감각 처리 (Sensory Processing)
  // 청각 및 순차 처리 능력
  soundSequence, // 소리 순서 기억하기 (S 1.5.1)
  animalSoundSequence, // 동물 소리 순서 맞추기 (S 1.5.2)
  positionSequence, // 위치 순서 기억하기 (S 1.5.3) - Simon Says
  // 시각적 처리 능력
  findDifferent, // 다른 그림 찾기 (S 1.5.4)
  findSameShape, // 같은 형태 찾기 (S 1.5.5)
  findDifferentDirection, // 방향이 다른 글자 찾기 (S 1.5.6)
  hiddenPicture, // 숨은 그림 찾기 (S 1.5.7)
  
  // WP 1.6: 인지 제어 (Executive Functions)
  // 작업 기억 능력
  digitSpanForward, // 숫자 따라 말하기 순방향 (S 1.6.1) - 녹음
  digitSpanBackward, // 숫자 거꾸로 말하기 역방향 (S 1.6.2) - 녹음
  wordSpanForward, // 단어 따라 말하기 (S 1.6.3) - 녹음
  wordSpanBackward, // 단어 거꾸로 말하기 (S 1.6.4) - 녹음
  // 주의 집중 능력
  goNoGo, // Go/No-Go 기본 (S 1.6.5)
  goNoGoAuditory, // Go/No-Go 청각 버전 (S 1.6.6)
  continuousPerformance, // 지속적 주의력 (S 1.6.7)
}

@freezed
abstract class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required QuestionType type,
    required String promptText, // 질문 텍스트 (성우 대본용)
    required String promptAudioUrl, // 질문 오디오 URL
    @Default([]) List<String> optionsImageUrl, // 보기 이미지 URL 목록
    @Default([]) List<String> optionsText, // 보기 텍스트 (접근성용)
    required dynamic correctAnswer, // 정답 (인덱스 or 텍스트)
    @Default(10) int timeLimitSeconds, // 제한 시간
    // S 1.4.1: 소리 식별용 추가 필드
    @Default([]) List<String> soundUrls, // 재생할 소리 URL 목록
    @Default([]) List<String> soundLabels, // 소리 라벨 (예: "북소리", "피아노 소리")
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

/// 사용자 답변 데이터 (S 1.3.4)
/// 
/// 사용자가 입력한 답변과 관련 메타데이터를 저장합니다.
@freezed
abstract class AnswerData with _$AnswerData {
  const factory AnswerData({
    required String questionId,
    required dynamic selectedAnswer, // 선택한 인덱스 또는 텍스트
    required int reactionTimeMs, // 반응 시간 (밀리초)
    required DateTime answeredAt, // 답변 시각
    String? recordingPath, // 녹음 파일 경로 (recording 타입일 때)
  }) = _AnswerData;

  factory AnswerData.fromJson(Map<String, dynamic> json) =>
      _$AnswerDataFromJson(json);
}
