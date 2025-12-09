import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../../presentation/providers/assessment_providers.dart';

/// 검사 결과 제출 서비스 (S 1.3.10)
/// 
/// 검사 완료 후 답안 데이터를 Firestore로 전송합니다.
/// 오프라인 시 로컬에 저장하고 나중에 재시도합니다.
class AssessmentSubmissionService {
  static const String _pendingKey = 'pending_submissions';
  
  /// 검사 결과 제출
  static Future<SubmissionResult> submitAssessmentResult({
    required String childId,
    required String assessmentId,
    required AssessmentMode mode,
    required List<AnswerData> answers,
    required int tutorialCorrectCount,
    required int totalQuestions,
  }) async {
    final result = AssessmentResult(
      childId: childId,
      assessmentId: assessmentId,
      mode: mode,
      answers: answers,
      tutorialCorrectCount: tutorialCorrectCount,
      totalQuestions: totalQuestions,
      completedAt: DateTime.now(),
    );
    
    try {
      // Firestore에 저장 시도
      await _submitToFirestore(result);
      return SubmissionResult.success;
    } catch (e) {
      // 실패 시 로컬에 저장 (나중에 재시도)
      await _savePendingSubmission(result);
      return SubmissionResult.pending;
    }
  }
  
  /// Firestore에 결과 저장
  static Future<void> _submitToFirestore(AssessmentResult result) async {
    final firestore = FirebaseFirestore.instance;
    
    // 검사 결과 문서 생성
    final docRef = firestore
        .collection('children')
        .doc(result.childId)
        .collection('assessment_results')
        .doc();
    
    await docRef.set({
      'assessmentId': result.assessmentId,
      'mode': result.mode.name,
      'answers': result.answers.map((a) => a.toJson()).toList(),
      'tutorialCorrectCount': result.tutorialCorrectCount,
      'totalQuestions': result.totalQuestions,
      'completedAt': Timestamp.fromDate(result.completedAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// 대기 중인 제출 저장 (오프라인용)
  static Future<void> _savePendingSubmission(AssessmentResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 기존 대기 목록 불러오기
    final pendingJson = prefs.getString(_pendingKey);
    List<Map<String, dynamic>> pendingList = [];
    
    if (pendingJson != null) {
      pendingList = (jsonDecode(pendingJson) as List)
          .cast<Map<String, dynamic>>();
    }
    
    // 새 항목 추가
    pendingList.add(result.toJson());
    
    // 저장
    await prefs.setString(_pendingKey, jsonEncode(pendingList));
  }
  
  /// 대기 중인 제출 재시도
  static Future<int> retryPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingKey);
    
    if (pendingJson == null) return 0;
    
    List<Map<String, dynamic>> pendingList = (jsonDecode(pendingJson) as List)
        .cast<Map<String, dynamic>>();
    
    if (pendingList.isEmpty) return 0;
    
    List<Map<String, dynamic>> stillPending = [];
    int successCount = 0;
    
    for (final item in pendingList) {
      try {
        final result = AssessmentResult.fromJson(item);
        await _submitToFirestore(result);
        successCount++;
      } catch (e) {
        // 여전히 실패하면 대기 목록에 유지
        stillPending.add(item);
      }
    }
    
    // 대기 목록 업데이트
    if (stillPending.isEmpty) {
      await prefs.remove(_pendingKey);
    } else {
      await prefs.setString(_pendingKey, jsonEncode(stillPending));
    }
    
    return successCount;
  }
  
  /// 대기 중인 제출 개수 확인
  static Future<int> getPendingCount() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingKey);
    
    if (pendingJson == null) return 0;
    
    final pendingList = jsonDecode(pendingJson) as List;
    return pendingList.length;
  }
}

/// 제출 결과
enum SubmissionResult {
  success, // 성공
  pending, // 대기 중 (오프라인)
  error,   // 오류
}

/// 검사 결과 데이터
class AssessmentResult {
  final String childId;
  final String assessmentId;
  final AssessmentMode mode;
  final List<AnswerData> answers;
  final int tutorialCorrectCount;
  final int totalQuestions;
  final DateTime completedAt;
  
  const AssessmentResult({
    required this.childId,
    required this.assessmentId,
    required this.mode,
    required this.answers,
    required this.tutorialCorrectCount,
    required this.totalQuestions,
    required this.completedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'assessmentId': assessmentId,
      'mode': mode.name,
      'answers': answers.map((a) => a.toJson()).toList(),
      'tutorialCorrectCount': tutorialCorrectCount,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
    };
  }
  
  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      childId: json['childId'] as String,
      assessmentId: json['assessmentId'] as String,
      mode: AssessmentMode.values.byName(json['mode'] as String),
      answers: (json['answers'] as List).map((e) => AnswerData(
        questionId: e['questionId'] as String,
        selectedAnswer: e['selectedAnswer'],
        reactionTimeMs: e['reactionTimeMs'] as int,
        answeredAt: DateTime.parse(e['answeredAt'] as String),
        recordingPath: e['recordingPath'] as String?,
      )).toList(),
      tutorialCorrectCount: json['tutorialCorrectCount'] as int,
      totalQuestions: json['totalQuestions'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

