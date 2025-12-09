import 'package:flutter/material.dart';

import '../design/design_system.dart';
import 'child_friendly_button.dart';

/// 아동 친화적 다이얼로그
/// 
/// **특징:**
/// - 큰 터치 영역
/// - 명확한 시각적 구분
/// - 느린 애니메이션 (1.5배 느리게)
/// - 이미지/아이콘 중심 (Zero-Text Interface)
/// 
/// **사용 예시:**
/// - 확인 다이얼로그
/// - 선택 다이얼로그 (예/아니오)
/// - 알림 다이얼로그
class ChildFriendlyDialog extends StatelessWidget {
  /// 제목 (부모 모드용)
  final String? title;

  /// 내용 (부모 모드용)
  final String? content;

  /// 아이콘 (아동 모드에서 주로 사용)
  final IconData? icon;

  /// 이미지 (아동 모드에서 주로 사용)
  final Widget? image;

  /// 다이얼로그 타입
  final DialogType type;

  /// 확인 버튼 텍스트
  final String? confirmText;

  /// 취소 버튼 텍스트
  final String? cancelText;

  /// 확인 콜백
  final VoidCallback? onConfirm;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 확인 버튼 색상
  final Color? confirmColor;

  /// 취소 버튼 색상
  final Color? cancelColor;

  /// 단일 버튼 여부 (확인 버튼만 표시)
  final bool singleButton;

  const ChildFriendlyDialog({
    super.key,
    this.title,
    this.content,
    this.icon,
    this.image,
    this.type = DialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.cancelColor,
    this.singleButton = false,
  }) : assert(
          title != null || content != null || icon != null || image != null,
          'title, content, icon, 또는 image 중 하나는 필수입니다 (Zero-Text Interface 지원).',
        );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.borderRadiusXL),
      ),
      child: Container(
        padding: DesignSystem.paddingXL,
        constraints: const BoxConstraints(
          maxWidth: 400,
          minHeight: 200,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 또는 이미지
            if (icon != null || image != null) ...[
              if (image != null)
                image!
              else if (icon != null)
                Icon(
                  icon,
                  size: DesignSystem.iconSizeXXL,
                  color: _getIconColor(),
                ),
              const SizedBox(height: DesignSystem.spacingLG),
            ],

            // 제목
            if (title != null) ...[
              Text(
                title!,
                style: DesignSystem.textStyleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingMD),
            ],

            // 내용
            if (content != null) ...[
              Text(
                content!,
                style: DesignSystem.textStyleRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignSystem.spacingXL),
            ],

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!singleButton && cancelText != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: DesignSystem.spacingSM),
                      child: ChildFriendlyButton(
                        label: cancelText,
                        type: ChildButtonType.neutral,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                        size: ChildButtonSize.medium,
                      ),
                    ),
                  ),
                Expanded(
                  child: ChildFriendlyButton(
                    label: confirmText ?? '확인',
                    type: _getConfirmButtonType(),
                    color: confirmColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                    size: ChildButtonSize.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor() {
    switch (type) {
      case DialogType.success:
        return DesignSystem.childFriendlyGreen;
      case DialogType.error:
        return DesignSystem.childFriendlyRed;
      case DialogType.warning:
        return DesignSystem.childFriendlyYellow;
      case DialogType.info:
        return DesignSystem.primaryBlue;
    }
  }

  ChildButtonType _getConfirmButtonType() {
    switch (type) {
      case DialogType.success:
        return ChildButtonType.success;
      case DialogType.error:
        return ChildButtonType.error;
      case DialogType.warning:
        return ChildButtonType.warning;
      case DialogType.info:
        return ChildButtonType.primary;
    }
  }
}

/// 다이얼로그 타입
enum DialogType {
  /// 정보
  info,

  /// 성공
  success,

  /// 오류
  error,

  /// 경고
  warning,
}

/// 다이얼로그 표시 헬퍼
class DialogHelper {
  /// 아동 친화적 다이얼로그 표시
  static Future<T?> showChildFriendlyDialog<T>({
    required BuildContext context,
    String? title,
    String? content,
    IconData? icon,
    Widget? image,
    DialogType type = DialogType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    bool singleButton = false,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: DesignSystem.opacityOverlay),
      builder: (context) => ChildFriendlyDialog(
        title: title,
        content: content,
        icon: icon,
        image: image,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        singleButton: singleButton,
      ),
    );
  }

  /// 확인 다이얼로그 표시
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    String cancelText = '취소',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    final result = await showChildFriendlyDialog<bool>(
      context: context,
      title: title,
      content: content,
      type: DialogType.info,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
    return result ?? false;
  }

  /// 알림 다이얼로그 표시
  static Future<void> showAlertDialog({
    required BuildContext context,
    String? title,
    String? content,
    String confirmText = '확인',
    DialogType type = DialogType.info,
    VoidCallback? onConfirm,
  }) {
    return showChildFriendlyDialog(
      context: context,
      title: title,
      content: content,
      type: type,
      confirmText: confirmText,
      singleButton: true,
      onConfirm: onConfirm,
    );
  }
}

