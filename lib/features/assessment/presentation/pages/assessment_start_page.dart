import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_system.dart';
import '../providers/assessment_session_provider.dart';
import 'assessment_player_page_v2.dart';

/// Assessment 시작 화면
class AssessmentStartPage extends ConsumerWidget {
  final String childId;
  final String childName;

  const AssessmentStartPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문해력 기초 검사'),
        backgroundColor: DesignSystem.childFriendlyPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아동 이름
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$childName님',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 검사 안내
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.quiz, size: 64, color: Colors.blue),
                    SizedBox(height: 16),
                    Text('📝 문해력 기초 검사', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text('• 총 50문항', style: TextStyle(fontSize: 18)),
                    Text('• 약 20~30분 소요', style: TextStyle(fontSize: 18)),
                    Text('• 천천히 편안하게 답해주세요', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 시작 버튼
              ElevatedButton(
                onPressed: () => _startAssessment(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, size: 32, color: Colors.white),
                    SizedBox(width: 12),
                    Text('검사 시작하기', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startAssessment(BuildContext context, WidgetRef ref) async {
    // 검사 세션 생성 및 시작
    await ref.read(currentAssessmentSessionProvider.notifier).startNewAssessment(childId);
    
    // 검사 화면으로 이동
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssessmentPlayerPageV2(
            childId: childId,
            childName: childName,
          ),
        ),
      );
    }
  }
}
