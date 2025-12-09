/// 결제 관련 Riverpod 프로바이더
/// WP 3.7: Payment & Subscription System

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/payment_models.dart';
import '../../domain/services/payment_service.dart';

/// 결제 서비스 프로바이더
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

/// 전체 상품 목록 프로바이더
final productsProvider = Provider<List<Product>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return service.getProducts();
});

/// 검사권 상품 목록 프로바이더
final ticketProductsProvider = Provider<List<Product>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return service.getTicketProducts();
});

/// 구독 상품 목록 프로바이더
final subscriptionProductsProvider = Provider<List<Product>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  return service.getSubscriptionProducts();
});

/// 현재 사용자 ID (실제로는 Auth에서 가져와야 함)
final currentUserIdProvider = Provider<String>((ref) {
  // TODO: 실제 인증 시스템에서 사용자 ID 가져오기
  return 'demo_user';
});

/// 구독 상태 프로바이더
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return SubscriptionNotifier(service, userId);
});

class SubscriptionState {
  final SubscriptionInfo? subscription;
  final bool isLoading;
  final String? error;

  SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionInfo? subscription,
    bool? isLoading,
    String? error,
  }) => SubscriptionState(
    subscription: subscription ?? this.subscription,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final PaymentService _service;
  final String _userId;

  SubscriptionNotifier(this._service, this._userId) : super(SubscriptionState()) {
    _loadSubscription();
  }

  void _loadSubscription() {
    final subscription = _service.getSubscription(_userId);
    state = state.copyWith(subscription: subscription);
  }

  Future<bool> cancelSubscription(String reason) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.cancelSubscription(_userId, reason);
    if (success) {
      _loadSubscription();
    }
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<bool> resumeSubscription() async {
    state = state.copyWith(isLoading: true);
    final success = await _service.resumeSubscription(_userId);
    if (success) {
      _loadSubscription();
    }
    state = state.copyWith(isLoading: false);
    return success;
  }

  void refresh() {
    _loadSubscription();
  }
}

/// 잔여 검사권 프로바이더
final remainingTicketsProvider = StateNotifierProvider<TicketsNotifier, int>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return TicketsNotifier(service, userId);
});

class TicketsNotifier extends StateNotifier<int> {
  final PaymentService _service;
  final String _userId;

  TicketsNotifier(this._service, this._userId) : super(0) {
    _loadTickets();
  }

  void _loadTickets() {
    state = _service.getRemainingTickets(_userId);
  }

  void refresh() {
    _loadTickets();
  }
}

/// 무료 체험 정보 프로바이더
final freeTrialProvider = StateNotifierProvider<FreeTrialNotifier, FreeTrialState>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return FreeTrialNotifier(service, userId);
});

class FreeTrialState {
  final FreeTrialInfo? info;
  final bool canStartTrial;
  final bool isLoading;

  FreeTrialState({
    this.info,
    this.canStartTrial = false,
    this.isLoading = false,
  });

  FreeTrialState copyWith({
    FreeTrialInfo? info,
    bool? canStartTrial,
    bool? isLoading,
  }) => FreeTrialState(
    info: info ?? this.info,
    canStartTrial: canStartTrial ?? this.canStartTrial,
    isLoading: isLoading ?? this.isLoading,
  );
}

class FreeTrialNotifier extends StateNotifier<FreeTrialState> {
  final PaymentService _service;
  final String _userId;

  FreeTrialNotifier(this._service, this._userId) : super(FreeTrialState()) {
    _loadInfo();
  }

  void _loadInfo() {
    final info = _service.getFreeTrialInfo(_userId);
    final canStart = _service.canStartFreeTrial(_userId);
    state = state.copyWith(info: info, canStartTrial: canStart);
  }

  Future<bool> startFreeTrial() async {
    state = state.copyWith(isLoading: true);
    final success = await _service.startFreeTrial(_userId);
    if (success) {
      _loadInfo();
    }
    state = state.copyWith(isLoading: false);
    return success;
  }

  void refresh() {
    _loadInfo();
  }
}

/// 구매 내역 프로바이더
final purchaseHistoryProvider = StateNotifierProvider<PurchaseHistoryNotifier, List<PurchaseRecord>>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PurchaseHistoryNotifier(service, userId);
});

class PurchaseHistoryNotifier extends StateNotifier<List<PurchaseRecord>> {
  final PaymentService _service;
  final String _userId;

  PurchaseHistoryNotifier(this._service, this._userId) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    state = _service.getPurchaseHistory(_userId);
  }

  void refresh() {
    _loadHistory();
  }
}

/// 구매 처리 프로바이더
final purchaseProvider = StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return PurchaseNotifier(service, userId, ref);
});

class PurchaseState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final PurchaseRecord? lastPurchase;

  PurchaseState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.lastPurchase,
  });

  PurchaseState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    PurchaseRecord? lastPurchase,
  }) => PurchaseState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    error: error,
    lastPurchase: lastPurchase ?? this.lastPurchase,
  );
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final PaymentService _service;
  final String _userId;
  final Ref _ref;

  PurchaseNotifier(this._service, this._userId, this._ref) : super(PurchaseState());

  Future<bool> purchase(String productId) async {
    state = PurchaseState(isLoading: true);
    
    final result = await _service.purchase(_userId, productId);
    
    if (result.success) {
      state = PurchaseState(
        isSuccess: true,
        lastPurchase: result.purchaseRecord,
      );
      
      // 관련 상태들 갱신
      _ref.read(remainingTicketsProvider.notifier).refresh();
      _ref.read(subscriptionProvider.notifier).refresh();
      _ref.read(purchaseHistoryProvider.notifier).refresh();
      
      return true;
    } else {
      state = PurchaseState(
        isSuccess: false,
        error: result.errorMessage,
      );
      return false;
    }
  }

  void reset() {
    state = PurchaseState();
  }
}

/// 학습 콘텐츠 접근 가능 여부
final canAccessLearningProvider = Provider<bool>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return service.canAccessLearning(userId);
});

/// 검사 가능 여부
final canDoAssessmentProvider = Provider<bool>((ref) {
  final service = ref.watch(paymentServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return service.canDoAssessment(userId);
});

