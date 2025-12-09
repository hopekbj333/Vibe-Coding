import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_mode_providers.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../domain/services/pin_service.dart';

/// PIN 잠금 화면
/// 
/// 부모 모드로 전환하기 위해 PIN을 입력하는 화면입니다.
class PinLockPage extends ConsumerStatefulWidget {
  final bool isSettingPin;

  const PinLockPage({
    super.key,
    this.isSettingPin = false,
  });

  @override
  ConsumerState<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends ConsumerState<PinLockPage> {
  final PinService _pinService = PinService();
  String _enteredPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isConfirming = false;
  String? _firstPin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.neutralGray50,
      appBar: AppBar(
        title: Text(
          widget.isSettingPin ? 'PIN 설정' : '부모 모드 잠금 해제',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSystem.spacingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                const Icon(
                  Icons.lock,
                  size: DesignSystem.iconSizeXXL,
                  color: DesignSystem.primaryBlue,
                ),
                const SizedBox(height: DesignSystem.spacingLG),

                // 제목
                Text(
                  widget.isSettingPin
                      ? (_isConfirming ? 'PIN을 다시 입력하세요' : '4자리 PIN을 설정하세요')
                      : '4자리 PIN을 입력하세요',
                  style: DesignSystem.parentTextStyleTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignSystem.spacingMD),

                // PIN 입력 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    PinService.pinLength,
                    (index) => Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _enteredPin.length
                            ? DesignSystem.primaryBlue
                            : DesignSystem.neutralGray300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DesignSystem.spacingLG),

                // 에러 메시지
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: DesignSystem.textStyleSmall.copyWith(
                      color: DesignSystem.semanticError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignSystem.spacingMD),
                ],

                // 숫자 키패드
                _buildKeypad(),

                const SizedBox(height: DesignSystem.spacingLG),

                // 취소 버튼
                if (!widget.isSettingPin)
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('취소'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: DesignSystem.spacingMD),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: DesignSystem.spacingMD),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: DesignSystem.spacingMD),
        _buildKeypadRow(['', '0', '⌫']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 80);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleKeyPress(key),
              style: ElevatedButton.styleFrom(
                backgroundColor: key == '⌫'
                    ? DesignSystem.neutralGray300
                    : Colors.white,
                foregroundColor: DesignSystem.neutralGray900,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.borderRadiusMD),
                ),
              ),
              child: Text(
                key,
                style: DesignSystem.textStyleLarge,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleKeyPress(String key) async {
    if (key == '⌫') {
      setState(() {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
          _errorMessage = null;
        }
      });
      return;
    }

    if (_enteredPin.length < PinService.pinLength) {
      setState(() {
        _enteredPin += key;
        _errorMessage = null;
      });

      // PIN이 4자리가 되면 자동으로 처리
      if (_enteredPin.length == PinService.pinLength) {
        await _processPin();
      }
    }
  }

  Future<void> _processPin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isSettingPin) {
        if (!_isConfirming) {
          // 첫 번째 PIN 입력
          setState(() {
            _firstPin = _enteredPin;
            _enteredPin = '';
            _isConfirming = true;
          });
        } else {
          // 두 번째 PIN 확인
          if (_enteredPin == _firstPin) {
            final success = await _pinService.setPin(_enteredPin);
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN이 설정되었습니다'),
                  backgroundColor: DesignSystem.semanticSuccess,
                ),
              );
              context.pop();
            } else {
              setState(() {
                _errorMessage = 'PIN 설정에 실패했습니다';
                _enteredPin = '';
                _isConfirming = false;
                _firstPin = null;
              });
            }
          } else {
            setState(() {
              _errorMessage = 'PIN이 일치하지 않습니다';
              _enteredPin = '';
              _isConfirming = false;
              _firstPin = null;
            });
          }
        }
      } else {
        // PIN 확인
        final isValid = await _pinService.verifyPin(_enteredPin);
        if (isValid && mounted) {
          // PIN 확인 성공 - 결과를 반환하고 화면 닫기
          context.pop(true);
        } else {
          setState(() {
            _errorMessage = 'PIN이 올바르지 않습니다';
            _enteredPin = '';
            HapticFeedback.vibrate(); // 진동 피드백
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

