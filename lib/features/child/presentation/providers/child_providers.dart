import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/state/auth_providers.dart';
import '../../data/repositories/child_repository_impl.dart';
import '../../domain/repositories/child_repository.dart';
import '../../domain/services/child_service.dart';

/// ChildRepository Provider
/// 
/// ChildRepository 인스턴스를 제공합니다.
final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return ChildRepositoryImpl();
});

/// ChildService Provider
/// 
/// ChildService 인스턴스를 제공합니다.
final childServiceProvider = Provider<ChildService>((ref) {
  final repository = ref.watch(childRepositoryProvider);
  return ChildService(repository: repository);
});

/// 아동 프로필 목록 Provider
/// 
/// 현재 사용자의 아동 프로필 목록을 가져옵니다.
final childrenListProvider = FutureProvider<List<ChildModel>>((ref) async {
  final userModel = ref.watch(userModelProvider);
  final user = userModel.valueOrNull;
  
  if (user == null) {
    return [];
  }

  final childService = ref.watch(childServiceProvider);
  return await childService.getChildren(user.uid);
});

/// 아동 프로필 생성 Provider
/// 
/// 아동 프로필을 생성합니다.
final createChildProvider = FutureProvider.family<ChildModel, CreateChildParams>(
  (ref, params) async {
    final childService = ref.read(childServiceProvider);
    return await childService.createChild(
      parentId: params.parentId,
      name: params.name,
      birthDate: params.birthDate,
      gender: params.gender,
    );
  },
);

/// 아동 프로필 수정 Provider
/// 
/// 아동 프로필을 수정합니다.
final updateChildProvider = FutureProvider.family<ChildModel, UpdateChildParams>(
  (ref, params) async {
    final childService = ref.read(childServiceProvider);
    return await childService.updateChild(
      child: params.child,
      name: params.name,
      birthDate: params.birthDate,
      gender: params.gender,
    );
  },
);

/// 아동 프로필 삭제 Provider
/// 
/// 아동 프로필을 삭제합니다.
final deleteChildProvider = FutureProvider.family<bool, String>(
  (ref, childId) async {
    final childService = ref.read(childServiceProvider);
    return await childService.deleteChild(childId);
  },
);

/// 아동 프로필 생성 파라미터
class CreateChildParams {
  final String parentId;
  final String name;
  final DateTime birthDate;
  final String? gender;

  CreateChildParams({
    required this.parentId,
    required this.name,
    required this.birthDate,
    this.gender,
  });
}

/// 아동 프로필 수정 파라미터
class UpdateChildParams {
  final ChildModel child;
  final String? name;
  final DateTime? birthDate;
  final String? gender;

  UpdateChildParams({
    required this.child,
    this.name,
    this.birthDate,
    this.gender,
  });
}

