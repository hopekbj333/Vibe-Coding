/// 구독 상품 카드 위젯
/// S 3.7.4: 학습 구독 상품

import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import '../../data/models/payment_models.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback? onSubscribe;
  final bool isLoading;
  final bool isCurrentPlan;

  const SubscriptionCardWidget({
    super.key,
    required this.product,
    this.onSubscribe,
    this.isLoading = false,
    this.isCurrentPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    final isYearly = product.period == SubscriptionPeriod.yearly;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: product.isBestValue
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignSystem.primaryBlue,
                  DesignSystem.primaryBlue.withOpacity(0.8),
                ],
              )
            : null,
        color: product.isBestValue ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: product.isBestValue
                ? DesignSystem.primaryBlue.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품명
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: product.isBestValue
                            ? Colors.white.withOpacity(0.2)
                            : DesignSystem.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '📚',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: product.isBestValue
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        if (isCurrentPlan)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '현재 플랜',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // 가격
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (product.originalPrice != null) ...[
                      Text(
                        '₩${_formatPrice(product.originalPrice!)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: product.isBestValue
                              ? Colors.white54
                              : Colors.grey[400],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '₩${_formatPrice(product.price)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: product.isBestValue
                            ? Colors.white
                            : DesignSystem.primaryBlue,
                      ),
                    ),
                    Text(
                      isYearly ? '/년' : '/월',
                      style: TextStyle(
                        fontSize: 16,
                        color: product.isBestValue
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                if (isYearly && product.monthlyPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '= 월 ₩${_formatPrice(product.monthlyPrice!)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: product.isBestValue
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // 혜택 목록
                ...product.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: product.isBestValue
                              ? Colors.white.withOpacity(0.2)
                              : DesignSystem.semanticSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: product.isBestValue
                              ? Colors.white
                              : DesignSystem.semanticSuccess,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 15,
                            color: product.isBestValue
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 24),
                
                // 구독 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading || isCurrentPlan ? null : onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: product.isBestValue
                          ? Colors.white
                          : DesignSystem.primaryBlue,
                      foregroundColor: product.isBestValue
                          ? DesignSystem.primaryBlue
                          : Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                product.isBestValue
                                    ? DesignSystem.primaryBlue
                                    : Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            isCurrentPlan ? '현재 구독 중' : '구독하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // 베스트 배지
          if (product.isBestValue)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('👑', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text(
                      'BEST',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 할인율 배지
          if (product.discountPercent != null)
            Positioned(
              top: product.isBestValue ? 50 : 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${product.discountPercent}% 할인',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
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

