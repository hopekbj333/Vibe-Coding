/// 캐시된 콘텐츠 모델
class CachedContentModel {
  final String id;
  final String type; // 'game', 'audio', 'image'
  final String path;
  final int size; // bytes
  final DateTime cachedAt;
  final DateTime lastUsed;
  final int useCount;

  CachedContentModel({
    required this.id,
    required this.type,
    required this.path,
    required this.size,
    required this.cachedAt,
    required this.lastUsed,
    this.useCount = 0,
  });

  CachedContentModel copyWith({
    String? id,
    String? type,
    String? path,
    int? size,
    DateTime? cachedAt,
    DateTime? lastUsed,
    int? useCount,
  }) {
    return CachedContentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      path: path ?? this.path,
      size: size ?? this.size,
      cachedAt: cachedAt ?? this.cachedAt,
      lastUsed: lastUsed ?? this.lastUsed,
      useCount: useCount ?? this.useCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'path': path,
        'size': size,
        'cachedAt': cachedAt.toIso8601String(),
        'lastUsed': lastUsed.toIso8601String(),
        'useCount': useCount,
      };

  factory CachedContentModel.fromJson(Map<String, dynamic> json) =>
      CachedContentModel(
        id: json['id'],
        type: json['type'],
        path: json['path'],
        size: json['size'],
        cachedAt: DateTime.parse(json['cachedAt']),
        lastUsed: DateTime.parse(json['lastUsed']),
        useCount: json['useCount'] ?? 0,
      );
}

/// 오프라인 학습 기록
class OfflineLearningRecord {
  final String id;
  final String childId;
  final String moduleId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isSynced;

  OfflineLearningRecord({
    required this.id,
    required this.childId,
    required this.moduleId,
    required this.data,
    required this.createdAt,
    this.isSynced = false,
  });

  // Hive adapter를 수동으로 등록하는 대신 간소화된 저장소 사용
  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'moduleId': moduleId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
      };

  factory OfflineLearningRecord.fromJson(Map<String, dynamic> json) =>
      OfflineLearningRecord(
        id: json['id'],
        childId: json['childId'],
        moduleId: json['moduleId'],
        data: json['data'],
        createdAt: DateTime.parse(json['createdAt']),
        isSynced: json['isSynced'] ?? false,
      );
}

