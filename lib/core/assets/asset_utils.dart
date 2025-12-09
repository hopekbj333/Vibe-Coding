/// 에셋 경로 유틸리티
/// 
/// 에셋 경로를 일관되게 생성하고 관리합니다.
class AssetUtils {
  AssetUtils._();

  /// 이미지 에셋 경로 생성
  /// 
  /// [fileName] 파일 이름 (예: 'apple.png')
  /// 
  /// 반환: 전체 경로 (예: 'assets/images/apple.png')
  static String imagePath(String fileName) {
    return 'assets/images/$fileName';
  }

  /// 오디오 에셋 경로 생성
  /// 
  /// [fileName] 파일 이름 (예: 'question_1.mp3')
  /// 
  /// 반환: 전체 경로 (예: 'assets/audio/question_1.mp3')
  static String audioPath(String fileName) {
    return 'assets/audio/$fileName';
  }

  /// 캐릭터 이미지 경로 생성
  /// 
  /// [fileName] 파일 이름 (예: 'character_idle.png')
  /// 
  /// 반환: 전체 경로 (예: 'assets/characters/character_idle.png')
  static String characterPath(String fileName) {
    return 'assets/characters/$fileName';
  }

  /// 검사 모듈별 에셋 경로 생성
  /// 
  /// [module] 모듈 이름 (예: 'phonological', 'sensory')
  /// [type] 에셋 타입 ('images' 또는 'audio')
  /// [fileName] 파일 이름
  /// 
  /// 반환: 전체 경로 (예: 'assets/images/phonological/question_1.png')
  static String moduleAssetPath({
    required String module,
    required String type, // 'images' or 'audio'
    required String fileName,
  }) {
    return 'assets/$type/$module/$fileName';
  }

  /// 검사 세트 에셋 목록 생성
  /// 
  /// 특정 검사 모듈에 필요한 모든 에셋 경로를 생성합니다.
  /// 
  /// [module] 모듈 이름
  /// [imageFiles] 이미지 파일 목록
  /// [audioFiles] 오디오 파일 목록
  /// 
  /// 반환: 에셋 경로 목록
  static List<String> createAssetList({
    required String module,
    List<String>? imageFiles,
    List<String>? audioFiles,
  }) {
    final assets = <String>[];

    if (imageFiles != null) {
      for (final file in imageFiles) {
        assets.add(moduleAssetPath(
          module: module,
          type: 'images',
          fileName: file,
        ));
      }
    }

    if (audioFiles != null) {
      for (final file in audioFiles) {
        assets.add(moduleAssetPath(
          module: module,
          type: 'audio',
          fileName: file,
        ));
      }
    }

    return assets;
  }
}

