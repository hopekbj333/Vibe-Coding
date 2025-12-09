import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/state/app_state.dart';

/// Firestore 사용자 모델 변환 유틸리티
/// 
/// UserModel과 Firestore 문서 간 변환을 처리합니다.
class UserModelFirestore {
  /// Firestore 문서를 UserModel로 변환
  static UserModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      role: _parseRole(data['role'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      childrenIds: (data['children'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// UserModel을 Firestore 문서 데이터로 변환
  static Map<String, dynamic> toFirestore(UserModel user) {
    return {
      'email': user.email,
      'displayName': user.displayName,
      'role': _roleToString(user.role),
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
      'children': user.childrenIds,
    };
  }

  /// 역할 문자열을 UserRole enum으로 변환
  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'parent':
        return UserRole.parent;
      case 'teacher':
        return UserRole.teacher;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.parent;
    }
  }

  /// UserRole enum을 문자열로 변환
  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return 'parent';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.admin:
        return 'admin';
    }
  }
}

