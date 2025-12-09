# 공통 UI 컴포넌트 가이드

이 디렉토리는 앱 전체에서 사용할 공통 UI 컴포넌트를 포함합니다.

## 목적

**왜 필요한가요?**
- 앱 전체에서 일관된 디자인 유지
- 아동 친화적 UX (큰 버튼, 명확한 색상, 느린 애니메이션)
- 개발 효율성 향상 (재사용 가능한 컴포넌트)

## 구조

```
lib/core/widgets/
├── child_friendly_button.dart          # 아동 친화적 버튼
├── child_friendly_dialog.dart        # 아동 친화적 다이얼로그
├── child_friendly_loading_indicator.dart # 아동 친화적 로딩 인디케이터
├── choice_button_layout.dart         # 선택 버튼 레이아웃
├── animation_utils.dart                # 애니메이션 유틸리티
├── placeholder_image_widget.dart     # Placeholder 이미지 위젯 (에셋 준비 전)
├── placeholder_example.dart          # Placeholder 사용 예시
└── README.md                          # 이 파일
```

## 사용 방법

### 1. 아동 친화적 버튼

```dart
import 'package:literacy_assessment/core/widgets/child_friendly_button.dart';

// 기본 버튼
ChildFriendlyButton(
  label: '확인',
  icon: Icons.check,
  onPressed: () {
    // 버튼 클릭 처리
  },
)

// O/X 버튼 (S 2.2.1)
Row(
  children: [
    Expanded(
      child: ChildFriendlyButton(
        label: 'O',
        type: ChildButtonType.success,
        icon: Icons.check_circle,
        onPressed: () {
          // 정답 처리
        },
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: ChildFriendlyButton(
        label: 'X',
        type: ChildButtonType.error,
        icon: Icons.cancel,
        onPressed: () {
          // 오답 처리
        },
      ),
    ),
  ],
)

// 이미지 버튼 (Zero-Text Interface)
ChildFriendlyButton(
  image: Image.asset('assets/images/apple.png'),
  onPressed: () {
    // 선택 처리
  },
)
```

### 2. 아동 친화적 다이얼로그

```dart
import 'package:literacy_assessment/core/widgets/child_friendly_dialog.dart';

// 확인 다이얼로그
DialogHelper.showConfirmDialog(
  context: context,
  title: '확인',
  content: '정말로 나가시겠습니까?',
  onConfirm: () {
    // 확인 처리
  },
);

// 알림 다이얼로그
DialogHelper.showAlertDialog(
  context: context,
  title: '완료',
  content: '검사가 완료되었습니다!',
  type: DialogType.success,
  icon: Icons.check_circle,
);

// 커스텀 다이얼로그
DialogHelper.showChildFriendlyDialog(
  context: context,
  image: Image.asset('assets/images/character.png'),
  confirmText: '시작',
  cancelText: '나중에',
  onConfirm: () {
    // 확인 처리
  },
);
```

### 3. 아동 친화적 로딩 인디케이터

```dart
import 'package:literacy_assessment/core/widgets/child_friendly_loading_indicator.dart';

// 기본 로딩 인디케이터
ChildFriendlyLoadingIndicator(
  message: '준비 중이에요...',
  showCharacterAnimation: true,
)

// 전체 화면 오버레이
Stack(
  children: [
    YourContent(),
    if (isLoading)
      ChildFriendlyLoadingOverlay(
        message: '로딩 중...',
      ),
  ],
)
```

### 4. 애니메이션 유틸리티

```dart
import 'package:literacy_assessment/core/widgets/animation_utils.dart';

// 페이드 인
AnimationUtils.fadeIn(
  child: YourWidget(),
)

// 슬라이드 인
AnimationUtils.slideInFromBottom(
  child: YourWidget(),
)

// 스케일 인
AnimationUtils.scaleIn(
  child: YourWidget(),
)

// 페이지 전환
Navigator.push(
  context,
  AnimationUtils.fadeRoute(
    page: NextPage(),
  ),
);
```

### 5. 캐릭터 위젯 (실제 이미지 사용)

> **✅ 캐릭터 이미지 완성!** 실제 캐릭터 5종이 준비되었습니다.
> `CharacterWidget`을 사용하여 감정에 따른 캐릭터를 표시할 수 있습니다.

```dart
import 'package:literacy_assessment/core/widgets/character_widget.dart';

// 정답 시 - 기쁜 캐릭터
CharacterWidget(
  emotion: CharacterEmotion.happy,
  size: 200,
)

// 문제 제시 시 - 생각하는 캐릭터
CharacterWidget(
  emotion: CharacterEmotion.thinking,
  size: 150,
)

// 오답 시 - 슬픈 캐릭터 (격려)
CharacterWidget(
  emotion: CharacterEmotion.sad,
  size: 150,
)

// 레벨업 시 - 신난 캐릭터
CharacterWidget(
  emotion: CharacterEmotion.excited,
  size: 250,
)

// 크기 프리셋 사용
CharacterWidget(
  emotion: CharacterEmotion.neutral,
  size: CharacterWidget.sizeLarge, // 200
)
```

**사용 가능한 캐릭터 감정:**
- `CharacterEmotion.happy` - 😊 기쁨 (정답 피드백)
- `CharacterEmotion.neutral` - 😐 중립 (기본 상태, 로딩)
- `CharacterEmotion.thinking` - 🤔 생각 (문제 제시)
- `CharacterEmotion.sad` - 😢 슬픔 (오답 피드백, 격려)
- `CharacterEmotion.excited` - 🤩 신남 (레벨업, 완료)

**크기 프리셋:**
- `CharacterWidget.sizeSmall` - 100
- `CharacterWidget.sizeMedium` - 150
- `CharacterWidget.sizeLarge` - 200
- `CharacterWidget.sizeXLarge` - 250

## 디자인 원칙

### 1. 아동 친화적 크기
- 버튼 최소 높이: 72px (아동 모드)
- 아이콘 최소 크기: 48px
- 터치 영역 최소 크기: 48x48px

### 2. 명확한 색상 구분
- 성공: 초록색 (`ChildButtonType.success`)
- 오류: 빨간색 (`ChildButtonType.error`)
- 경고: 노란색 (`ChildButtonType.warning`)
- 기본: 파란색 (`ChildButtonType.primary`)

### 3. 느린 애니메이션
- 모든 애니메이션: 1.5배 느리게 (300ms)
- 부드러운 커브: `Curves.easeInOut`
- 바운스 효과: `Curves.elasticOut`

### 4. Zero-Text Interface
- 텍스트 대신 이미지/아이콘 사용
- 부모 모드에서만 텍스트 표시
- 명확한 시각적 피드백

### 6. 선택 버튼 레이아웃

```dart
import 'package:literacy_assessment/core/widgets/choice_button_layout.dart';
import 'package:literacy_assessment/core/widgets/child_friendly_button.dart';

// 2개 선택지 (좌우 배치)
ChoiceButtonLayout(
  buttons: [
    ChildFriendlyButton(
      image: Image.asset('assets/images/apple.png'),
      onPressed: () {},
    ),
    ChildFriendlyButton(
      image: Image.asset('assets/images/banana.png'),
      onPressed: () {},
    ),
  ],
)

// 3개 선택지 (삼각형 배치)
ChoiceButtonLayout(
  buttons: [
    ChildFriendlyButton(image: Image.asset('assets/images/q1.png'), onPressed: () {}),
    ChildFriendlyButton(image: Image.asset('assets/images/q2.png'), onPressed: () {}),
    ChildFriendlyButton(image: Image.asset('assets/images/q3.png'), onPressed: () {}),
  ],
)

// 4개 선택지 (2x2 그리드)
ChoiceButtonLayout(
  buttons: [
    ChildFriendlyButton(image: Image.asset('assets/images/q1.png'), onPressed: () {}),
    ChildFriendlyButton(image: Image.asset('assets/images/q2.png'), onPressed: () {}),
    ChildFriendlyButton(image: Image.asset('assets/images/q3.png'), onPressed: () {}),
    ChildFriendlyButton(image: Image.asset('assets/images/q4.png'), onPressed: () {}),
  ],
)

// O/X 버튼 (S 2.2.1)
OXButtonLayout(
  onO: () {
    // 정답 처리
  },
  onX: () {
    // 오답 처리
  },
)
```

## 향후 확장

- [x] O/X 버튼 컴포넌트 (S 2.2.1) - `OXButtonLayout` 구현 완료
- [x] 이선다지 버튼 컴포넌트 (S 2.2.2) - `ChoiceButtonLayout` 구현 완료
- [ ] 짝 맞추기 컴포넌트 (S 2.2.3)
- [ ] 시퀀싱 컴포넌트 (S 2.2.4)

