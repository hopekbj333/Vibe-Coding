import 'package:freezed_annotation/freezed_annotation.dart';
import '../services/assessment_sampling_service.dart';
import 'dart:convert';

part 'assessment_session_model.freezed.dart';
part 'assessment_session_model.g.dart';

/// Assessment 세션 상태
enum AssessmentStatus {
  notStarted, // 시작 전
  inProgress, // 진행 중
  paused, // 일시 중지
  completed, // 완료
  abandoned, // 중도 포기
}

// Top-level functions for JSON serialization (freezed requires top-level functions)
List<Map<String, dynamic>> _assessmentQuestionsToJson(List<AssessmentQuestion> questions) =>
    questions.map((q) => q.toJson()).toList();

List<AssessmentQuestion> _assessmentQuestionsFromJson(List<dynamic> json) =>
    json.map((e) => AssessmentQuestion.fromJson(e as Map<String, dynamic>)).toList();

/// Assessment 세션 모델
@freezed
abstract class AssessmentSession with _$AssessmentSession {
  const AssessmentSession._();

  const factory AssessmentSession({
    required String sessionId, // 세션 고유 ID
    required String childId, // 아동 ID
    required DateTime startedAt, // 시작 시간
    DateTime? completedAt, // 완료 시간
    required AssessmentStatus status, // 세션 상태
    @JsonKey(toJson: _assessmentQuestionsToJson, fromJson: _assessmentQuestionsFromJson)
    required List<AssessmentQuestion> questions, // 전체 문항 (50개)
    required List<AssessmentAnswer> answers, // 답변 기록
    required int currentQuestionIndex, // 현재 문항 번호 (0-based)
    required int totalQuestions, // 전체 문항 수 (50)
  }) = _AssessmentSession;

  /// 진행률 (0.0 ~ 1.0)
  double get progress => currentQuestionIndex / totalQuestions;

  /// 정답 개수
  int get correctCount => answers.where((a) => a.isCorrect).length;

  /// 정답률
  double get accuracy => answers.isEmpty ? 0.0 : correctCount / answers.length;

  /// 평균 응답 시간 (밀리초)
  double get averageResponseTime {
    if (answers.isEmpty) return 0.0;
    final totalTime = answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);
    return totalTime / answers.length;
  }

  /// 분야별 정답률
  Map<String, double> get accuracyByType {
    final Map<String, List<bool>> typeResults = {};
    
    for (final answer in answers) {
      final question = questions[answer.questionIndex];
      final type = question.type.toString();
      typeResults[type] = [...(typeResults[type] ?? []), answer.isCorrect];
    }

    return typeResults.map((type, results) {
      final correctCount = results.where((r) => r).length;
      return MapEntry(type, correctCount / results.length);
    });
  }

  factory AssessmentSession.fromJson(Map<String, dynamic> json) =>
      _$AssessmentSessionFromJson(json);
}

/// Assessment 답변 모델
@freezed
abstract class AssessmentAnswer with _$AssessmentAnswer {
  const factory AssessmentAnswer({
    required int questionIndex, // 문항 번호 (0-based)
    required String questionId, // 문항 ID (itemId)
    required String userAnswer, // 사용자 답변
    required String correctAnswer, // 정답
    required bool isCorrect, // 정답 여부
    required int responseTimeMs, // 응답 시간 (밀리초)
    required DateTime answeredAt, // 답변 시간
    Map<String, dynamic>? metadata, // 추가 데이터 (예: 터치 좌표)
  }) = _AssessmentAnswer;

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) =>
      _$AssessmentAnswerFromJson(json);
}
