import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/constants/asset_paths.dart';

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
      AppLogger.debug('캐시에서 시퀀스 반환', data: {
        'count': _cachedSequences!.length,
      });
      return _cachedSequences!;
    }

    try {
      AppLogger.debug('JSON 파일 로드 시작', data: {
        'path': AssetPaths.instructionSequences,
      });
      final jsonString = await rootBundle.loadString(
        AssetPaths.instructionSequences,
      );
      AppLogger.success('JSON 파일 로드 완료', data: {
        'length': jsonString.length,
      });
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      AppLogger.success('JSON 파싱 완료', data: {
        'keyCount': jsonData.length,
        'availableKeys': jsonData.keys.toList(),
      });
      
      final sequences = <String, QuestionInstructionSequence>{};
      
      for (final entry in jsonData.entries) {
        final questionNumber = entry.key;
        final sequenceJson = entry.value as Map<String, dynamic>;
        sequences[questionNumber] = QuestionInstructionSequence.fromJson(sequenceJson);
        AppLogger.debug('문항 시퀀스 로드', data: {
          'questionNumber': questionNumber,
          'stepCount': sequences[questionNumber]!.steps.length,
        });
      }
      
      // 캐시에 저장
      _cachedSequences = sequences;
      AppLogger.success('캐시에 저장 완료', data: {
        'count': sequences.length,
      });
      
      return sequences;
    } catch (e, stackTrace) {
      AppLogger.error(
        'JSON 파일 로드 실패',
        error: e,
        stackTrace: stackTrace,
        data: {'path': AssetPaths.instructionSequences},
      );
      throw Exception('Failed to load instruction_sequences.json: $e');
    }
  }

  /// 특정 문항 번호의 시퀀스 가져오기
  Future<QuestionInstructionSequence?> getSequenceForQuestion(int questionNumber) async {
    AppLogger.debug('문항의 시퀀스 찾기 시작', data: {
      'questionNumber': questionNumber,
    });
    final sequences = await loadSequences();
    final key = questionNumber.toString();
    
    final sequence = sequences[key];
    if (sequence != null) {
      AppLogger.success('문항의 시퀀스 찾음', data: {
        'questionNumber': questionNumber,
        'stepCount': sequence.steps.length,
      });
    } else {
      AppLogger.warning('문항의 시퀀스를 찾을 수 없음', data: {
        'questionNumber': questionNumber,
        'key': key,
        'availableKeys': sequences.keys.toList(),
      });
    }
    return sequence;
  }

  /// 캐시 초기화 (테스트용)
  static void clearCache() {
    _cachedSequences = null;
  }
}
