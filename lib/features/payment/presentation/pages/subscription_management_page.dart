/// 구독 관리 페이지
/// S 3.7.6: 구독 상태 관리
/// S 3.7.7: 결제 내역

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/payment_models.dart';
import '../../domain/services/payment_service.dart';
import '../providers/payment_providers.dart';
import '../widgets/subscription_status_widget.dart';
import '../widgets/payment_history_widget.dart';

class SubscriptionManagementPage extends ConsumerWidget {
  const SubscriptionManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final remainingTickets = ref.watch(remainingTicketsProvider);
    final purchaseHistory = ref.watch(purchaseHistoryProvider);
    final service = ref.watch(paymentServiceProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('나의 구독'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 구독이 없는 경우
            if (subscriptionState.subscription == null)
              _buildNoSubscription(context),

            // 구독 상태 카드
            if (subscriptionState.subscription != null)
              SubscriptionStatusWidget(
                subscription: subscriptionState.subscription!,
                productName: _getProductName(
                  service,
                  subscriptionState.subscription!.productId,
                ),
                remainingTickets: remainingTickets +
                    subscriptionState.subscription!.remainingTickets,
                onManage: () {
                  Navigator.pushNamed(context, '/payment');
                },
                onCancel: () {
                  if (subscriptionState.subscription!.status ==
                      SubscriptionStatus.cancelled) {
                    _handleResumeSubscription(context, ref);
                  } else {
                    _showCancelDialog(context, ref, subscriptionState.subscription!);
                  }
                },
              ),

            // 결제 내역 섹션
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '결제 내역',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (purchaseHistory.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // 전체 내역 페이지로 이동 (필요시)
                      },
                      child: const Text('전체 보기'),
                    ),
                ],
              ),
            ),

            PaymentHistoryWidget(
              purchases: purchaseHistory,
              onViewReceipt: (purchase) => _showReceiptDialog(context, purchase),
              onSendEmail: (purchase) => _handleSendEmail(context, purchase),
              onRefund: (purchase) => _showRefundDialog(context, ref, purchase),
            ),

            const SizedBox(height: 32),

            // 고객 지원
            _buildSupportSection(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubscription(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '📭',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            '구독 중인 상품이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '구독하면 모든 학습 콘텐츠를\n무제한으로 이용할 수 있어요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/payment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '상품 둘러보기',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '고객 지원',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSupportItem(
            icon: Icons.help_outline,
            title: '자주 묻는 질문',
            onTap: () {
              // FAQ 페이지로 이동
            },
          ),
          _buildSupportItem(
            icon: Icons.email_outlined,
            title: '이메일 문의',
            subtitle: 'support@example.com',
            onTap: () {
              // 이메일 앱 열기
            },
          ),
          _buildSupportItem(
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: () {
              // 이용약관 페이지로 이동
            },
          ),
          _buildSupportItem(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            onTap: () {
              // 개인정보처리방침 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String? _getProductName(PaymentService service, String productId) {
    if (productId == 'trial') return '무료 체험';
    final product = service.getProduct(productId);
    return product?.name;
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    SubscriptionInfo subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => CancelSubscriptionDialog(
        subscription: subscription,
        remainingDays: subscription.remainingDays ?? 0,
        onConfirm: (reason) async {
          final success = await ref
              .read(subscriptionProvider.notifier)
              .cancelSubscription(reason);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success ? '구독이 해지 예약되었습니다.' : '해지에 실패했습니다.',
                ),
                backgroundColor:
                    success ? DesignSystem.semanticSuccess : Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleResumeSubscription(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 재개'),
        content: const Text('구독을 다시 활성화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryBlue,
            ),
            child: const Text('재개하기'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success =
          await ref.read(subscriptionProvider.notifier).resumeSubscription();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '구독이 재개되었습니다!' : '구독 재개에 실패했습니다.',
            ),
            backgroundColor: success ? DesignSystem.semanticSuccess : Colors.red,
          ),
        );
      }
    }
  }

  void _showReceiptDialog(BuildContext context, PurchaseRecord purchase) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDialog(
        purchase: purchase,
        onSendEmail: () {
          Navigator.pop(context);
          _handleSendEmail(context, purchase);
        },
      ),
    );
  }

  void _handleSendEmail(BuildContext context, PurchaseRecord purchase) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📧 영수증을 이메일로 발송했습니다.'),
        backgroundColor: DesignSystem.semanticSuccess,
      ),
    );
  }

  void _showRefundDialog(
    BuildContext context,
    WidgetRef ref,
    PurchaseRecord purchase,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('환불 요청'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${purchase.productName}의 환불을 요청하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
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
                      '환불은 7일 이내, 미사용 상품에 한해 가능합니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('환불 요청'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(paymentServiceProvider);
      final userId = ref.read(currentUserIdProvider);
      final success = await service.requestRefund(
        userId,
        purchase.id,
        '사용자 요청',
      );
      
      ref.read(purchaseHistoryProvider.notifier).refresh();
      ref.read(remainingTicketsProvider.notifier).refresh();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '환불이 완료되었습니다.' : '환불에 실패했습니다.',
            ),
            backgroundColor: success ? DesignSystem.semanticSuccess : Colors.red,
          ),
        );
      }
    }
  }
}

