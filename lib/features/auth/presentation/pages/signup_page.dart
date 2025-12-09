import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/auth_providers.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/widgets/child_friendly_dialog.dart';
import '../../../../core/widgets/child_friendly_loading_indicator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

/// 회원가입 화면
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      DialogHelper.showAlertDialog(
        context: context,
        title: '알림',
        content: '이용약관에 동의해주세요.',
        type: DialogType.warning,
      );
      return;
    }

    // 상태 관리
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      if (kDebugMode) {
        print('✓ Sign up button pressed');
      }
      
      // 이전 상태 초기화 (재시도 시 중요)
      ref.invalidate(signUpWithEmailProvider);
      
      final userModel = await ref.read(
        signUpWithEmailProvider(
          SignUpParams(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _displayNameController.text.trim().isEmpty
                ? null
                : _displayNameController.text.trim(),
          ),
        ).future,
      );

      if (kDebugMode) {
        print('✓ Sign up provider completed: ${userModel.uid}');
      }

      ref.read(authLoadingProvider.notifier).state = false;
      
      if (mounted) {
        if (kDebugMode) {
          print('✓ Sign up successful, user: ${userModel.uid}');
          print('✓ Navigating to home...');
        }
        
        // 회원가입 성공 후 홈 화면으로 이동
        // authStateChangesProvider는 Stream이므로 자동으로 업데이트됨
        // 하지만 즉시 리다이렉트하기 위해 약간의 지연을 둠
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          // 인증 상태 Provider를 무효화하여 즉시 재계산
          ref.invalidate(authStatusProvider);
          ref.invalidate(userModelProvider);
          
          // 다시 약간의 지연을 두어 상태 업데이트 대기
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            if (kDebugMode) {
              print('✓ Executing navigation to /home');
            }
            context.go('/home');
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('⚠ Sign up error caught: $e');
        print('  Stack trace: $stackTrace');
      }
      ref.read(authLoadingProvider.notifier).state = false;
      final errorMessage = e is AuthException ? e.message : '회원가입 중 오류가 발생했습니다.';
      ref.read(authErrorProvider.notifier).state = errorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);

    // 에러 표시
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        DialogHelper.showAlertDialog(
          context: context,
          title: '오류',
          content: error,
          type: DialogType.error,
        );
        ref.read(authErrorProvider.notifier).state = null;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            SingleChildScrollView(
              padding: DesignSystem.paddingXL,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // 이름 입력 (선택)
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText: '이름 (선택)',
                        hintText: '이름을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMD,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 이메일 입력
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: '이메일 *',
                        hintText: 'example@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMD,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요.';
                        }
                        if (!RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,4}$')
                            .hasMatch(value)) {
                          return '올바른 이메일 형식이 아닙니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 비밀번호 입력
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호 *',
                        hintText: '최소 8자, 영문과 숫자 포함',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMD,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        }
                        if (value.length < 8) {
                          return '비밀번호는 최소 8자 이상이어야 합니다.';
                        }
                        if (!RegExp(r'[a-zA-Z]').hasMatch(value) ||
                            !RegExp(r'[0-9]').hasMatch(value)) {
                          return '비밀번호는 영문과 숫자를 포함해야 합니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 비밀번호 확인
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인 *',
                        hintText: '비밀번호를 다시 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            DesignSystem.borderRadiusMD,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호 확인을 입력해주세요.';
                        }
                        if (value != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 이용약관 동의
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: 이용약관 화면으로 이동
                            },
                            child: const Text(
                              '이용약관 및 개인정보처리방침에 동의합니다.',
                              style: DesignSystem.textStyleSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 회원가입 버튼
                    ChildFriendlyButton(
                      label: '회원가입',
                      icon: Icons.person_add,
                      onPressed: isLoading ? null : _handleSignUp,
                      fullWidth: true,
                      size: ChildButtonSize.medium,
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 로그인 링크
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          '이미 계정이 있으신가요?',
                          style: DesignSystem.textStyleRegular,
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: const Text('로그인'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 로딩 오버레이
            if (isLoading)
              const ChildFriendlyLoadingOverlay(
                message: '회원가입 중...',
              ),
          ],
        ),
      ),
    );
  }
}

