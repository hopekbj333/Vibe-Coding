// 전역 앱 상태 모델
// 
// 앱 전체에서 공유되는 상태를 정의합니다.

import 'package:cloud_firestore/cloud_firestore.dart';

/// 앱 모드 (부모 모드 / 아동 모드)
enum AppMode {
  /// 부모/관리자 모드
  /// - 아동 프로필 관리
  /// - 검사 결과 확인
  /// - 채점 작업
  parent,
  
  /// 아동 모드
  /// - 검사 실행
  /// - 학습 콘텐츠 이용
  child,
}

/// 인증 상태
enum AuthStatus {
  /// 초기 상태 (확인 중)
  initial,
  
  /// 인증되지 않음
  unauthenticated,
  
  /// 인증됨
  authenticated,
  
  /// 인증 실패
  error,
}

/// 사용자 역할
enum UserRole {
  /// 부모
  parent,
  
  /// 교사
  teacher,
  
  /// 관리자
  admin,
}

/// 사용자 정보 모델
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> childrenIds; // 연결된 아동 프로필 ID 목록

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.childrenIds = const [],
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? childrenIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }
}

/// 아동 프로필 모델
class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final DateTime birthDate;
  final String? gender; // 'male' | 'female' | null
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAssessmentDate;
  final int assessmentCount;

  ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
    this.lastAssessmentDate,
    this.assessmentCount = 0,
  });

  /// 나이 계산 (만 나이)
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  ChildModel copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? birthDate,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAssessmentDate,
    int? assessmentCount,
  }) {
    return ChildModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
      assessmentCount: assessmentCount ?? this.assessmentCount,
    );
  }

  /// Firestore 문서에서 생성
  /// 
  /// [map] Firestore 문서 데이터
  /// [id] 문서 ID (별도로 전달)
  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      parentId: map['parentId'] as String,
      name: map['name'] as String,
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      gender: map['gender'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      lastAssessmentDate: map['lastAssessmentDate'] != null
          ? (map['lastAssessmentDate'] as Timestamp).toDate()
          : null,
      assessmentCount: (map['assessmentCount'] as int?) ?? 0,
    );
  }

  /// Firestore 문서로 변환
  /// 
  /// Firestore Timestamp를 사용합니다.
  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastAssessmentDate': lastAssessmentDate != null
          ? Timestamp.fromDate(lastAssessmentDate!)
          : null,
      'assessmentCount': assessmentCount,
    };
  }
}

/// 검사 진행 상태
enum AssessmentStatus {
  /// 진행 중
  inProgress,
  
  /// 일시 정지
  paused,
  
  /// 완료
  completed,
  
  /// 취소됨
  cancelled,
}

/// 검사 진행 상태 모델
class AssessmentStateModel {
  final String? assessmentId;
  final String? childId;
  final AssessmentStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? pausedAt;
  final String? currentModule; // 현재 진행 중인 모듈
  final int? currentStep; // 현재 단계
  final Map<String, dynamic>? progressData; // 모듈별 진행 상태

  AssessmentStateModel({
    this.assessmentId,
    this.childId,
    this.status = AssessmentStatus.inProgress,
    this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.currentModule,
    this.currentStep,
    this.progressData,
  });

  /// 검사 진행 중 여부
  bool get isInProgress => status == AssessmentStatus.inProgress;

  /// 검사 완료 여부
  bool get isCompleted => status == AssessmentStatus.completed;

  /// 검사 일시 정지 여부
  bool get isPaused => status == AssessmentStatus.paused;

  AssessmentStateModel copyWith({
    String? assessmentId,
    String? childId,
    AssessmentStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    String? currentModule,
    int? currentStep,
    Map<String, dynamic>? progressData,
  }) {
    return AssessmentStateModel(
      assessmentId: assessmentId ?? this.assessmentId,
      childId: childId ?? this.childId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      currentModule: currentModule ?? this.currentModule,
      currentStep: currentStep ?? this.currentStep,
      progressData: progressData ?? this.progressData,
    );
  }
}

