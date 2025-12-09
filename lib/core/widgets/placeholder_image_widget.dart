/// Placeholder 이미지 위젯
/// 
/// 에셋이 준비되기 전에 UI 개발을 진행하기 위한 임시 이미지 위젯입니다.
/// 실제 에셋이 준비되면 Image.asset()으로 교체하면 됩니다.

import 'package:flutter/material.dart';

/// Placeholder 이미지 타입
enum PlaceholderType {
  character,    // 캐릭터 (정사각형)
  icon,         // 아이콘 (작은 정사각형)
  badge,        // 배지 (중간 정사각형)
  gameAsset,    // 게임 에셋 (정사각형)
  audio,        // 오디오 (가로형)
}

/// 감정 타입 (캐릭터용)
enum CharacterEmotion {
  happy,        // 기쁨
  neutral,      // 중립
  thinking,     // 생각
  sad,          // 슬픔
  excited,      // 신남
}

/// Placeholder 이미지 위젯
/// 
/// 사용 예시:
/// ```dart
/// PlaceholderImageWidget(
///   type: PlaceholderType.character,
///   label: '캐릭터',
///   emotion: CharacterEmotion.happy,
/// )
/// ```
class PlaceholderImageWidget extends StatelessWidget {
  final PlaceholderType type;
  final String label;
  final CharacterEmotion? emotion;
  final double? width;
  final double? height;
  final bool showLabel;

  const PlaceholderImageWidget({
    super.key,
    required this.type,
    required this.label,
    this.emotion,
    this.width,
    this.height,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = _getSize();
    final color = _getColor();
    final icon = _getIcon();

    return Container(
      width: width ?? size.width,
      height: height ?? size.height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: size.width * 0.4,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (emotion != null) ...[
            const SizedBox(height: 4),
            Text(
              _getEmotionText(emotion!),
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 타입별 크기 반환
  Size _getSize() {
    switch (type) {
      case PlaceholderType.character:
        return const Size(200, 200);
      case PlaceholderType.icon:
        return const Size(80, 80);
      case PlaceholderType.badge:
        return const Size(120, 120);
      case PlaceholderType.gameAsset:
        return const Size(150, 150);
      case PlaceholderType.audio:
        return const Size(200, 100);
    }
  }

  /// 타입별 색상 반환
  Color _getColor() {
    switch (type) {
      case PlaceholderType.character:
        return _getEmotionColor(emotion ?? CharacterEmotion.neutral);
      case PlaceholderType.icon:
        return Colors.blue;
      case PlaceholderType.badge:
        return Colors.amber;
      case PlaceholderType.gameAsset:
        return Colors.green;
      case PlaceholderType.audio:
        return Colors.purple;
    }
  }

  /// 타입별 아이콘 반환
  IconData _getIcon() {
    switch (type) {
      case PlaceholderType.character:
        return _getEmotionIcon(emotion ?? CharacterEmotion.neutral);
      case PlaceholderType.icon:
        return Icons.star;
      case PlaceholderType.badge:
        return Icons.emoji_events;
      case PlaceholderType.gameAsset:
        return Icons.image;
      case PlaceholderType.audio:
        return Icons.volume_up;
    }
  }

  /// 감정별 색상 반환
  Color _getEmotionColor(CharacterEmotion emotion) {
    switch (emotion) {
      case CharacterEmotion.happy:
        return Colors.green;
      case CharacterEmotion.neutral:
        return Colors.blue;
      case CharacterEmotion.thinking:
        return Colors.orange;
      case CharacterEmotion.sad:
        return Colors.grey;
      case CharacterEmotion.excited:
        return Colors.pink;
    }
  }

  /// 감정별 아이콘 반환
  IconData _getEmotionIcon(CharacterEmotion emotion) {
    switch (emotion) {
      case CharacterEmotion.happy:
        return Icons.sentiment_satisfied_alt;
      case CharacterEmotion.neutral:
        return Icons.sentiment_neutral;
      case CharacterEmotion.thinking:
        return Icons.psychology;
      case CharacterEmotion.sad:
        return Icons.sentiment_dissatisfied;
      case CharacterEmotion.excited:
        return Icons.celebration;
    }
  }

  /// 감정별 텍스트 반환
  String _getEmotionText(CharacterEmotion emotion) {
    switch (emotion) {
      case CharacterEmotion.happy:
        return '😊 기쁨';
      case CharacterEmotion.neutral:
        return '😐 중립';
      case CharacterEmotion.thinking:
        return '🤔 생각';
      case CharacterEmotion.sad:
        return '😢 슬픔';
      case CharacterEmotion.excited:
        return '🤩 신남';
    }
  }
}

/// 캐릭터 Placeholder 위젯 (간편 사용)
class CharacterPlaceholder extends StatelessWidget {
  final CharacterEmotion emotion;
  final double? size;

  const CharacterPlaceholder({
    super.key,
    required this.emotion,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return PlaceholderImageWidget(
      type: PlaceholderType.character,
      label: '캐릭터',
      emotion: emotion,
      width: size,
      height: size,
    );
  }
}

/// 게임 에셋 Placeholder 위젯 (간편 사용)
class GameAssetPlaceholder extends StatelessWidget {
  final String label;
  final double? size;

  const GameAssetPlaceholder({
    super.key,
    required this.label,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return PlaceholderImageWidget(
      type: PlaceholderType.gameAsset,
      label: label,
      width: size,
      height: size,
    );
  }
}

/// UI 아이콘 Placeholder 위젯 (간편 사용)
class IconPlaceholder extends StatelessWidget {
  final String label;
  final double? size;

  const IconPlaceholder({
    super.key,
    required this.label,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return PlaceholderImageWidget(
      type: PlaceholderType.icon,
      label: label,
      width: size,
      height: size,
      showLabel: false,
    );
  }
}

/// 배지 Placeholder 위젯 (간편 사용)
class BadgePlaceholder extends StatelessWidget {
  final String label;
  final double? size;

  const BadgePlaceholder({
    super.key,
    required this.label,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return PlaceholderImageWidget(
      type: PlaceholderType.badge,
      label: label,
      width: size,
      height: size,
    );
  }
}
