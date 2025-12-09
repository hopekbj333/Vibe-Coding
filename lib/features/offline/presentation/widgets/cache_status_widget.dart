import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';

/// 캐시 상태 표시 위젯
class CacheStatusWidget extends StatelessWidget {
  final Map<String, dynamic> cacheStats;
  final VoidCallback onClearCache;

  const CacheStatusWidget({
    super.key,
    required this.cacheStats,
    required this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize = cacheStats['totalSize'] as int? ?? 0;
    final sizeMB = (totalSize / 1024 / 1024).toStringAsFixed(1);
    final count = cacheStats['totalCount'] as int? ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storage,
                  color: DesignSystem.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '캐시 저장소',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '총 크기: $sizeMB MB',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '파일 개수: $count개',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onClearCache,
                icon: const Icon(Icons.delete_outline),
                label: const Text('캐시 삭제'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.semanticError,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

