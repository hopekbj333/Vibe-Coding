/// 구독 상태 관리 위젯
/// S 3.7.6: 구독 상태 관리

import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/payment_models.dart';

class SubscriptionStatusWidget extends StatelessWidget {
  final SubscriptionInfo subscription;
  final String? productName;
  final int remainingTickets;
  final VoidCallback? onManage;
  final VoidCallback? onCancel;

  const SubscriptionStatusWidget({
    super.key,
    required this.subscription,
    this.productName,
    this.remainingTickets = 0,
    this.onManage,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: subscription.isActive
                    ? [DesignSystem.primaryBlue, DesignSystem.primaryBlue.withOpacity(0.8)]
                    : [Colors.grey.shade400, Colors.grey.shade500],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.isTrial ? '🎁' : '📚',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName ?? (subscription.isTrial ? '무료 체험' : '구독'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 상세 정보
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 갱신일
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: subscription.status == SubscriptionStatus.cancelled
                      ? '종료 예정일'
                      : '다음 갱신일',
                  value: subscription.nextRenewalDate != null
                      ? _formatDate(subscription.nextRenewalDate!)
                      : subscription.endDate != null
                          ? _formatDate(subscription.endDate!)
                          : '-',
                ),
                
                const Divider(height: 24),
                
                // 잔여 검사권
                _buildInfoRow(
                  icon: Icons.confirmation_number,
                  label: '남은 검사권',
                  value: '$remainingTickets회',
                  valueColor: remainingTickets > 0
                      ? DesignSystem.primaryBlue
                      : Colors.grey,
                ),
                
                if (subscription.status == SubscriptionStatus.cancelled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '해지 예약됨 - 만료일까지 이용 가능',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 액션 버튼들
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '구독 변경',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: subscription.status == SubscriptionStatus.cancelled
                      ? ElevatedButton(
                          onPressed: onCancel, // 재개 동작
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '구독 재개',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      : TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '해지하기',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.trial:
        return Colors.purple;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.red;
      case SubscriptionStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return '✅ 활성';
      case SubscriptionStatus.trial:
        return '🎁 체험 중';
      case SubscriptionStatus.paused:
        return '⏸️ 일시중단';
      case SubscriptionStatus.cancelled:
        return '🚫 해지 예정';
      case SubscriptionStatus.expired:
        return '⏰ 만료됨';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// 해지 확인 다이얼로그
class CancelSubscriptionDialog extends StatefulWidget {
  final SubscriptionInfo subscription;
  final int remainingDays;
  final Function(String reason)? onConfirm;

  const CancelSubscriptionDialog({
    super.key,
    required this.subscription,
    required this.remainingDays,
    this.onConfirm,
  });

  @override
  State<CancelSubscriptionDialog> createState() => _CancelSubscriptionDialogState();
}

class _CancelSubscriptionDialogState extends State<CancelSubscriptionDialog> {
  String? _selectedReason;
  final _otherController = TextEditingController();

  final List<String> _reasons = [
    '가격이 부담됩니다',
    '아이가 사용하지 않습니다',
    '다른 서비스를 이용합니다',
    '콘텐츠가 만족스럽지 않습니다',
    '기타',
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '😢',
                style: TextStyle(fontSize: 48),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                '정말 해지하시겠어요?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoItem(
                      '남은 기간',
                      '${widget.remainingDays}일',
                    ),
                    const Divider(),
                    _buildInfoItem(
                      '학습 데이터',
                      '유지됩니다',
                    ),
                    const Divider(),
                    _buildInfoItem(
                      '재구독',
                      '언제든 가능',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '해지 사유를 선택해주세요',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              ...List.generate(_reasons.length, (index) {
                final reason = _reasons[index];
                return RadioListTile<String>(
                  title: Text(
                    reason,
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
              
              if (_selectedReason == '기타') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _otherController,
                  decoration: InputDecoration(
                    hintText: '사유를 입력해주세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                ),
              ],
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedReason == null
                          ? null
                          : () {
                              final reason = _selectedReason == '기타'
                                  ? _otherController.text.isNotEmpty
                                      ? _otherController.text
                                      : '기타'
                                  : _selectedReason!;
                              widget.onConfirm?.call(reason);
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('해지 진행'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

