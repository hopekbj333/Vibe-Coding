import 'dart:convert';
import 'package:flutter/services.dart';

/// 안내 시퀀스 스텝 모델
class InstructionStep {
  final String action;
  final Map<String, dynamic> params;

  InstructionStep({
    required this.action,
    required this.params,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    final action = json['action'] as String;
    final params = Map<String, dynamic>.from(json);
    params.remove('action');
    
    return InstructionStep(
      action: action,
      params: params,
    );
  }
}

/// 문항별 안내 시퀀스 모델
class QuestionInstructionSequence {
  final List<InstructionStep> steps;

  QuestionInstructionSequence({
    required this.steps,
  });

  factory QuestionInstructionSequence.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List;
    final steps = stepsJson
        .map((step) => InstructionStep.fromJson(step as Map<String, dynamic>))
        .toList();
    
    return QuestionInstructionSequence(steps: steps);
  }
}

/// 안내 시퀀스 JSON 로더 서비스
class InstructionSequenceLoaderService {
  static Map<String, QuestionInstructionSequence>? _cachedSequences;

  /// instruction_sequences.json 파일 로드
  Future<Map<String, QuestionInstructionSequence>> loadSequences() async {
    // 캐시가 있으면 반환
    if (_cachedSequences != null) {
      print('📦 [로더] 캐시에서 시퀀스 반환 (${_cachedSequences!.length}개)');
      return _cachedSequences!;
    }

    try {
      print('📂 [로더] JSON 파일 로드 시작: assets/questions/story/instruction_sequences.json');
      final jsonString = await rootBundle.loadString(
        'assets/questions/story/instruction_sequences.json',
      );
      print('✅ [로더] JSON 파일 로드 완료 (길이: ${jsonString.length}자)');
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      print('✅ [로더] JSON 파싱 완료 (키 개수: ${jsonData.length})');
      print('  - 사용 가능한 키: ${jsonData.keys.toList()}');
      
      final sequences = <String, QuestionInstructionSequence>{};
      
      for (final entry in jsonData.entries) {
        final questionNumber = entry.key;
        final sequenceJson = entry.value as Map<String, dynamic>;
        sequences[questionNumber] = QuestionInstructionSequence.fromJson(sequenceJson);
        print('  - 문항 $questionNumber: ${sequences[questionNumber]!.steps.length}개 step');
      }
      
      // 캐시에 저장
      _cachedSequences = sequences;
      print('✅ [로더] 캐시에 저장 완료 (${sequences.length}개 문항)');
      
      return sequences;
    } catch (e, stackTrace) {
      print('❌ [로더] JSON 파일 로드 실패: $e');
      print('스택: $stackTrace');
      throw Exception('Failed to load instruction_sequences.json: $e');
    }
  }

  /// 특정 문항 번호의 시퀀스 가져오기
  Future<QuestionInstructionSequence?> getSequenceForQuestion(int questionNumber) async {
    print('🔍 [로더] 문항 $questionNumber의 시퀀스 찾기 시작');
    final sequences = await loadSequences();
    final key = questionNumber.toString();
    print('  - 찾는 키: "$key"');
    print('  - 사용 가능한 키: ${sequences.keys.toList()}');
    
    final sequence = sequences[key];
    if (sequence != null) {
      print('✅ [로더] 문항 $questionNumber의 시퀀스 찾음 (${sequence.steps.length}개 step)');
    } else {
      print('❌ [로더] 문항 $questionNumber의 시퀀스를 찾을 수 없음');
    }
    return sequence;
  }

  /// 캐시 초기화 (테스트용)
  static void clearCache() {
    _cachedSequences = null;
  }
}
