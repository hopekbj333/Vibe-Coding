import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// 에셋 로딩 상태
enum AssetLoadingState {
  idle,
  loading,
  loaded,
  error,
}

/// 게임 에셋 로더 서비스
/// 
/// 게임에 사용되는 이미지, 오디오 등의 에셋을 효율적으로 로딩하고 관리합니다.
/// Milestone 2 - WP 2.1 (S 2.1.2)
class AssetLoaderService {
  /// 싱글톤 인스턴스
  static final AssetLoaderService _instance = AssetLoaderService._internal();
  factory AssetLoaderService() => _instance;
  AssetLoaderService._internal();

  /// 로딩 상태
  AssetLoadingState _state = AssetLoadingState.idle;
  AssetLoadingState get state => _state;

  /// 로딩 진행률 (0.0 ~ 1.0)
  double _progress = 0.0;
  double get progress => _progress;

  /// 에러 메시지
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 캐시된 이미지들
  final Map<String, ImageProvider> _imageCache = {};

  /// 캐시된 오디오 파일들 (미리 로드)
  final Set<String> _preloadedAudio = {};

  /// 기본 게임 에셋 로드
  /// 
  /// 앱 시작 시 또는 Training 화면 진입 시 호출합니다.
  Future<void> loadGameAssets() async {
    if (_state == AssetLoadingState.loading ||
        _state == AssetLoadingState.loaded) {
      return; // 이미 로딩 중이거나 완료됨
    }

    _state = AssetLoadingState.loading;
    _progress = 0.0;
    _errorMessage = null;

    try {
      // 1. 기본 이미지 로드
      await _loadImages();
      _progress = 0.5;

      // 2. 기본 오디오 파일 프리로드
      await _loadAudio();
      _progress = 1.0;

      _state = AssetLoadingState.loaded;
    } catch (e) {
      _state = AssetLoadingState.error;
      _errorMessage = e.toString();
      rethrow;
    }
  }

  /// 이미지 로드
  Future<void> _loadImages() async {
    // 기본 캐릭터/UI 이미지들
    final imageAssets = [
      'assets/characters/character_happy.png',
      'assets/characters/character_neutral.png',
      'assets/characters/character_thinking.png',
      'assets/images/star.png',
      'assets/images/checkmark.png',
      'assets/images/retry.png',
    ];

    for (final path in imageAssets) {
      try {
        // 이미지 존재 여부 확인
        await rootBundle.load(path);
        // 캐시에 추가
        _imageCache[path] = AssetImage(path);
      } catch (e) {
        // 이미지 없어도 계속 진행 (선택적 에셋)
        debugPrint('⚠️ 이미지 로드 실패 (선택사항): $path');
      }
    }
  }

  /// 오디오 파일 프리로드
  Future<void> _loadAudio() async {
    // 기본 효과음들
    final audioAssets = [
      'audio/correct.mp3',
      'audio/incorrect.mp3',
      'audio/button_click.mp3',
      'audio/level_up.mp3',
      'audio/encouragement.mp3',
    ];

    for (final path in audioAssets) {
      try {
        // Flame Audio로 프리로드
        await FlameAudio.audioCache.load(path);
        _preloadedAudio.add(path);
      } catch (e) {
        // 오디오 없어도 계속 진행
        debugPrint('⚠️ 오디오 로드 실패 (선택사항): $path');
      }
    }
  }

  /// 특정 모듈의 에셋 로드 (지연 로딩)
  /// 
  /// 게임 시작 전에 해당 모듈의 에셋만 로드합니다.
  Future<void> loadModuleAssets(String moduleId) async {
    debugPrint('📦 모듈 에셋 로드: $moduleId');

    // 모듈별 에셋 경로
    final modulePath = 'assets/games/$moduleId/';

    try {
      // 모듈별 이미지 로드 (예시)
      // 실제로는 모듈 설정 파일에서 읽어옴
      final moduleImages = await _getModuleImagePaths(moduleId);
      for (final imagePath in moduleImages) {
        if (!_imageCache.containsKey(imagePath)) {
          try {
            await rootBundle.load(imagePath);
            _imageCache[imagePath] = AssetImage(imagePath);
          } catch (e) {
            debugPrint('⚠️ 모듈 이미지 로드 실패: $imagePath');
          }
        }
      }

      // 모듈별 오디오 로드
      final moduleAudio = await _getModuleAudioPaths(moduleId);
      for (final audioPath in moduleAudio) {
        if (!_preloadedAudio.contains(audioPath)) {
          try {
            await FlameAudio.audioCache.load(audioPath);
            _preloadedAudio.add(audioPath);
          } catch (e) {
            debugPrint('⚠️ 모듈 오디오 로드 실패: $audioPath');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ 모듈 에셋 로드 오류: $e');
    }
  }

  /// 모듈별 이미지 경로 가져오기 (예시)
  Future<List<String>> _getModuleImagePaths(String moduleId) async {
    // 실제로는 설정 파일이나 서버에서 가져옴
    // 현재는 하드코딩
    switch (moduleId) {
      case 'phonological_basic':
        return [
          'assets/games/$moduleId/cat.png',
          'assets/games/$moduleId/dog.png',
          'assets/games/$moduleId/bird.png',
        ];
      case 'sensory_basic':
        return [
          'assets/games/$moduleId/drum.png',
          'assets/games/$moduleId/piano.png',
          'assets/games/$moduleId/guitar.png',
        ];
      default:
        return [];
    }
  }

  /// 모듈별 오디오 경로 가져오기 (예시)
  Future<List<String>> _getModuleAudioPaths(String moduleId) async {
    // 실제로는 설정 파일이나 서버에서 가져옴
    switch (moduleId) {
      case 'phonological_basic':
        return [
          'audio/modules/$moduleId/sound1.mp3',
          'audio/modules/$moduleId/sound2.mp3',
        ];
      case 'sensory_basic':
        return [
          'audio/modules/$moduleId/drum.mp3',
          'audio/modules/$moduleId/piano.mp3',
        ];
      default:
        return [];
    }
  }

  /// 이미지 가져오기
  ImageProvider? getImage(String path) {
    return _imageCache[path];
  }

  /// 오디오 재생
  Future<void> playSound(String path) async {
    try {
      if (_preloadedAudio.contains(path)) {
        await FlameAudio.play(path);
      } else {
        // 프리로드되지 않은 경우 즉시 로드 후 재생
        await FlameAudio.play(path);
      }
    } catch (e) {
      debugPrint('❌ 오디오 재생 실패: $path - $e');
    }
  }

  /// 오디오 볼륨 조절
  void setVolume(double volume) {
    FlameAudio.bgm.audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// 배경음악 재생
  Future<void> playBackgroundMusic(String path, {double volume = 0.3}) async {
    try {
      await FlameAudio.bgm.play(path, volume: volume);
    } catch (e) {
      debugPrint('❌ 배경음악 재생 실패: $path - $e');
    }
  }

  /// 배경음악 정지
  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  /// 배경음악 일시정지
  void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  /// 배경음악 재개
  void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }

  /// 메모리 정리
  void dispose() {
    FlameAudio.bgm.dispose();
    _imageCache.clear();
    _preloadedAudio.clear();
    _state = AssetLoadingState.idle;
    _progress = 0.0;
  }

  /// 특정 모듈 에셋 언로드 (메모리 절약)
  void unloadModuleAssets(String moduleId) {
    // 모듈 에셋 제거
    _imageCache.removeWhere((key, value) => key.contains(moduleId));
    _preloadedAudio.removeWhere((path) => path.contains(moduleId));
    debugPrint('🗑️ 모듈 에셋 언로드: $moduleId');
  }

  /// 캐시 상태 확인
  Map<String, dynamic> getCacheStatus() {
    return {
      'state': _state.name,
      'progress': _progress,
      'cachedImages': _imageCache.length,
      'preloadedAudio': _preloadedAudio.length,
      'errorMessage': _errorMessage,
    };
  }
}

