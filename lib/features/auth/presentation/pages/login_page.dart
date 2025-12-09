import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_config.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/widgets/child_friendly_dialog.dart';
import '../../../../core/widgets/child_friendly_loading_indicator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

/// 로그인 화면
/// 
/// 이메일/비밀번호 로그인 및 소셜 로그인을 제공합니다.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // 개발용 자동 로그인 설정
  static const _devEmail = 'test@test.com';
  static const _devPassword = 'test1234';

  @override
  void initState() {
    super.initState();
    // 개발 모드에서 자동 로그인
    if (AppConfig.isDevelopment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoLoginForDev();
      });
    }
  }

  /// 개발 모드 전용 자동 로그인
  Future<void> _autoLoginForDev() async {
    _emailController.text = _devEmail;
    _passwordController.text = _devPassword;
    await _handleEmailLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 상태 관리
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await ref.read(
        signInWithEmailProvider(
          SignInParams(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        ).future,
      );

      ref.read(authLoadingProvider.notifier).state = false;
      if (mounted) {
        // 로그인 성공: 홈 화면으로 이동
        context.go('/home');
      }
    } catch (e) {
      ref.read(authLoadingProvider.notifier).state = false;
      final errorMessage = e is AuthException ? e.message : '로그인 중 오류가 발생했습니다.';
      ref.read(authErrorProvider.notifier).state = errorMessage;
    }
  }

  Future<void> _handleGoogleLogin() async {
    // 상태 관리
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await ref.read(signInWithGoogleProvider.future);

      ref.read(authLoadingProvider.notifier).state = false;
      if (mounted) {
        // 로그인 성공: 홈 화면으로 이동
        context.go('/home');
      }
    } catch (e) {
      ref.read(authLoadingProvider.notifier).state = false;
      final errorMessage = e is AuthException ? e.message : 'Google 로그인 중 오류가 발생했습니다.';
      ref.read(authErrorProvider.notifier).state = errorMessage;
    }
  }

  Future<void> _handleAppleLogin() async {
    // 상태 관리
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await ref.read(signInWithAppleProvider.future);

      ref.read(authLoadingProvider.notifier).state = false;
      if (mounted) {
        // 로그인 성공: 홈 화면으로 이동
        context.go('/home');
      }
    } catch (e) {
      ref.read(authLoadingProvider.notifier).state = false;
      final errorMessage = e is AuthException ? e.message : 'Apple 로그인 중 오류가 발생했습니다.';
      ref.read(authErrorProvider.notifier).state = errorMessage;
    }
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      DialogHelper.showAlertDialog(
        context: context,
        title: '알림',
        content: '이메일을 입력해주세요.',
        type: DialogType.warning,
      );
      return;
    }

    DialogHelper.showConfirmDialog(
      context: context,
      title: '비밀번호 재설정',
      content: '$email로 비밀번호 재설정 이메일을 보내시겠습니까?',
      onConfirm: () async {
        try {
          await ref.read(resetPasswordProvider(email).future);
          if (mounted) {
            DialogHelper.showAlertDialog(
              context: context,
              title: '전송 완료',
              content: '비밀번호 재설정 이메일을 보냈습니다.',
              type: DialogType.success,
            );
          }
        } catch (e) {
          // 에러는 authErrorProvider에서 처리됨
        }
      },
    );
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
                    const SizedBox(height: 48),
                    
                    // 로고/제목
                    const Icon(
                      Icons.book,
                      size: DesignSystem.iconSizeXXL,
                      color: DesignSystem.primaryBlue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '문해력 기초 검사',
                      style: DesignSystem.textStyleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // 이메일 입력
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: '이메일',
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
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
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
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingSM),

                    // 비밀번호 찾기
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword,
                        child: const Text('비밀번호 찾기'),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 로그인 버튼
                    ChildFriendlyButton(
                      label: '로그인',
                      icon: Icons.login,
                      onPressed: isLoading ? null : _handleEmailLogin,
                      fullWidth: true,
                      size: ChildButtonSize.medium,
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 구분선
                    const Row(
                      children: [
                        Expanded(child: Divider(color: DesignSystem.neutralGray300)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.spacingMD,
                          ),
                          child: Text(
                            '또는',
                            style: DesignSystem.textStyleSmall,
                          ),
                        ),
                        Expanded(child: Divider(color: DesignSystem.neutralGray300)),
                      ],
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // Google 로그인
                    ChildFriendlyButton(
                      label: 'Google로 로그인',
                      icon: Icons.login,
                      type: ChildButtonType.neutral,
                      onPressed: isLoading ? null : _handleGoogleLogin,
                      fullWidth: true,
                      size: ChildButtonSize.medium,
                    ),
                    const SizedBox(height: DesignSystem.spacingSM),

                    // Apple 로그인 (iOS만 표시)
                    // TODO: Platform.isIOS 체크 추가
                    ChildFriendlyButton(
                      label: 'Apple로 로그인',
                      icon: Icons.phone_iphone,
                      type: ChildButtonType.neutral,
                      onPressed: isLoading ? null : _handleAppleLogin,
                      fullWidth: true,
                      size: ChildButtonSize.medium,
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 회원가입 링크
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '계정이 없으신가요? ',
                          style: DesignSystem.textStyleRegular,
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/auth/signup');
                          },
                          child: const Text('회원가입'),
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
                message: '로그인 중...',
              ),
          ],
        ),
      ),
    );
  }
}

