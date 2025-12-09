/// 결제/상품 메인 페이지
/// WP 3.7: Payment & Subscription System

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/payment_models.dart';
import '../providers/payment_providers.dart';
import '../widgets/ticket_card_widget.dart';
import '../widgets/subscription_card_widget.dart';
import '../widgets/free_trial_widget.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _purchasingProductId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProducts = ref.watch(ticketProductsProvider);
    final subscriptionProducts = ref.watch(subscriptionProductsProvider);
    final freeTrialState = ref.watch(freeTrialProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final remainingTickets = ref.watch(remainingTicketsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('상품 구매'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // 내 구독 바로가기
          if (subscriptionState.subscription != null)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/payment/subscription');
              },
              icon: const Icon(Icons.person_outline),
              tooltip: '내 구독',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignSystem.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: DesignSystem.primaryBlue,
          tabs: const [
            Tab(text: '검사권'),
            Tab(text: '학습 구독'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 현재 보유 현황
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: '🎫',
                    label: '보유 검사권',
                    value: '$remainingTickets회',
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[200],
                ),
                Expanded(
                  child: _buildStatusItem(
                    icon: '📚',
                    label: '구독 상태',
                    value: subscriptionState.subscription?.isActive == true
                        ? '활성'
                        : '미구독',
                    valueColor: subscriptionState.subscription?.isActive == true
                        ? DesignSystem.semanticSuccess
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // 무료 체험 배너 (신규 사용자)
          if (freeTrialState.canStartTrial)
            _buildFreeTrialBanner(freeTrialState),

          // 무료 체험 진행 중 배너
          if (freeTrialState.info?.isInTrial == true)
            FreeTrialActiveWidget(
              trialInfo: freeTrialState.info!,
              onSubscribe: () => _tabController.animateTo(1),
            ),

          // 탭 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 검사권 탭
                _buildTicketTab(ticketProducts),
                // 구독 탭
                _buildSubscriptionTab(
                  subscriptionProducts,
                  subscriptionState.subscription,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTrialBanner(FreeTrialState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showFreeTrialDialog(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade400,
                Colors.purple.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🎁', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '무료로 시작하세요!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '첫 검사 1회 + 학습 3일 무료',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTab(List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '검사권 구매',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '기초 문해력 검사를 진행할 수 있는 검사권입니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...products.map((product) => TicketCardWidget(
            product: product,
            isLoading: _purchasingProductId == product.id,
            onPurchase: () => _handlePurchase(product),
          )),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTab(
    List<Product> products,
    SubscriptionInfo? currentSubscription,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 구독',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '모든 학습 콘텐츠를 무제한으로 이용하세요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ...products.map((product) => SubscriptionCardWidget(
            product: product,
            isLoading: _purchasingProductId == product.id,
            isCurrentPlan: currentSubscription?.productId == product.id &&
                currentSubscription?.isActive == true,
            onSubscribe: () => _handlePurchase(product),
          )),
        ],
      ),
    );
  }

  void _showFreeTrialDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: FreeTrialStartWidget(
          onStartTrial: () async {
            Navigator.pop(context);
            await _handleStartFreeTrial();
          },
          isLoading: false,
        ),
      ),
    );
  }

  Future<void> _handleStartFreeTrial() async {
    final success = await ref.read(freeTrialProvider.notifier).startFreeTrial();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '🎉 무료 체험이 시작되었습니다!'
                : '무료 체험을 시작할 수 없습니다.',
          ),
          backgroundColor: success ? DesignSystem.semanticSuccess : Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePurchase(Product product) async {
    // 구매 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구매 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.name}을(를) 구매하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('결제 금액'),
                  Text(
                    '₩${_formatPrice(product.price)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DesignSystem.primaryBlue,
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
              backgroundColor: DesignSystem.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('구매하기'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _purchasingProductId = product.id;
    });

    final success = await ref.read(purchaseProvider.notifier).purchase(product.id);

    setState(() {
      _purchasingProductId = null;
    });

    if (mounted) {
      if (success) {
        _showPurchaseSuccessDialog(product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPurchaseSuccessDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              '구매 완료!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${product.name}이(가) 추가되었습니다.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignSystem.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

