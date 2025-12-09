import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';

/// 동기화 상태 표시 위젯
class SyncStatusWidget extends StatelessWidget {
  final Map<String, dynamic> syncStats;
  final VoidCallback onSync;
  final bool isLoading;

  const SyncStatusWidget({
    super.key,
    required this.syncStats,
    required this.onSync,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final unsynced = syncStats['unsynced'] as int? ?? 0;
    final synced = syncStats['synced'] as int? ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  unsynced > 0 ? Icons.cloud_upload : Icons.cloud_done,
                  color: unsynced > 0
                      ? DesignSystem.semanticWarning
                      : DesignSystem.semanticSuccess,
                ),
                const SizedBox(width: 8),
                const Text(
                  '동기화 상태',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '동기화 완료: $synced개',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '동기화 대기: $unsynced개',
              style: TextStyle(
                fontSize: 16,
                color: unsynced > 0
                    ? DesignSystem.semanticWarning
                    : DesignSystem.neutralGray600,
              ),
            ),
            if (unsynced > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onSync,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.sync),
                  label: Text(isLoading ? '동기화 중...' : '지금 동기화'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

