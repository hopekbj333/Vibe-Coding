import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/question_model.dart';

/// S 1.5.7: 숨은 그림 찾기 위젯
/// 
/// 복잡한 배경 안에서 특정 도형/패턴을 찾아 터치합니다.
class HiddenPictureWidget extends StatefulWidget {
  final QuestionModel question;
  final bool isInputBlocked;
  final Function(String answer) onAnswerSelected;

  const HiddenPictureWidget({
    super.key,
    required this.question,
    required this.isInputBlocked,
    required this.onAnswerSelected,
  });

  @override
  State<HiddenPictureWidget> createState() => _HiddenPictureWidgetState();
}

class _HiddenPictureWidgetState extends State<HiddenPictureWidget> {
  Offset? _tapPosition;
  bool _answered = false;

  @override
  void didUpdateWidget(HiddenPictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _tapPosition = null;
        _answered = false;
      });
    }
  }

  void _onImageTap(TapDownDetails details) {
    if (widget.isInputBlocked || _answered) return;

    final position = details.localPosition;
    debugPrint('🖼️ 이미지 터치: (${position.dx.toInt()}, ${position.dy.toInt()})');

    setState(() {
      _tapPosition = position;
      _answered = true;
    });

    // 터치 위치를 문자열로 변환하여 제출
    final answer = '${position.dx.toInt()},${position.dy.toInt()}';

    // 1초 후 제출 (시각적 피드백)
    Future.delayed(const Duration(seconds: 1), () {
      widget.onAnswerSelected(answer);
    });
  }

  String _getTargetShape() {
    // soundLabels[0]에서 찾을 도형 가져오기
    if (widget.question.soundLabels.isEmpty) return 'star';
    return widget.question.soundLabels[0];
  }

  Widget _buildTargetShapeIcon(String shapeName) {
    IconData iconData;
    switch (shapeName.toLowerCase()) {
      case 'star':
        iconData = Icons.star;
        break;
      case 'circle':
        iconData = Icons.circle;
        break;
      case 'triangle':
        iconData = Icons.change_history;
        break;
      case 'square':
        iconData = Icons.square;
        break;
      default:
        iconData = Icons.shape_line;
    }

    return Icon(
      iconData,
      size: 40,
      color: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetShape = _getTargetShape();

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            widget.question.promptText,
            style: DesignSystem.textStyleLarge,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // 찾을 도형 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '찾을 모양: ',
                style: DesignSystem.textStyleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTargetShapeIcon(targetShape),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 숨은 그림 이미지
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GestureDetector(
            onTapDown: _onImageTap,
            child: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: DesignSystem.neutralGray100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: DesignSystem.neutralGray300,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // 배경 이미지
                    if (widget.question.optionsImageUrl.isNotEmpty)
                      Image.asset(
                        widget.question.optionsImageUrl[0],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderScene();
                        },
                      )
                    else
                      _buildPlaceholderScene(),

                    // 터치한 위치 표시
                    if (_tapPosition != null)
                      Positioned(
                        left: _tapPosition!.dx - 25,
                        top: _tapPosition!.dy - 25,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.red,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 안내 텍스트
        if (!_answered)
          Text(
            '그림을 눌러서 숨은 모양을 찾아봐!',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.primaryBlue,
            ),
          )
        else
          Text(
            '여기를 찾았어!',
            style: DesignSystem.textStyleMedium.copyWith(
              color: DesignSystem.semanticSuccess,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 이미지가 없을 때 표시할 임시 장면
  Widget _buildPlaceholderScene() {
    return Container(
      color: Colors.lightBlue.withOpacity(0.3),
      child: Stack(
        children: [
          // 배경 요소들 (임시)
          Positioned(
            top: 50,
            left: 30,
            child: Icon(Icons.cloud, size: 60, color: Colors.grey[300]),
          ),
          Positioned(
            top: 80,
            right: 40,
            child: Icon(Icons.cloud, size: 50, color: Colors.grey[300]),
          ),
          Positioned(
            bottom: 100,
            left: 50,
            child: Icon(Icons.grass, size: 40, color: Colors.green[300]),
          ),
          Positioned(
            bottom: 120,
            right: 60,
            child: Icon(Icons.local_florist, size: 35, color: Colors.pink[200]),
          ),
          // 숨은 도형 (힌트)
          Positioned(
            top: 150,
            left: 100,
            child: Icon(
              Icons.star,
              size: 45,
              color: Colors.yellow.withOpacity(0.4),
            ),
          ),
          // 텍스트
          Center(
            child: Text(
              '(임시 이미지)\n\n숨은 별을 찾아봐!',
              style: DesignSystem.textStyleMedium.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

