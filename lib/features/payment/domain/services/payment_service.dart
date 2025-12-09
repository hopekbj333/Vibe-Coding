/// 결제 서비스
/// WP 3.7: Payment & Subscription System
/// 
/// 참고: 실제 인앱 결제 연동은 스토어 설정 후 구현
/// 현재는 시뮬레이션 모드로 UI/UX 흐름 테스트

import 'dart:async';
import '../../../payment/data/models/payment_models.dart';

class PaymentService {
  // 싱글톤
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // 시뮬레이션용 데이터 저장소
  final Map<String, SubscriptionInfo> _subscriptions = {};
  final Map<String, List<PurchaseRecord>> _purchases = {};
  final Map<String, FreeTrialInfo> _freeTrials = {};
  final Map<String, UserTickets> _userTickets = {};

  /// 사전 정의된 상품 목록
  List<Product> getProducts() {
    return [
      // 검사권 상품
      Product(
        id: 'ticket_1',
        name: '검사 1회권',
        description: '기초 문해력 검사 1회',
        type: ProductType.assessmentTicket,
        price: 9900,
        quantity: 1,
        benefits: ['기초 검사 1회', '상세 리포트 제공'],
      ),
      Product(
        id: 'ticket_5',
        name: '검사 5회권',
        description: '기초 문해력 검사 5회 패키지',
        type: ProductType.assessmentTicket,
        price: 39000,
        originalPrice: 49500,
        quantity: 5,
        benefits: ['기초 검사 5회', '상세 리포트 제공', '20% 할인'],
        isPopular: true,
      ),
      Product(
        id: 'ticket_10',
        name: '검사 10회권',
        description: '기초 문해력 검사 10회 패키지',
        type: ProductType.assessmentTicket,
        price: 69000,
        originalPrice: 99000,
        quantity: 10,
        benefits: ['기초 검사 10회', '상세 리포트 제공', '30% 할인'],
        isBestValue: true,
      ),
      // 구독 상품
      Product(
        id: 'sub_monthly',
        name: '월간 구독',
        description: '모든 학습 콘텐츠 무제한 이용',
        type: ProductType.subscription,
        price: 19900,
        period: SubscriptionPeriod.monthly,
        benefits: [
          '모든 학습 게임 무제한',
          '월 1회 미니 테스트',
          '성장 리포트',
        ],
      ),
      Product(
        id: 'sub_yearly',
        name: '연간 구독',
        description: '모든 학습 콘텐츠 무제한 + 검사권 2회 포함',
        type: ProductType.subscription,
        price: 159000,
        originalPrice: 238800,
        period: SubscriptionPeriod.yearly,
        benefits: [
          '모든 학습 게임 무제한',
          '무제한 미니 테스트',
          '성장 리포트',
          '검사권 2회 포함',
        ],
        isBestValue: true,
      ),
    ];
  }

  /// 검사권 상품만 가져오기
  List<Product> getTicketProducts() {
    return getProducts()
        .where((p) => p.type == ProductType.assessmentTicket)
        .toList();
  }

  /// 구독 상품만 가져오기
  List<Product> getSubscriptionProducts() {
    return getProducts()
        .where((p) => p.type == ProductType.subscription)
        .toList();
  }

  /// 상품 조회
  Product? getProduct(String productId) {
    try {
      return getProducts().firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// 구매 처리 (시뮬레이션)
  Future<PurchaseResult> purchase(String userId, String productId) async {
    // 시뮬레이션 딜레이
    await Future.delayed(const Duration(seconds: 1));

    final product = getProduct(productId);
    if (product == null) {
      return PurchaseResult(
        success: false,
        errorMessage: '상품을 찾을 수 없습니다.',
      );
    }

    // 구매 기록 생성
    final purchaseId = 'purchase_${DateTime.now().millisecondsSinceEpoch}';
    final purchase = PurchaseRecord(
      id: purchaseId,
      userId: userId,
      productId: productId,
      productName: product.name,
      productType: product.type,
      amount: product.price,
      status: PaymentStatus.completed,
      purchaseDate: DateTime.now(),
      transactionId: 'sim_txn_${DateTime.now().millisecondsSinceEpoch}',
    );

    // 구매 내역 저장
    _purchases[userId] ??= [];
    _purchases[userId]!.add(purchase);

    // 상품 유형에 따른 처리
    if (product.type == ProductType.assessmentTicket) {
      // 검사권 추가
      _addTickets(userId, product.quantity ?? 0);
    } else if (product.type == ProductType.subscription) {
      // 구독 활성화
      _activateSubscription(userId, product);
    }

    return PurchaseResult(
      success: true,
      purchaseRecord: purchase,
    );
  }

  /// 검사권 추가
  void _addTickets(String userId, int count) {
    final current = _userTickets[userId]?.remainingTickets ?? 0;
    _userTickets[userId] = UserTickets(
      userId: userId,
      remainingTickets: current + count,
      lastUpdated: DateTime.now(),
    );
  }

  /// 검사권 사용
  Future<bool> useTicket(String userId) async {
    final tickets = _userTickets[userId];
    if (tickets == null || tickets.remainingTickets <= 0) {
      // 무료 검사 확인
      final trial = _freeTrials[userId];
      if (trial != null && trial.canUseFreAssessment) {
        _freeTrials[userId] = trial.copyWith(hasUsedFreeAssessment: true);
        return true;
      }
      return false;
    }

    _userTickets[userId] = tickets.copyWith(
      remainingTickets: tickets.remainingTickets - 1,
      lastUpdated: DateTime.now(),
    );
    return true;
  }

  /// 구독 활성화
  void _activateSubscription(String userId, Product product) {
    final now = DateTime.now();
    final endDate = product.period == SubscriptionPeriod.yearly
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    final subscriptionId = 'sub_${DateTime.now().millisecondsSinceEpoch}';
    _subscriptions[userId] = SubscriptionInfo(
      id: subscriptionId,
      userId: userId,
      productId: product.id,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: endDate,
      nextRenewalDate: endDate,
      remainingTickets: product.period == SubscriptionPeriod.yearly ? 2 : 0,
    );
  }

  /// 구독 정보 조회
  SubscriptionInfo? getSubscription(String userId) {
    return _subscriptions[userId];
  }

  /// 구독 해지
  Future<bool> cancelSubscription(String userId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final subscription = _subscriptions[userId];
    if (subscription == null) return false;

    _subscriptions[userId] = subscription.copyWith(
      status: SubscriptionStatus.cancelled,
      cancelledDate: DateTime.now(),
      cancellationReason: reason,
    );
    return true;
  }

  /// 구독 재개
  Future<bool> resumeSubscription(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final subscription = _subscriptions[userId];
    if (subscription == null || 
        subscription.status != SubscriptionStatus.cancelled) {
      return false;
    }

    _subscriptions[userId] = subscription.copyWith(
      status: SubscriptionStatus.active,
      cancelledDate: null,
      cancellationReason: null,
    );
    return true;
  }

  /// 무료 체험 시작
  Future<bool> startFreeTrial(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final existing = _freeTrials[userId];
    if (existing != null && existing.hasUsedFreeTrial) {
      return false; // 이미 체험 사용함
    }

    final now = DateTime.now();
    _freeTrials[userId] = FreeTrialInfo(
      userId: userId,
      hasUsedFreeTrial: true,
      trialStartDate: now,
      trialEndDate: now.add(const Duration(days: 3)),
      hasUsedFreeAssessment: false,
    );

    // 체험용 구독 활성화
    final subscriptionId = 'trial_${DateTime.now().millisecondsSinceEpoch}';
    _subscriptions[userId] = SubscriptionInfo(
      id: subscriptionId,
      userId: userId,
      productId: 'trial',
      status: SubscriptionStatus.trial,
      startDate: now,
      endDate: now.add(const Duration(days: 3)),
    );

    return true;
  }

  /// 무료 체험 정보 조회
  FreeTrialInfo? getFreeTrialInfo(String userId) {
    return _freeTrials[userId];
  }

  /// 무료 체험 가능 여부
  bool canStartFreeTrial(String userId) {
    final existing = _freeTrials[userId];
    return existing == null || !existing.hasUsedFreeTrial;
  }

  /// 잔여 검사권 조회
  int getRemainingTickets(String userId) {
    return _userTickets[userId]?.remainingTickets ?? 0;
  }

  /// 구매 내역 조회
  List<PurchaseRecord> getPurchaseHistory(String userId) {
    return _purchases[userId] ?? [];
  }

  /// 환불 요청 (시뮬레이션)
  Future<bool> requestRefund(String userId, String purchaseId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));

    final purchases = _purchases[userId];
    if (purchases == null) return false;

    final index = purchases.indexWhere((p) => p.id == purchaseId);
    if (index == -1) return false;

    final purchase = purchases[index];
    if (!purchase.canRefund) return false;

    // 환불 처리
    purchases[index] = PurchaseRecord(
      id: purchase.id,
      userId: purchase.userId,
      productId: purchase.productId,
      productName: purchase.productName,
      productType: purchase.productType,
      amount: purchase.amount,
      status: PaymentStatus.refunded,
      purchaseDate: purchase.purchaseDate,
      transactionId: purchase.transactionId,
      refundDate: DateTime.now(),
      refundReason: reason,
    );

    // 상품 회수 (검사권의 경우)
    if (purchase.productType == ProductType.assessmentTicket) {
      final product = getProduct(purchase.productId);
      if (product != null) {
        final current = _userTickets[userId]?.remainingTickets ?? 0;
        final newCount = (current - (product.quantity ?? 0)).clamp(0, 9999);
        _userTickets[userId] = UserTickets(
          userId: userId,
          remainingTickets: newCount,
          lastUpdated: DateTime.now(),
        );
      }
    }

    return true;
  }

  /// 학습 콘텐츠 접근 가능 여부
  bool canAccessLearning(String userId) {
    final subscription = _subscriptions[userId];
    if (subscription != null && subscription.isActive) {
      return true;
    }
    final trial = _freeTrials[userId];
    return trial != null && trial.isInTrial;
  }

  /// 검사 가능 여부
  bool canDoAssessment(String userId) {
    // 무료 검사 가능 여부
    final trial = _freeTrials[userId];
    if (trial != null && trial.canUseFreAssessment) {
      return true;
    }
    // 잔여 검사권 확인
    final tickets = _userTickets[userId];
    if (tickets != null && tickets.remainingTickets > 0) {
      return true;
    }
    // 구독에 포함된 검사권 확인
    final subscription = _subscriptions[userId];
    if (subscription != null && subscription.remainingTickets > 0) {
      return true;
    }
    return false;
  }
}

/// 구매 결과
class PurchaseResult {
  final bool success;
  final PurchaseRecord? purchaseRecord;
  final String? errorMessage;

  PurchaseResult({
    required this.success,
    this.purchaseRecord,
    this.errorMessage,
  });
}

