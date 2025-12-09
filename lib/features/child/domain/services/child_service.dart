import '../../../../core/state/app_state.dart';
import '../repositories/child_repository.dart';

/// 아동 프로필 서비스
/// 
/// 아동 프로필 관련 비즈니스 로직을 처리합니다.
class ChildService {
  final ChildRepository _repository;

  ChildService({required ChildRepository repository})
      : _repository = repository;

  /// 아동 프로필 목록 가져오기
  /// 
  /// [parentId] 부모 사용자 UID
  /// 
  /// 반환: 아동 프로필 목록
  Future<List<ChildModel>> getChildren(String parentId) async {
    return await _repository.getChildren(parentId);
  }

  /// 아동 프로필 가져오기
  /// 
  /// [childId] 아동 프로필 ID
  /// 
  /// 반환: 아동 프로필 (없으면 null)
  Future<ChildModel?> getChild(String childId) async {
    return await _repository.getChild(childId);
  }

  /// 아동 프로필 생성
  /// 
  /// [parentId] 부모 사용자 UID
  /// [name] 아동 이름
  /// [birthDate] 생년월일
  /// [gender] 성별 ('male' | 'female' | null)
  /// 
  /// 반환: 생성된 아동 프로필
  Future<ChildModel> createChild({
    required String parentId,
    required String name,
    required DateTime birthDate,
    String? gender,
  }) async {
    final now = DateTime.now();
    final child = ChildModel(
      id: '', // Repository에서 자동 생성
      parentId: parentId,
      name: name.trim(),
      birthDate: birthDate,
      gender: gender,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createChild(child);
  }

  /// 아동 프로필 수정
  /// 
  /// [child] 수정할 아동 프로필
  /// [name] 새 이름 (null이면 변경하지 않음)
  /// [birthDate] 새 생년월일 (null이면 변경하지 않음)
  /// [gender] 새 성별 (null이면 변경하지 않음)
  /// 
  /// 반환: 수정된 아동 프로필
  Future<ChildModel> updateChild({
    required ChildModel child,
    String? name,
    DateTime? birthDate,
    String? gender,
  }) async {
    final updatedChild = child.copyWith(
      name: name?.trim() ?? child.name,
      birthDate: birthDate ?? child.birthDate,
      gender: gender ?? child.gender,
    );

    return await _repository.updateChild(updatedChild);
  }

  /// 아동 프로필 삭제
  /// 
  /// [childId] 삭제할 아동 프로필 ID
  /// 
  /// 반환: 삭제 성공 여부
  Future<bool> deleteChild(String childId) async {
    return await _repository.deleteChild(childId);
  }
}

