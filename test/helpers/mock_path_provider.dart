import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// 테스트 환경에서 path_provider 호출을 가로채는 플랫폼 구현체.
class TestPathProviderPlatform extends PathProviderPlatform {
  final Directory _tempDir;

  TestPathProviderPlatform(this._tempDir);

  static Future<TestPathProviderPlatform> create() async {
    final dir = await Directory.systemTemp.createTemp('literacy_test');
    return TestPathProviderPlatform(dir);
  }

  @override
  Future<String?> getTemporaryPath() async => _tempDir.path;

  @override
  Future<String?> getApplicationSupportPath() async => _tempDir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir.path;

  @override
  Future<String?> getDownloadsPath() async => _tempDir.path;

  @override
  Future<String?> getExternalStoragePath() async => _tempDir.path;

  @override
  Future<List<String>?> getExternalCachePaths() async => [_tempDir.path];

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async =>
      [_tempDir.path];

  @override
  Future<String?> getLibraryPath() async => _tempDir.path;
}

