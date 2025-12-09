import '../../../../core/state/app_state.dart';

/// 아동 프로필 저장소 인터페이스
/// 
/// 아동 프로필의 CRUD 작업을 정의합니다.
abstract class ChildRepository {
  /// 아동 프로필 목록 가져오기
  /// 
  /// [parentId] 부모 사용자 UID
  /// 
  /// 반환: 아동 프로필 목록
  Future<List<ChildModel>> getChildren(String parentId);

  /// 아동 프로필 가져오기
  /// 
  /// [childId] 아동 프로필 ID
  /// 
  /// 반환: 아동 프로필 (없으면 null)
  Future<ChildModel?> getChild(String childId);

  /// 아동 프로필 생성
  /// 
  /// [child] 생성할 아동 프로필 (id는 자동 생성)
  /// 
  /// 반환: 생성된 아동 프로필 (id 포함)
  Future<ChildModel> createChild(ChildModel child);

  /// 아동 프로필 수정
  /// 
  /// [child] 수정할 아동 프로필
  /// 
  /// 반환: 수정된 아동 프로필
  Future<ChildModel> updateChild(ChildModel child);

  /// 아동 프로필 삭제
  /// 
  /// [childId] 삭제할 아동 프로필 ID
  /// 
  /// 반환: 삭제 성공 여부
  Future<bool> deleteChild(String childId);
}

