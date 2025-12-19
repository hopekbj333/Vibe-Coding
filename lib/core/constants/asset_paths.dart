/// 에셋 경로 상수
/// 
/// 모든 에셋 경로를 중앙에서 관리하여
/// 경로 변경 시 한 곳만 수정하면 되도록 함
class AssetPaths {
  AssetPaths._();

  /// 오디오 에셋 기본 경로
  static const String audioBase = 'assets/audio/';

  /// 환경음 오디오 경로
  static const String audioEnvironment = '${audioBase}environment/';

  /// 음높이 오디오 경로
  static const String audioPitch = '${audioBase}pitch/';

  /// 문항 시퀀스 JSON 경로
  static const String instructionSequences = 'assets/questions/story/instruction_sequences.json';

  /// 능력 매핑 JSON 경로 (향후 사용)
  static const String abilityMappings = 'assets/config/ability_mappings.json';

  /// 오디오 경로에서 'assets/' 접두사 제거
  /// AssetSource는 'assets/' 접두사 없이 경로를 받음
  static String removeAssetsPrefix(String path) {
    if (path.startsWith('assets/')) {
      return path.substring(7); // 'assets/'.length = 7
    }
    return path;
  }

  /// 오디오 경로에 'assets/' 접두사 추가
  static String addAssetsPrefix(String path) {
    if (path.startsWith('assets/')) {
      return path;
    }
    return 'assets/$path';
  }
}
