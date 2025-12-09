import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/firebase/firebase_config.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 변수 로드
  // 환경 변수는 빌드 시 --dart-define=ENV_FILE=.env.dev 형태로 전달
  // 또는 기본값으로 .env.dev 사용
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env.dev');
  try {
    await dotenv.load(fileName: envFile);
    if (kDebugMode) {
      print('✓ Environment file loaded: $envFile');
    }
  } catch (e) {
    // .env 파일이 없어도 앱이 실행되도록 함 (개발 편의성)
    // 하지만 환경 변수는 기본값을 사용하게 됨
    if (kDebugMode) {
      print('⚠ Warning: Could not load $envFile. Using default values.');
      print('  Error: $e');
      print('  Please create $envFile file or use --dart-define=ENV_FILE=<file>');
    }
  }
  
  // Firebase 초기화
  // Firebase가 설정되지 않은 경우에도 앱이 실행되도록 안전하게 처리
  await FirebaseConfig.initialize();
  
  // Firebase가 초기화된 경우 Crashlytics 설정
  if (FirebaseConfig.isInitialized) {
    FirebaseConfig.setupCrashlytics();
  }
  
  runApp(
    const ProviderScope(
      child: LiteracyAssessmentApp(),
    ),
  );
}

class LiteracyAssessmentApp extends ConsumerWidget {
  const LiteracyAssessmentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '문해력 기초 검사',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.createRouter(ref),
      // 로케일 설정 (DatePicker 등 위젯에서 필요)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어 (기본값)
      ],
      locale: const Locale('ko', 'KR'), // 기본 로케일을 한국어로 설정
    );
  }
}

