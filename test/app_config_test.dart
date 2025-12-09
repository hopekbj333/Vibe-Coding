import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:literacy_assessment/config/app_config.dart';

void main() {
  group('AppConfig', () {
    setUp(() async {
      // 테스트용 환경 변수 직접 설정
      dotenv.testLoad(fileInput: '''
ENVIRONMENT=development
APP_NAME=문해력 기초 검사 테스트
APP_VERSION=1.0.0-test
API_BASE_URL=http://test.example.com
''');
    });

    tearDown(() {
      // 테스트 후 정리 (필요시)
    });

    test('환경 타입이 올바르게 파싱되는지 확인', () {
      expect(AppConfig.environment, AppEnvironment.development);
    });

    test('앱 이름이 올바르게 로드되는지 확인', () {
      expect(AppConfig.appName, '문해력 기초 검사 테스트');
    });

    test('앱 버전이 올바르게 로드되는지 확인', () {
      expect(AppConfig.appVersion, '1.0.0-test');
    });

    test('API 베이스 URL이 올바르게 로드되는지 확인', () {
      expect(AppConfig.apiBaseUrl, 'http://test.example.com');
    });

    test('환경 변수가 없을 때 기본값 사용', () {
      dotenv.testLoad(fileInput: '');
      expect(AppConfig.appName, '문해력 기초 검사');
      expect(AppConfig.appVersion, '1.0.0');
      expect(AppConfig.environment, AppEnvironment.development);
    });

    test('프로덕션 환경 파싱', () {
      dotenv.testLoad(fileInput: 'ENVIRONMENT=production');
      expect(AppConfig.environment, AppEnvironment.production);
      expect(AppConfig.isProduction, true);
      expect(AppConfig.isDevelopment, false);
    });

    test('스테이징 환경 파싱', () {
      dotenv.testLoad(fileInput: 'ENVIRONMENT=staging');
      expect(AppConfig.environment, AppEnvironment.staging);
      expect(AppConfig.isStaging, true);
      expect(AppConfig.isDevelopment, false);
    });
  });
}

