import 'package:audioplayers/audioplayers.dart';
import '../constants/audio_constants.dart';
import '../constants/asset_paths.dart';
import '../utils/logger.dart';
import 'package:flutter/services.dart';

/// 오디오 재생 서비스
/// 
/// 오디오 파일 재생의 공통 로직을 제공하여
/// 코드 중복을 줄이고 일관된 재생 경험을 제공합니다.
class AudioPlaybackService {
  final AudioPlayer _audioPlayer;
  bool _isInitialized = false;

  AudioPlaybackService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  /// 오디오 파일 재생
  /// 
  /// [audioPath]: 재생할 오디오 파일 경로 (assets/ 접두사 포함 또는 제외 가능)
  /// [onStateChanged]: 재생 상태 변경 콜백 (선택사항)
  /// 
  /// 반환: 재생 완료까지 대기
  Future<void> playAsset(
    String audioPath, {
    void Function(bool isPlaying)? onStateChanged,
  }) async {
    if (audioPath.isEmpty) {
      AppLogger.warning('오디오 경로가 비어있습니다');
      throw Exception('오디오 경로가 비어있습니다');
    }

    // 파일 존재 여부 확인 (Web에서는 체크가 불완전할 수 있으므로 항상 재생 시도)
    final fileExists = await _checkAudioFileExists(audioPath);
    if (!fileExists) {
      AppLogger.warning('오디오 파일 존재 확인 실패했지만 재생 시도', data: {
        'audioPath': audioPath,
      });
    } else {
      AppLogger.success('오디오 파일 존재 확인 성공', data: {'audioPath': audioPath});
    }

    // 이전 오디오 정리 (중복 재생 방지)
    await _audioPlayer.stop();

    // 볼륨 통일 설정
    await _audioPlayer.setVolume(AudioConstants.defaultVolume);

    if (onStateChanged != null) {
      onStateChanged(true);
    }

    try {
      // AssetSource는 'assets/' 접두사를 제외하고 경로를 받습니다
      final assetSourcePath = AssetPaths.removeAssetsPrefix(audioPath);
      if (assetSourcePath != audioPath) {
        AppLogger.debug('오디오 경로 변환', data: {
          'original': audioPath,
          'converted': assetSourcePath,
        });
      }
      final assetSource = AssetSource(assetSourcePath);

      AppLogger.audio('AssetSource 생성', data: {
        'original': audioPath,
        'converted': assetSourcePath,
      });

      // play() 호출
      AppLogger.audio('오디오 재생 시작', data: {
        'audioPath': audioPath,
        'assetSource': assetSourcePath,
      });
      await _audioPlayer.play(assetSource);

      AppLogger.audio('오디오 재생 중', data: {'audioPath': audioPath});

      // 재생 완료 이벤트 대기
      try {
        await _audioPlayer.onPlayerComplete.first.timeout(
          AudioConstants.audioTimeout,
        );
        AppLogger.success('오디오 재생 완료 이벤트 수신');
      } on TimeoutException {
        AppLogger.warning('오디오 재생 완료 이벤트 타임아웃 - 재생 상태 확인', data: {
          'audioPath': audioPath,
        });

        // 타임아웃 발생 시 재생 상태 확인
        try {
          final state = _audioPlayer.state;
          AppLogger.debug('현재 재생 상태 확인', data: {'state': state.toString()});
          // 재생 중이면 완료될 때까지 추가 대기
          if (state == PlayerState.playing) {
            AppLogger.debug('재생 중이므로 완료될 때까지 추가 대기');
            await _audioPlayer.onPlayerComplete.first.timeout(
              AudioConstants.audioAdditionalWait,
            );
            AppLogger.success('추가 대기 후 오디오 재생 완료');
          }
        } catch (e, stackTrace) {
          AppLogger.warning('재생 상태 확인 중 오류', data: {'error': e.toString()});
        }
      } catch (e, stackTrace) {
        AppLogger.warning('오디오 재생 완료 대기 중 오류', data: {'error': e.toString()});
      }

      AppLogger.success('오디오 재생 완료', data: {'audioPath': audioPath});
    } catch (e, stackTrace) {
      AppLogger.error(
        '오디오 재생 실패',
        error: e,
        stackTrace: stackTrace,
        data: {'audioPath': audioPath},
      );
      rethrow;
    } finally {
      if (onStateChanged != null) {
        onStateChanged(false);
      }
    }
  }

  /// 여러 오디오 파일을 순차적으로 재생
  /// 
  /// [audioPaths]: 재생할 오디오 파일 경로 리스트
  /// [delayBetween]: 각 오디오 사이의 딜레이 (밀리초)
  /// [onStateChanged]: 재생 상태 변경 콜백 (선택사항)
  Future<void> playSequence(
    List<String> audioPaths, {
    int? delayBetween,
    void Function(bool isPlaying)? onStateChanged,
  }) async {
    final delay = delayBetween ?? AudioConstants.audioSequenceDelayMs;

    AppLogger.audio('순차 오디오 재생 시작', data: {
      'audioCount': audioPaths.length,
      'delayBetweenMs': delay,
    });

    for (int i = 0; i < audioPaths.length; i++) {
      final audioPath = audioPaths[i];
      AppLogger.audio('오디오 시퀀스: ${i + 1}/${audioPaths.length} 재생 시작', data: {
        'audioPath': audioPath,
      });

      try {
        await playAsset(audioPath, onStateChanged: onStateChanged);
        AppLogger.success('오디오 시퀀스: ${i + 1}/${audioPaths.length} 재생 완료');

        // 마지막이 아니면 딜레이
        if (i < audioPaths.length - 1) {
          AppLogger.delay('오디오 시퀀스: 다음 소리 전 딜레이', data: {'ms': delay});
          await Future.delayed(Duration(milliseconds: delay));
        }
      } catch (e, stackTrace) {
        AppLogger.error(
          '오디오 시퀀스: 오디오 재생 실패',
          error: e,
          stackTrace: stackTrace,
          data: {'audioPath': audioPath},
        );
        // 계속 진행
      }
    }

    AppLogger.success('오디오 시퀀스: 모든 오디오 재생 완료');
  }

  /// 재생 중지
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      AppLogger.debug('오디오 재생 중지 완료');
    } catch (e, stackTrace) {
      AppLogger.warning('오디오 재생 중지 실패', data: {'error': e.toString()});
    }
  }

  /// 현재 재생 상태
  PlayerState get state => _audioPlayer.state;

  /// 리소스 정리
  void dispose() {
    _audioPlayer.dispose();
  }

  /// 오디오 파일 존재 여부 확인
  Future<bool> _checkAudioFileExists(String audioPath) async {
    try {
      // rootBundle.load는 'assets/' 접두사를 제외한 경로를 받습니다
      final bundlePath = AssetPaths.removeAssetsPrefix(audioPath);
      AppLogger.debug('파일 존재 확인', data: {
        'bundlePath': bundlePath,
        'originalPath': audioPath,
      });

      await rootBundle.load(bundlePath);
      AppLogger.success('파일 존재 확인 성공', data: {'bundlePath': bundlePath});
      return true;
    } catch (e, stackTrace) {
      AppLogger.warning('오디오 파일 존재 확인 실패', data: {
        'audioPath': audioPath,
        'error': e.toString(),
      });
      // Web에서는 파일 확인이 실패해도 재생은 시도해봄
      return false;
    }
  }
}
