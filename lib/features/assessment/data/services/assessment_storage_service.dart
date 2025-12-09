import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../../presentation/providers/assessment_providers.dart';

/// 검사 진행 상태 로컬 저장 서비스 (S 1.3.8)
/// 
/// 앱 강제 종료나 이탈 시 현재 진행 상태를 저장하고,
/// 다시 진입 시 복원할 수 있도록 합니다.
class AssessmentStorageService {
  static const String _keyPrefix = 'assessment_progress_';
  static const String _keyChildId = 'child_id';
  static const String _keyAssessmentId = 'assessment_id';
  static const String _keyCurrentIndex = 'current_index';
  static const String _keyMode = 'mode';
  static const String _keyAnswers = 'answers';
  static const String _keyTutorialCorrectCount = 'tutorial_correct_count';
  static const String _keyTimestamp = 'timestamp';

  /// 진행 상태 저장
  static Future<void> saveProgress({
    required String childId,
    required String assessmentId,
    required int currentQuestionIndex,
    required AssessmentMode mode,
    required List<AnswerData> answers,
    required int tutorialCorrectCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$childId';
    
    final data = {
      _keyChildId: childId,
      _keyAssessmentId: assessmentId,
      _keyCurrentIndex: currentQuestionIndex,
      _keyMode: mode.name,
      _keyAnswers: answers.map((a) => a.toJson()).toList(),
      _keyTutorialCorrectCount: tutorialCorrectCount,
      _keyTimestamp: DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(key, jsonEncode(data));
  }

  /// 저장된 진행 상태 불러오기
  static Future<SavedProgress?> loadProgress(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$childId';
    
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 24시간 이상 지난 데이터는 무효
      final timestamp = DateTime.parse(data[_keyTimestamp] as String);
      if (DateTime.now().difference(timestamp).inHours > 24) {
        await clearProgress(childId);
        return null;
      }
      
      return SavedProgress(
        childId: data[_keyChildId] as String,
        assessmentId: data[_keyAssessmentId] as String,
        currentQuestionIndex: data[_keyCurrentIndex] as int,
        mode: AssessmentMode.values.byName(data[_keyMode] as String),
        answers: (data[_keyAnswers] as List)
            .map((e) => AnswerData(
                  questionId: e['questionId'] as String,
                  selectedAnswer: e['selectedAnswer'],
                  reactionTimeMs: e['reactionTimeMs'] as int,
                  answeredAt: DateTime.parse(e['answeredAt'] as String),
                  recordingPath: e['recordingPath'] as String?,
                ))
            .toList(),
        tutorialCorrectCount: data[_keyTutorialCorrectCount] as int,
        savedAt: timestamp,
      );
    } catch (e) {
      // 파싱 실패 시 삭제
      await clearProgress(childId);
      return null;
    }
  }

  /// 저장된 진행 상태 삭제
  static Future<void> clearProgress(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$childId';
    await prefs.remove(key);
  }

  /// 저장된 진행 상태가 있는지 확인
  static Future<bool> hasProgress(String childId) async {
    final progress = await loadProgress(childId);
    return progress != null;
  }
}

/// 저장된 진행 상태 데이터
class SavedProgress {
  final String childId;
  final String assessmentId;
  final int currentQuestionIndex;
  final AssessmentMode mode;
  final List<AnswerData> answers;
  final int tutorialCorrectCount;
  final DateTime savedAt;

  const SavedProgress({
    required this.childId,
    required this.assessmentId,
    required this.currentQuestionIndex,
    required this.mode,
    required this.answers,
    required this.tutorialCorrectCount,
    required this.savedAt,
  });
}

