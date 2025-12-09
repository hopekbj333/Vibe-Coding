import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/state/auth_providers.dart';
import '../../../../core/widgets/child_friendly_button.dart';
import '../../../../core/widgets/child_friendly_loading_indicator.dart';
import '../providers/child_providers.dart';

/// 아동 프로필 등록/수정 화면
/// 
/// 아동 프로필을 등록하거나 수정하는 화면입니다.
class ChildFormPage extends ConsumerStatefulWidget {
  final String? childId;

  const ChildFormPage({
    super.key,
    this.childId,
  });

  @override
  ConsumerState<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends ConsumerState<ChildFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.childId != null) {
      _loadChild();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadChild() async {
    try {
      final children = await ref.read(childrenListProvider.future);
      final child = children.firstWhere(
        (c) => c.id == widget.childId,
        orElse: () => throw Exception('Child not found'),
      );
      if (mounted) {
        setState(() {
          _nameController.text = child.name;
          _birthDate = child.birthDate;
          _gender = child.gender;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('아동 프로필을 불러오는데 실패했습니다: $e'),
            backgroundColor: DesignSystem.semanticError,
          ),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 10, 1, 1);
    final lastDate = DateTime(now.year, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 5, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ko', 'KR'),
      helpText: '생년월일 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요'),
          backgroundColor: DesignSystem.semanticError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = await ref.read(userModelProvider.future);

      if (userModel == null) {
        throw Exception('로그인이 필요합니다');
      }

      if (widget.childId == null) {
        // 새 아동 프로필 생성
        await ref.read(
          createChildProvider(
            CreateChildParams(
              parentId: userModel.uid,
              name: _nameController.text.trim(),
              birthDate: _birthDate!,
              gender: _gender,
            ),
          ).future,
        );
      } else {
        // 아동 프로필 수정
        final children = await ref.read(childrenListProvider.future);
        final child = children.firstWhere(
          (c) => c.id == widget.childId,
          orElse: () => throw Exception('Child not found'),
        );
        await ref.read(
          updateChildProvider(
            UpdateChildParams(
              child: child,
              name: _nameController.text.trim(),
              birthDate: _birthDate,
              gender: _gender,
            ),
          ).future,
        );
      }

      if (mounted) {
        // Provider 무효화하여 목록 새로고침
        ref.invalidate(childrenListProvider);
        // 화면 닫기
        context.pop();
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.childId == null
                  ? '아동 프로필이 등록되었습니다'
                  : '아동 프로필이 수정되었습니다',
            ),
            backgroundColor: DesignSystem.semanticSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $errorMessage'),
            backgroundColor: DesignSystem.semanticError,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.childId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '아동 프로필 수정' : '아동 프로필 등록'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: ChildFriendlyLoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DesignSystem.spacingMD),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 프로필 이미지 (향후 추가)
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: DesignSystem.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: DesignSystem.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 이름 입력
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        hintText: '아동의 이름을 입력하세요',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 생년월일 선택
                    InkWell(
                      onTap: _selectBirthDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '생년월일',
                          hintText: '생년월일을 선택하세요',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _birthDate != null
                              ? DateFormat('yyyy년 MM월 dd일').format(_birthDate!)
                              : '생년월일을 선택하세요',
                          style: TextStyle(
                            color: _birthDate != null
                                ? Colors.black
                                : DesignSystem.neutralGray500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacingMD),

                    // 성별 선택
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: '성별 (선택사항)',
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('선택하지 않음'),
                        ),
                        DropdownMenuItem(
                          value: 'male',
                          child: Text('남자'),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('여자'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    const SizedBox(height: DesignSystem.spacingLG),

                    // 제출 버튼
                    ChildFriendlyButton(
                      onPressed: _handleSubmit,
                      label: isEdit ? '수정하기' : '등록하기',
                      color: DesignSystem.primaryBlue,
                      icon: isEdit ? Icons.save : Icons.add,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

