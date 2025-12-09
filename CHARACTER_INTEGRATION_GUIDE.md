# 🎨 캐릭터 이미지 통합 가이드

**작성일**: 2025-12-05  
**목적**: Placeholder를 실제 캐릭터 이미지로 교체

---

## ✅ 완료된 작업

- [x] 캐릭터 5종 제작 완료
- [x] `assets/characters/` 폴더에 저장 완료
- [x] `pubspec.yaml`에 경로 등록 완료

---

## 📂 현재 상태

### 캐릭터 파일 위치
```
c:\dev\literacy-assessment\assets\characters\
├── character_excited.png   (🤩 신남 - 레벨업)
├── character_happy.png     (😊 기쁨 - 정답)
├── character_neutral.png   (😐 중립 - 기본)
├── character_sad.png       (😢 슬픔 - 오답)
└── character_thinking.png  (🤔 생각 - 문제 제시)
```

### 코드에서 사용되는 곳

1. **`asset_loader_service.dart`** (75-77줄)
   - 캐릭터 이미지 프리로드
   - 앱 시작 시 캐시에 저장

2. **`asset_utils.dart`** (25-32줄)
   - 캐릭터 경로 헬퍼 함수

3. **`feedback_widget.dart`**
   - 정답/오답 피드백 시 캐릭터 표시

---

## 🔄 교체 방법

### 방법 1: Image.asset() 직접 사용 (간단)

#### Before (Placeholder)
```dart
import 'package:literacy_assessment/core/widgets/placeholder_image_widget.dart';

CharacterPlaceholder(
  emotion: CharacterEmotion.happy,
  size: 200,
)
```

#### After (실제 이미지)
```dart
Image.asset(
  'assets/characters/character_happy.png',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
)
```

---

### 방법 2: AssetUtils 헬퍼 사용 (권장)

#### Before (Placeholder)
```dart
CharacterPlaceholder(
  emotion: CharacterEmotion.thinking,
  size: 150,
)
```

#### After (헬퍼 사용)
```dart
import 'package:literacy_assessment/core/assets/asset_utils.dart';

Image.asset(
  AssetUtils.characterPath('character_thinking.png'),
  width: 150,
  height: 150,
  fit: BoxFit.contain,
)
```

---

### 방법 3: 캐릭터 헬퍼 위젯 만들기 (가장 권장!)

**새 파일 생성**: `lib/core/widgets/character_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:literacy_assessment/core/assets/asset_utils.dart';

/// 캐릭터 감정 타입
enum CharacterEmotion {
  happy,        // 기쁨 - 정답
  neutral,      // 중립 - 기본
  thinking,     // 생각 - 문제 제시
  sad,          // 슬픔 - 오답 (격려)
  excited,      // 신남 - 레벨업
}

/// 캐릭터 위젯
/// 
/// 감정에 따라 적절한 캐릭터 이미지를 표시합니다.
class CharacterWidget extends StatelessWidget {
  final CharacterEmotion emotion;
  final double? size;
  final BoxFit fit;

  const CharacterWidget({
    super.key,
    required this.emotion,
    this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = _getImagePath(emotion);
    
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 Placeholder 표시
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getEmotionIcon(emotion),
            size: (size ?? 100) * 0.4,
            color: Colors.grey[400],
          ),
        );
      },
    );
  }

  /// 감정에 따른 이미지 경로 반환
  String _getImagePath(CharacterEmotion emotion) {
    final fileName = switch (emotion) {
      CharacterEmotion.happy => 'character_happy.png',
      CharacterEmotion.neutral => 'character_neutral.png',
      CharacterEmotion.thinking => 'character_thinking.png',
      CharacterEmotion.sad => 'character_sad.png',
      CharacterEmotion.excited => 'character_excited.png',
    };
    
    return AssetUtils.characterPath(fileName);
  }

  /// 감정에 따른 대체 아이콘 (에러 시)
  IconData _getEmotionIcon(CharacterEmotion emotion) {
    return switch (emotion) {
      CharacterEmotion.happy => Icons.sentiment_satisfied_alt,
      CharacterEmotion.neutral => Icons.sentiment_neutral,
      CharacterEmotion.thinking => Icons.psychology,
      CharacterEmotion.sad => Icons.sentiment_dissatisfied,
      CharacterEmotion.excited => Icons.celebration,
    };
  }
}
```

#### 사용 예시

```dart
// Before
CharacterPlaceholder(
  emotion: CharacterEmotion.happy,
  size: 200,
)

// After
CharacterWidget(
  emotion: CharacterEmotion.happy,
  size: 200,
)
```

**장점:**
- ✅ 간결한 코드
- ✅ 에러 처리 내장
- ✅ 일관된 사용법
- ✅ 나중에 애니메이션 추가 가능

---

## 📝 실제 코드 수정 예시

### 1. feedback_widget.dart 수정

#### 파일 위치
`lib/features/training/presentation/widgets/feedback_widget.dart`

#### Before
```dart
// Placeholder 사용 중
CharacterPlaceholder(
  emotion: isCorrect ? CharacterEmotion.happy : CharacterEmotion.sad,
  size: 200,
)
```

#### After
```dart
import 'package:literacy_assessment/core/widgets/character_widget.dart';

CharacterWidget(
  emotion: isCorrect ? CharacterEmotion.happy : CharacterEmotion.sad,
  size: 200,
)
```

---

### 2. 게임 화면에서 사용

#### 문제 제시 시
```dart
Column(
  children: [
    // 캐릭터 (생각하는 표정)
    CharacterWidget(
      emotion: CharacterEmotion.thinking,
      size: 150,
    ),
    const SizedBox(height: 24),
    // 질문 텍스트 (음성으로 대체 가능)
    const Text(
      '어떤 동물이 "야옹" 소리를 낼까?',
      style: TextStyle(fontSize: 24),
    ),
  ],
)
```

#### 정답 시
```dart
CharacterWidget(
  emotion: CharacterEmotion.happy,
  size: 200,
)
```

#### 오답 시 (격려)
```dart
CharacterWidget(
  emotion: CharacterEmotion.sad,
  size: 200,
)
```

#### 레벨업 시
```dart
CharacterWidget(
  emotion: CharacterEmotion.excited,
  size: 250,
)
```

---

## 🎯 단계별 적용 가이드

### Step 1: CharacterWidget 만들기 (5분)

1. 파일 생성: `lib/core/widgets/character_widget.dart`
2. 위의 코드 복사-붙여넣기
3. 저장

### Step 2: 기존 Placeholder 찾기 (2분)

```bash
# 터미널에서 검색
cd c:\dev\literacy-assessment
grep -r "CharacterPlaceholder" lib/
```

또는 VS Code에서:
- `Ctrl+Shift+F` (전체 검색)
- 검색어: `CharacterPlaceholder`

### Step 3: 하나씩 교체 (10분)

**파일별 우선순위:**

1. ⭐⭐⭐ `feedback_widget.dart` (정답/오답 피드백)
2. ⭐⭐ 게임 화면들 (문제 제시)
3. ⭐ 예시 파일 (`placeholder_example.dart` - 참고용이므로 선택사항)

### Step 4: 테스트 (5분)

1. 앱 실행
2. 게임 시작
3. 캐릭터 이미지 표시 확인
4. 정답/오답 시 캐릭터 변경 확인

---

## 🆘 문제 해결

### Q1: 이미지가 안 보여요
**A**: 
```bash
# Flutter 재시작
flutter clean
flutter pub get
flutter run
```

### Q2: 이미지가 깨져 보여요
**A**: 
- `fit: BoxFit.contain` 사용
- 크기 조절: `width`와 `height` 동일하게

### Q3: 특정 감정 이미지만 안 보여요
**A**: 
- 파일명 확인 (대소문자 구분)
- 파일 존재 확인: `assets/characters/` 폴더

---

## 💡 추가 팁

### 애니메이션 추가 (선택사항)

```dart
class CharacterWidget extends StatelessWidget {
  // ... 기존 코드 ...

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Image.asset(
        _getImagePath(emotion),
        key: ValueKey(emotion), // 감정 변경 시 애니메이션
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}
```

### 크기 프리셋

```dart
class CharacterWidget extends StatelessWidget {
  // ... 기존 코드 ...
  
  /// 크기 프리셋
  static const double sizeSmall = 100;
  static const double sizeMedium = 150;
  static const double sizeLarge = 200;
  static const double sizeXLarge = 250;
}

// 사용
CharacterWidget(
  emotion: CharacterEmotion.happy,
  size: CharacterWidget.sizeLarge,
)
```

---

## ✅ 체크리스트

### 코드 통합
- [ ] `character_widget.dart` 파일 생성
- [ ] `feedback_widget.dart`에 적용
- [ ] 게임 화면들에 적용
- [ ] 테스트 실행

### 테스트
- [ ] 앱 실행 확인
- [ ] 모든 감정 표시 확인
- [ ] 정답 시 happy 표시 확인
- [ ] 오답 시 sad 표시 확인
- [ ] 레벨업 시 excited 표시 확인

### 정리
- [ ] Placeholder 관련 코드 제거 (선택사항)
- [ ] 주석 정리
- [ ] 코드 커밋

---

## 📊 영향 범위

| 파일 | 변경 사항 | 우선순위 |
|-----|----------|---------|
| `character_widget.dart` | 새로 생성 | ⭐⭐⭐ |
| `feedback_widget.dart` | Placeholder → CharacterWidget | ⭐⭐⭐ |
| 게임 화면들 | Placeholder → CharacterWidget | ⭐⭐ |
| `placeholder_example.dart` | 참고용 (수정 선택사항) | ⭐ |

---

## 🎯 예상 소요 시간

| 작업 | 소요 시간 |
|-----|----------|
| CharacterWidget 생성 | 5분 |
| feedback_widget 수정 | 3분 |
| 게임 화면 수정 (10개) | 10분 |
| 테스트 | 5분 |
| **총 예상 시간** | **20~25분** |

---

**작성일**: 2025-12-05  
**상태**: 작업 준비 완료  
**다음**: CharacterWidget 생성 후 적용 시작

