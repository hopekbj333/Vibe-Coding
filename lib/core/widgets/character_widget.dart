/// 캐릭터 위젯
/// 
/// 감정에 따라 적절한 캐릭터 이미지를 표시합니다.
/// 실제 캐릭터 이미지가 없으면 아이콘으로 대체됩니다.

import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/assets/asset_utils.dart';

/// 캐릭터 감정 타입
enum CharacterEmotion {
  happy,        // 😊 기쁨 - 정답 피드백
  neutral,      // 😐 중립 - 기본 상태, 로딩
  thinking,     // 🤔 생각 - 문제 제시
  sad,          // 😢 슬픔 - 오답 피드백 (격려)
  excited,      // 🤩 신남 - 레벨업, 완료
}

/// 캐릭터 위젯
/// 
/// 사용 예시:
/// ```dart
/// CharacterWidget(
///   emotion: CharacterEmotion.happy,
///   size: 200,
/// )
/// ```
class CharacterWidget extends StatelessWidget {
  /// 캐릭터 감정
  final CharacterEmotion emotion;
  
  /// 캐릭터 크기 (정사각형)
  final double? size;
  
  /// 이미지 fit 방식
  final BoxFit fit;
  
  /// 애니메이션 활성화 여부
  final bool animate;

  const CharacterWidget({
    super.key,
    required this.emotion,
    this.size,
    this.fit = BoxFit.contain,
    this.animate = true,
  });

  /// 크기 프리셋
  static const double sizeSmall = 100;
  static const double sizeMedium = 150;
  static const double sizeLarge = 200;
  static const double sizeXLarge = 250;

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImagePath(emotion);
    
    final imageWidget = Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: fit,
      key: ValueKey('character_image_$emotion'), // 이미지 위젯에 key 추가하여 리빌드 방지
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 Placeholder 표시
        return _buildPlaceholder();
      },
    );

    if (animate) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: imageWidget,
        key: ValueKey(emotion), // 감정 변경 시 애니메이션
      );
    }

    // 애니메이션이 비활성화된 경우 RepaintBoundary로 감싸서 리페인트 방지
    return RepaintBoundary(
      child: imageWidget,
    );
  }

  /// Placeholder 위젯 (이미지 로드 실패 시)
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getEmotionColor(emotion).withOpacity(0.2),
        border: Border.all(
          color: _getEmotionColor(emotion),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmotionIcon(emotion),
            size: (size ?? 100) * 0.4,
            color: _getEmotionColor(emotion),
          ),
          if (size != null && size! > 100) ...[
            const SizedBox(height: 8),
            Text(
              _getEmotionText(emotion),
              style: TextStyle(
                color: _getEmotionColor(emotion),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 감정에 따른 이미지 경로 반환
  String _getImagePath(CharacterEmotion emotion) {
    final fileName = switch (emotion) {
      CharacterEmotion.happy => 'character_happy.png',
      CharacterEmotion.neutral => 'character_neutral.png',
      CharacterEmotion.thinking => 'character_thinking.png',
      CharacterEmotion.sad => 'character_sad.png',
      CharacterEmotion.excited => 'character_excited.png',
    };
    
    return AssetUtils.characterPath(fileName);
  }

  /// 감정에 따른 색상 (Placeholder용)
  Color _getEmotionColor(CharacterEmotion emotion) {
    return switch (emotion) {
      CharacterEmotion.happy => Colors.green,
      CharacterEmotion.neutral => Colors.blue,
      CharacterEmotion.thinking => Colors.orange,
      CharacterEmotion.sad => Colors.grey,
      CharacterEmotion.excited => Colors.pink,
    };
  }

  /// 감정에 따른 아이콘 (Placeholder용)
  IconData _getEmotionIcon(CharacterEmotion emotion) {
    return switch (emotion) {
      CharacterEmotion.happy => Icons.sentiment_satisfied_alt,
      CharacterEmotion.neutral => Icons.sentiment_neutral,
      CharacterEmotion.thinking => Icons.psychology,
      CharacterEmotion.sad => Icons.sentiment_dissatisfied,
      CharacterEmotion.excited => Icons.celebration,
    };
  }

  /// 감정에 따른 텍스트 (Placeholder용)
  String _getEmotionText(CharacterEmotion emotion) {
    return switch (emotion) {
      CharacterEmotion.happy => '😊 기쁨',
      CharacterEmotion.neutral => '😐 중립',
      CharacterEmotion.thinking => '🤔 생각',
      CharacterEmotion.sad => '😢 슬픔',
      CharacterEmotion.excited => '🤩 신남',
    };
  }
}
