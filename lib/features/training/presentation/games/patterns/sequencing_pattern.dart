import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../../core/design/design_system.dart';
import '../../../data/models/training_content_model.dart';
import '../../widgets/feedback_widget.dart';

/// 시퀀싱 (순서 맞추기) 게임 패턴
/// 
/// 여러 아이템을 올바른 순서로 배열하는 게임입니다.
/// 드래그 앤 드롭 또는 순차 터치 방식을 지원합니다.
/// 
/// WP 2.2 - S 2.2.4
class SequencingPattern extends StatefulWidget {
  /// 문제 항목 (options를 순서대로 배열해야 함)
  final ContentItem item;
  
  /// 완료 콜백
  final void Function(bool isCorrect, int responseTimeMs) onComplete;
  
  /// 다음으로 이동 콜백
  final VoidCallback? onNext;
  
  /// 피드백 표시 여부
  final bool showFeedback;
  
  /// 게임 모드
  final SequencingMode mode;
  
  /// 문제 인덱스
  final int? questionIndex;
  
  /// 총 문제 수
  final int? totalQuestions;

  const SequencingPattern({
    super.key,
    required this.item,
    required this.onComplete,
    this.onNext,
    this.showFeedback = true,
    this.mode = SequencingMode.dragDrop,
    this.questionIndex,
    this.totalQuestions,
  });

  @override
  State<SequencingPattern> createState() => _SequencingPatternState();
}

/// 시퀀싱 게임 모드
enum SequencingMode {
  dragDrop,      // 드래그 앤 드롭
  sequentialTap, // 순차 터치
}

class _SequencingPatternState extends State<SequencingPattern>
    with TickerProviderStateMixin {
  DateTime? _startTime;
  
  // 드래그 앤 드롭 모드용
  late List<ContentOption> _currentOrder;
  late List<ContentOption> _correctOrder;
  
  // 순차 터치 모드용
  List<ContentOption> _selectedSequence = [];
  
  bool _completed = false;
  bool? _isCorrect;
  
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeGame();
  }
  
  @override
  void didUpdateWidget(SequencingPattern oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.itemId != widget.item.itemId) {
      setState(() {
        _startTime = DateTime.now();
        _completed = false;
        _isCorrect = null;
      });
      _initializeGame();
    }
  }
  
  void _initializeGame() {
    // 정답 순서 (optionData의 'order' 필드 기준으로 정렬)
    _correctOrder = List.from(widget.item.options);
    _correctOrder.sort((a, b) {
      final orderA = a.optionData?['order'] as int? ?? 0;
      final orderB = b.optionData?['order'] as int? ?? 0;
      return orderA.compareTo(orderB);
    });
    
    // 섞인 순서로 시작
    _currentOrder = List.from(widget.item.options);
    _currentOrder.shuffle();
    
    // 순차 터치 모드 초기화
    _selectedSequence = [];
    
    setState(() {});
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
    });
  }
  
  void _onSequentialTap(ContentOption option) {
    if (_selectedSequence.contains(option)) return;
    
    setState(() {
      _selectedSequence.add(option);
      
      // 모든 항목을 선택했으면 확인
      if (_selectedSequence.length == widget.item.options.length) {
        _checkSequentialAnswer();
      }
    });
  }
  
  void _checkSequentialAnswer() {
    final responseTime = DateTime.now().difference(_startTime!).inMilliseconds;
    
    // 선택한 순서가 정답 순서와 일치하는지 확인
    bool correct = true;
    for (int i = 0; i < _selectedSequence.length; i++) {
      if (_selectedSequence[i].optionId != _correctOrder[i].optionId) {
        correct = false;
        break;
      }
    }
    
    setState(() {
      _completed = true;
      _isCorrect = correct;
    });
    
    widget.onComplete(correct, responseTime);
    
    if (widget.showFeedback) {
      Timer(const Duration(seconds: 2), () {
        widget.onNext?.call();
      });
    } else {
      widget.onNext?.call();
    }
  }
  
  void _checkDragDropAnswer() {
    final responseTime = DateTime.now().difference(_startTime!).inMilliseconds;
    
    // 현재 순서가 정답 순서와 일치하는지 확인
    bool correct = true;
    for (int i = 0; i < _currentOrder.length; i++) {
      if (_currentOrder[i].optionId != _correctOrder[i].optionId) {
        correct = false;
        break;
      }
    }
    
    setState(() {
      _completed = true;
      _isCorrect = correct;
    });
    
    widget.onComplete(correct, responseTime);
    
    if (widget.showFeedback) {
      Timer(const Duration(seconds: 2), () {
        widget.onNext?.call();
      });
    } else {
      widget.onNext?.call();
    }
  }
  
  void _resetSequentialSelection() {
    setState(() {
      _selectedSequence = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // 진행 상황 표시
            if (widget.questionIndex != null && widget.totalQuestions != null)
              _buildProgressIndicator(),
            
            const SizedBox(height: 20),
            
            // 질문
            _buildQuestionArea(),
            
            const SizedBox(height: 24),
            
            // 게임 영역
            Expanded(
              child: widget.mode == SequencingMode.dragDrop
                  ? _buildDragDropGame()
                  : _buildSequentialTapGame(),
            ),
            
            // 확인 버튼 (드래그 앤 드롭 모드)
            if (widget.mode == SequencingMode.dragDrop && !_completed)
              _buildSubmitButton(),
            
            // 초기화 버튼 (순차 터치 모드)
            if (widget.mode == SequencingMode.sequentialTap && 
                _selectedSequence.isNotEmpty && 
                !_completed)
              _buildResetButton(),
            
            const SizedBox(height: 20),
          ],
        ),
        
        // 피드백 오버레이
        if (_completed && widget.showFeedback && _isCorrect != null)
          FeedbackWidget(
            type: _isCorrect! ? FeedbackType.correct : FeedbackType.incorrect,
            message: _isCorrect! 
                ? FeedbackMessages.getRandomCorrectMessage()
                : FeedbackMessages.getRandomIncorrectMessage(),
          ),
      ],
    );
  }
  
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            '${widget.questionIndex! + 1} / ${widget.totalQuestions}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (widget.questionIndex! + 1) / widget.totalQuestions!,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DesignSystem.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignSystem.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.item.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.mode == SequencingMode.dragDrop
                ? '순서를 맞춰서 정렬해주세요'
                : '순서대로 눌러주세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDragDropGame() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: _onReorder,
        itemCount: _currentOrder.length,
        itemBuilder: (context, index) {
          return _buildDragItem(_currentOrder[index], index);
        },
      ),
    );
  }
  
  Widget _buildDragItem(ContentOption option, int index) {
    return Container(
      key: ValueKey(option.optionId),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 순서 번호
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 이미지
              if (option.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    option.imagePath!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
              
              if (option.imagePath != null) const SizedBox(width: 16),
              
              // 텍스트
              Expanded(
                child: Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // 드래그 핸들
              const Icon(
                Icons.drag_handle,
                color: Colors.grey,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSequentialTapGame() {
    // 이미 선택한 순서 표시
    return Column(
      children: [
        // 선택된 순서 표시
        if (_selectedSequence.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSequence.asMap().entries.map((entry) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: DesignSystem.primaryBlue,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  label: Text(entry.value.label),
                  backgroundColor: Colors.white,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // 선택 가능한 항목들
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.item.options.length <= 4 ? 2 : 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: widget.item.options.length,
              itemBuilder: (context, index) {
                return _buildTapItem(widget.item.options[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTapItem(ContentOption option) {
    final isSelected = _selectedSequence.contains(option);
    final selectedIndex = _selectedSequence.indexOf(option);
    
    return GestureDetector(
      onTap: isSelected ? null : () => _onSequentialTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primaryBlue.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? DesignSystem.primaryBlue
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // 콘텐츠
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (option.imagePath != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          option.imagePath!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? DesignSystem.primaryBlue
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // 선택 번호 표시
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${selectedIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _checkDragDropAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '확인',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextButton(
        onPressed: _resetSequentialSelection,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 20),
            const SizedBox(width: 8),
            Text(
              '다시 선택하기',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

