/// 결제 및 구독 관련 데이터 모델
/// WP 3.7: Payment & Subscription System

/// 상품 유형
enum ProductType {
  /// 검사권 (일회성)
  assessmentTicket,
  /// 구독 (정기 결제)
  subscription,
}

/// 구독 기간 유형
enum SubscriptionPeriod {
  /// 월간
  monthly,
  /// 연간
  yearly,
}

/// 구독 상태
enum SubscriptionStatus {
  /// 활성
  active,
  /// 일시 중단 (결제 실패 등)
  paused,
  /// 해지됨
  cancelled,
  /// 만료됨
  expired,
  /// 체험 중
  trial,
}

/// 결제 상태
enum PaymentStatus {
  /// 대기 중
  pending,
  /// 완료
  completed,
  /// 실패
  failed,
  /// 환불됨
  refunded,
  /// 취소됨
  cancelled,
}

/// 상품 모델
class Product {
  final String id;
  final String name;
  final String description;
  final ProductType type;
  final int price; // 원 단위
  final int? originalPrice; // 할인 전 가격
  final int? quantity; // 검사권 개수 (검사권 상품의 경우)
  final SubscriptionPeriod? period; // 구독 기간 (구독 상품의 경우)
  final List<String> benefits; // 혜택 목록
  final bool isBestValue; // 베스트 상품 표시
  final bool isPopular; // 인기 상품 표시

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.originalPrice,
    this.quantity,
    this.period,
    this.benefits = const [],
    this.isBestValue = false,
    this.isPopular = false,
  });

  /// 할인율 계산
  int? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100).round();
  }

  /// 단가 계산 (검사권의 경우)
  int? get unitPrice {
    if (type != ProductType.assessmentTicket || quantity == null || quantity! <= 0) {
      return null;
    }
    return (price / quantity!).round();
  }

  /// 월 환산 가격 (연간 구독의 경우)
  int? get monthlyPrice {
    if (type != ProductType.subscription || period != SubscriptionPeriod.yearly) {
      return null;
    }
    return (price / 12).round();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'price': price,
    'originalPrice': originalPrice,
    'quantity': quantity,
    'period': period?.name,
    'benefits': benefits,
    'isBestValue': isBestValue,
    'isPopular': isPopular,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    type: ProductType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => ProductType.assessmentTicket,
    ),
    price: json['price'] ?? 0,
    originalPrice: json['originalPrice'],
    quantity: json['quantity'],
    period: json['period'] != null
        ? SubscriptionPeriod.values.firstWhere(
            (e) => e.name == json['period'],
            orElse: () => SubscriptionPeriod.monthly,
          )
        : null,
    benefits: List<String>.from(json['benefits'] ?? []),
    isBestValue: json['isBestValue'] ?? false,
    isPopular: json['isPopular'] ?? false,
  );
}

/// 구독 정보 모델
class SubscriptionInfo {
  final String id;
  final String userId;
  final String productId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextRenewalDate;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final int remainingTickets; // 포함된 검사권 잔여 개수

  SubscriptionInfo({
    required this.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.startDate,
    this.endDate,
    this.nextRenewalDate,
    this.cancelledDate,
    this.cancellationReason,
    this.remainingTickets = 0,
  });

  /// 활성 상태 여부
  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trial;

  /// 체험 중 여부
  bool get isTrial => status == SubscriptionStatus.trial;

  /// 남은 일수 계산
  int? get remainingDays {
    if (endDate == null) return null;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'productId': productId,
    'status': status.name,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'nextRenewalDate': nextRenewalDate?.toIso8601String(),
    'cancelledDate': cancelledDate?.toIso8601String(),
    'cancellationReason': cancellationReason,
    'remainingTickets': remainingTickets,
  };

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    productId: json['productId'] ?? '',
    status: SubscriptionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => SubscriptionStatus.expired,
    ),
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    nextRenewalDate: json['nextRenewalDate'] != null 
        ? DateTime.parse(json['nextRenewalDate']) 
        : null,
    cancelledDate: json['cancelledDate'] != null 
        ? DateTime.parse(json['cancelledDate']) 
        : null,
    cancellationReason: json['cancellationReason'],
    remainingTickets: json['remainingTickets'] ?? 0,
  );

  SubscriptionInfo copyWith({
    String? id,
    String? userId,
    String? productId,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextRenewalDate,
    DateTime? cancelledDate,
    String? cancellationReason,
    int? remainingTickets,
  }) => SubscriptionInfo(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    productId: productId ?? this.productId,
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
    cancelledDate: cancelledDate ?? this.cancelledDate,
    cancellationReason: cancellationReason ?? this.cancellationReason,
    remainingTickets: remainingTickets ?? this.remainingTickets,
  );
}

/// 구매 내역 모델
class PurchaseRecord {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final ProductType productType;
  final int amount;
  final PaymentStatus status;
  final DateTime purchaseDate;
  final String? transactionId; // 스토어 거래 ID
  final String? receiptData; // 영수증 데이터
  final DateTime? refundDate;
  final String? refundReason;

  PurchaseRecord({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productType,
    required this.amount,
    required this.status,
    required this.purchaseDate,
    this.transactionId,
    this.receiptData,
    this.refundDate,
    this.refundReason,
  });

  /// 환불 가능 여부 (7일 이내)
  bool get canRefund {
    if (status != PaymentStatus.completed) return false;
    final daysSincePurchase = DateTime.now().difference(purchaseDate).inDays;
    return daysSincePurchase <= 7;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'productId': productId,
    'productName': productName,
    'productType': productType.name,
    'amount': amount,
    'status': status.name,
    'purchaseDate': purchaseDate.toIso8601String(),
    'transactionId': transactionId,
    'receiptData': receiptData,
    'refundDate': refundDate?.toIso8601String(),
    'refundReason': refundReason,
  };

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    productId: json['productId'] ?? '',
    productName: json['productName'] ?? '',
    productType: ProductType.values.firstWhere(
      (e) => e.name == json['productType'],
      orElse: () => ProductType.assessmentTicket,
    ),
    amount: json['amount'] ?? 0,
    status: PaymentStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => PaymentStatus.pending,
    ),
    purchaseDate: DateTime.parse(json['purchaseDate']),
    transactionId: json['transactionId'],
    receiptData: json['receiptData'],
    refundDate: json['refundDate'] != null 
        ? DateTime.parse(json['refundDate']) 
        : null,
    refundReason: json['refundReason'],
  );
}

/// 무료 체험 정보 모델
class FreeTrialInfo {
  final String userId;
  final bool hasUsedFreeTrial;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final bool hasUsedFreeAssessment;

  FreeTrialInfo({
    required this.userId,
    this.hasUsedFreeTrial = false,
    this.trialStartDate,
    this.trialEndDate,
    this.hasUsedFreeAssessment = false,
  });

  /// 체험 중 여부
  bool get isInTrial {
    if (!hasUsedFreeTrial || trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  /// 체험 남은 일수
  int get trialRemainingDays {
    if (trialEndDate == null) return 0;
    final diff = trialEndDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// 무료 체험 가능 여부
  bool get canStartTrial => !hasUsedFreeTrial;

  /// 무료 검사 가능 여부
  bool get canUseFreAssessment => !hasUsedFreeAssessment;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'hasUsedFreeTrial': hasUsedFreeTrial,
    'trialStartDate': trialStartDate?.toIso8601String(),
    'trialEndDate': trialEndDate?.toIso8601String(),
    'hasUsedFreeAssessment': hasUsedFreeAssessment,
  };

  factory FreeTrialInfo.fromJson(Map<String, dynamic> json) => FreeTrialInfo(
    userId: json['userId'] ?? '',
    hasUsedFreeTrial: json['hasUsedFreeTrial'] ?? false,
    trialStartDate: json['trialStartDate'] != null 
        ? DateTime.parse(json['trialStartDate']) 
        : null,
    trialEndDate: json['trialEndDate'] != null 
        ? DateTime.parse(json['trialEndDate']) 
        : null,
    hasUsedFreeAssessment: json['hasUsedFreeAssessment'] ?? false,
  );

  FreeTrialInfo copyWith({
    String? userId,
    bool? hasUsedFreeTrial,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    bool? hasUsedFreeAssessment,
  }) => FreeTrialInfo(
    userId: userId ?? this.userId,
    hasUsedFreeTrial: hasUsedFreeTrial ?? this.hasUsedFreeTrial,
    trialStartDate: trialStartDate ?? this.trialStartDate,
    trialEndDate: trialEndDate ?? this.trialEndDate,
    hasUsedFreeAssessment: hasUsedFreeAssessment ?? this.hasUsedFreeAssessment,
  );
}

/// 사용자 잔여 검사권 모델
class UserTickets {
  final String userId;
  final int remainingTickets;
  final DateTime? lastUpdated;

  UserTickets({
    required this.userId,
    required this.remainingTickets,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'remainingTickets': remainingTickets,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  factory UserTickets.fromJson(Map<String, dynamic> json) => UserTickets(
    userId: json['userId'] ?? '',
    remainingTickets: json['remainingTickets'] ?? 0,
    lastUpdated: json['lastUpdated'] != null 
        ? DateTime.parse(json['lastUpdated']) 
        : null,
  );

  UserTickets copyWith({
    String? userId,
    int? remainingTickets,
    DateTime? lastUpdated,
  }) => UserTickets(
    userId: userId ?? this.userId,
    remainingTickets: remainingTickets ?? this.remainingTickets,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

