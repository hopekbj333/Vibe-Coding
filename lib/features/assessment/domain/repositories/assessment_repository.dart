import '../../data/models/assessment_model.dart';

abstract class AssessmentRepository {
  /// 검사 데이터를 가져옵니다.
  /// 
  /// [id]는 검사 세트 ID입니다.
  Future<AssessmentModel> getAssessment(String id);
}

