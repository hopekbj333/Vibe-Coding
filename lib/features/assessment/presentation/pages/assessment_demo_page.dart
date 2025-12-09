import 'package:flutter/material.dart';
import '../../../../core/design/design_system.dart';
import 'assessment_start_page.dart';

/// Assessment 데모 페이지
/// 테스트용 임시 아동 정보로 검사 시작
class AssessmentDemoPage extends StatelessWidget {
  const AssessmentDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검사 데모'),
        backgroundColor: DesignSystem.childFriendlyPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.science,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                '🧪 검사 시스템 데모',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✨ 새로 구현된 기능:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('• Training 문항 샘플링 (50개 게임 → 각 1문항)', style: TextStyle(fontSize: 16)),
                    Text('• Assessment 세션 관리', style: TextStyle(fontSize: 16)),
                    Text('• 진행률 추적', style: TextStyle(fontSize: 16)),
                    Text('• 실시간 결과 계산', style: TextStyle(fontSize: 16)),
                    Text('• 분야별 통계', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AssessmentStartPage(
                        childId: 'demo-child-001',
                        childName: '테스트 아동',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      '데모 검사 시작',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
