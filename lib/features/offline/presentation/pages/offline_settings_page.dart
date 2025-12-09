import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../domain/services/cache_manager_service.dart';
import '../../domain/services/offline_sync_service.dart';
import '../../domain/services/performance_optimizer_service.dart';
import '../../domain/services/secure_storage_service.dart';
import '../widgets/cache_status_widget.dart';
import '../widgets/sync_status_widget.dart';

/// 오프라인 및 최적화 설정 페이지 (WP 3.8)
class OfflineSettingsPage extends StatefulWidget {
  const OfflineSettingsPage({super.key});

  @override
  State<OfflineSettingsPage> createState() => _OfflineSettingsPageState();
}

class _OfflineSettingsPageState extends State<OfflineSettingsPage> {
  final _cacheManager = CacheManagerService();
  final _syncService = OfflineSyncService();
  final _performanceOptimizer = PerformanceOptimizerService();
  final _secureStorage = SecureStorageService();

  bool _isInitialized = false;
  bool _isSyncing = false;
  Map<String, dynamic> _cacheStats = {};
  Map<String, dynamic> _syncStats = {};
  Map<String, dynamic> _performanceStats = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheManager.initialize();
    await _syncService.initialize();
    await _performanceOptimizer.initialize();

    _loadStats();

    setState(() {
      _isInitialized = true;
    });
  }

  void _loadStats() {
    setState(() {
      _cacheStats = _cacheManager.getCacheStats();
      _syncStats = _syncService.getSyncStats();
      _performanceStats = _performanceOptimizer.getPerformanceStats();
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: const Text('모든 캐시 데이터를 삭제하시겠습니까?\n다시 다운로드가 필요할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: DesignSystem.semanticError,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cacheManager.clearCache();
      _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ 캐시가 삭제되었습니다')),
        );
      }
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _syncService.syncAll();
      _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ 동기화가 완료되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 동기화 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Text(
          '모든 로컬 데이터를 삭제하시겠습니까?\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: DesignSystem.semanticError,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _secureStorage.deleteAll();
      await _cacheManager.clearCache();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ 모든 데이터가 삭제되었습니다')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('오프라인 및 최적화 설정'),
        backgroundColor: DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 캐시 상태 (S 3.8.1)
            CacheStatusWidget(
              cacheStats: _cacheStats,
              onClearCache: _clearCache,
            ),
            const SizedBox(height: 16),

            // 동기화 상태 (S 3.8.2, S 3.8.3)
            SyncStatusWidget(
              syncStats: _syncStats,
              onSync: _syncNow,
              isLoading: _isSyncing,
            ),
            const SizedBox(height: 16),

            // 성능 최적화 (S 3.8.4, S 3.8.5, S 3.8.6)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.speed,
                          color: DesignSystem.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '성능 최적화',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '기기 모드: ${_performanceStats['isLowMemoryDevice'] == true ? "저사양" : "일반"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이미지 품질: ${_performanceStats['imageQuality']}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '목표 FPS: ${_performanceStats['targetFPS']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 데이터 보안 (S 3.8.7, S 3.8.8)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: DesignSystem.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '데이터 보안',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🔐 민감 데이터 암호화 저장',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '🔐 앱 삭제 시 자동 완전 삭제',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteAllData,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('모든 데이터 삭제'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DesignSystem.semanticError,
                          side: const BorderSide(
                            color: DesignSystem.semanticError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignSystem.neutralGray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ 오프라인 모드',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Wi-Fi 연결 시 자동으로 콘텐츠를 다운로드합니다\n'
                    '• 오프라인에서도 다운로드된 게임을 플레이할 수 있습니다\n'
                    '• 학습 기록은 온라인 시 자동으로 동기화됩니다',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

