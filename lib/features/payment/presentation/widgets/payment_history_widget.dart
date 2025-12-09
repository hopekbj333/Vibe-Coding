/// 결제 내역 위젯
/// S 3.7.7: 영수증 및 내역

import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/payment_models.dart';

class PaymentHistoryWidget extends StatelessWidget {
  final List<PurchaseRecord> purchases;
  final Function(PurchaseRecord)? onViewReceipt;
  final Function(PurchaseRecord)? onSendEmail;
  final Function(PurchaseRecord)? onRefund;

  const PaymentHistoryWidget({
    super.key,
    required this.purchases,
    this.onViewReceipt,
    this.onSendEmail,
    this.onRefund,
  });

  @override
  Widget build(BuildContext context) {
    if (purchases.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return _buildPurchaseItem(context, purchase);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '결제 내역이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseItem(BuildContext context, PurchaseRecord purchase) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 및 상태
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(purchase.purchaseDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    _buildStatusBadge(purchase.status),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 상품 정보
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconBackgroundColor(purchase.productType),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        purchase.productType == ProductType.subscription
                            ? '📚'
                            : '🎫',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchase.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            purchase.productType == ProductType.subscription
                                ? '구독'
                                : '검사권',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₩${_formatPrice(purchase.amount)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: purchase.status == PaymentStatus.refunded
                                ? Colors.grey
                                : Colors.black87,
                            decoration: purchase.status == PaymentStatus.refunded
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (purchase.status == PaymentStatus.refunded)
                          const Text(
                            '환불됨',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                // 환불 정보
                if (purchase.refundDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatDate(purchase.refundDate!)} 환불 완료',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
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
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onViewReceipt?.call(purchase),
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text('영수증 보기'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onSendEmail?.call(purchase),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('이메일 발송'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (purchase.canRefund) ...[
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade200,
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => onRefund?.call(purchase),
                      icon: const Icon(Icons.undo, size: 18),
                      label: const Text('환불'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case PaymentStatus.completed:
        color = DesignSystem.semanticSuccess;
        text = '완료';
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        text = '처리 중';
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        text = '실패';
        break;
      case PaymentStatus.refunded:
        color = Colors.grey;
        text = '환불됨';
        break;
      case PaymentStatus.cancelled:
        color = Colors.grey;
        text = '취소됨';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(ProductType type) {
    return type == ProductType.subscription
        ? DesignSystem.primaryBlue.withOpacity(0.1)
        : Colors.orange.withOpacity(0.1);
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// 영수증 상세 다이얼로그
class ReceiptDialog extends StatelessWidget {
  final PurchaseRecord purchase;
  final VoidCallback? onSendEmail;
  final VoidCallback? onClose;

  const ReceiptDialog({
    super.key,
    required this.purchase,
    this.onSendEmail,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: DesignSystem.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.receipt,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  '전자 영수증',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // 영수증 내용
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildReceiptRow('상품명', purchase.productName),
                _buildReceiptRow(
                  '결제일시',
                  _formatDateTime(purchase.purchaseDate),
                ),
                _buildReceiptRow(
                  '거래번호',
                  purchase.transactionId ?? '-',
                ),
                const Divider(height: 32),
                _buildReceiptRow(
                  '결제금액',
                  '₩${_formatPrice(purchase.amount)}',
                  isTotal: true,
                ),
                if (purchase.status == PaymentStatus.refunded) ...[
                  const SizedBox(height: 8),
                  _buildReceiptRow(
                    '환불일시',
                    _formatDateTime(purchase.refundDate!),
                    valueColor: Colors.red,
                  ),
                ],
              ],
            ),
          ),
          
          // 액션 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSendEmail,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('이메일 발송'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? (isTotal ? DesignSystem.primaryBlue : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

