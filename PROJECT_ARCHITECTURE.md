# 프로젝트 아키텍처

## 📋 개요

문해력 기초 검사 앱의 전체 아키텍처를 설명합니다.

**핵심 아키텍처:**
- **Feature-First**: 기능별 모듈화
- **Clean Architecture**: 레이어 분리
- **Riverpod**: 상태 관리
- **Firebase**: 백엔드 서비스
- **JSON + Firestore**: 문항 관리

---

## 🏗️ 시스템 구조

### 전체 레이어

```
┌─────────────────────────────────────────────────┐
│                Presentation                     │
│  (UI, Widgets, Pages, Providers)                │
├─────────────────────────────────────────────────┤
│                  Domain                         │
│  (Entities, UseCases, Repository Interface)     │
├─────────────────────────────────────────────────┤
│                   Data                          │
│  (Models, RepositoryImpl, DataSources)          │
├─────────────────────────────────────────────────┤
│              External Services                  │
│  (Firebase, Local Storage, Assets)              │
└─────────────────────────────────────────────────┘
```

---

## 📂 디렉토리 구조

```
lib/
├── config/                      # 앱 설정
│   ├── app_config.dart          # 환경 변수
│   └── routes/
│       └── app_router.dart      # GoRouter 라우팅
│
├── core/                        # 공통 모듈
│   ├── assets/                  # 에셋 매니저
│   ├── design/                  # 디자인 시스템
│   ├── state/                   # 전역 상태
│   ├── theme/                   # 테마
│   └── widgets/                 # 공통 위젯
│
└── features/                    # 기능별 모듈
    ├── splash/                  # 스플래시
    ├── auth/                    # 인증
    ├── home/                    # 홈
    ├── child/                   # 아동 관리
    ├── assessment/              # 검사
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── question_model.dart
    │   │   │   └── assessment_model.dart
    │   │   ├── repositories/
    │   │   └── services/
    │   ├── domain/
    │   │   ├── repositories/
    │   │   └── services/
    │   └── presentation/
    │       ├── pages/
    │       ├── widgets/
    │       └── providers/
    │
    └── training/                # 학습 (Milestone 2)
        ├── data/
        │   ├── models/
        │   │   ├── training_content_model.dart    ⭐ 문항 모델
        │   │   ├── game_session_model.dart
        │   │   └── learning_progress_model.dart
        │   ├── repositories/
        │   └── services/
        │       ├── question_loader_service.dart   ⭐ 문항 로더
        │       └── asset_loader_service.dart
        ├── domain/
        │   └── services/
        │       ├── difficulty_adjuster.dart
        │       └── progress_tracker.dart
        └── presentation/
            ├── games/              # Flame 게임
            ├── modules/            # 게임별 모듈
            │   ├── phonological/
            │   │   ├── same_sound_game_v2.dart      ⭐ JSON 기반
            │   │   └── ...
            │   ├── phonological3/
            │   │   ├── syllable_clap_game_v2.dart   ⭐ JSON 기반
            │   │   └── ...
            │   └── working_memory/
            │       ├── card_match_game_v2.dart      ⭐ JSON 기반
            │       └── ...
            ├── pages/
            └── widgets/

assets/
├── images/
├── audio/
├── characters/
└── questions/                   ⭐ 문항 데이터
    ├── training/                # 학습용 (로컬 JSON)
    │   ├── same_sound.json      ⭐ POC
    │   ├── syllable_clap.json   ⭐ POC
    │   └── card_match.json      ⭐ POC
    └── assessment/              # 검사용
        └── standard_questions.json
```

---

## 🎯 Feature 아키텍처

### Clean Architecture 적용

```
features/{feature_name}/
├── data/                       # 데이터 레이어
│   ├── models/                 # 데이터 모델 (DTO)
│   │   └── *_model.dart
│   ├── repositories/           # Repository 구현
│   │   └── *_repository_impl.dart
│   └── datasources/            # 데이터 소스
│       ├── local/              # 로컬 (JSON, Hive)
│       └── remote/             # 원격 (Firebase)
│
├── domain/                     # 도메인 레이어
│   ├── entities/               # 도메인 엔티티
│   │   └── *_entity.dart
│   ├── repositories/           # Repository 인터페이스
│   │   └── *_repository.dart
│   └── usecases/               # 비즈니스 로직
│       └── *_usecase.dart
│
└── presentation/               # 프레젠테이션 레이어
    ├── pages/                  # 화면 페이지
    │   └── *_page.dart
    ├── widgets/                # 재사용 위젯
    │   └── *_widget.dart
    └── providers/              # 상태 관리 (Riverpod)
        └── *_providers.dart
```

---

## 📊 문항 관리 시스템 (⭐ 신규)

### 아키텍처 다이어그램

```
┌────────────────────────────────────────────────────────┐
│                  제작 도구                              │
│  ┌──────────────────┐  ┌─────────────────────────┐    │
│  │ 구글 시트        │  │ Apps Script             │    │
│  │ - Content Info   │→ │ - exportToJSON()        │    │
│  │ - Items          │  │ - validateData()        │    │
│  │ - Options        │  │                         │    │
│  └──────────────────┘  └─────────────────────────┘    │
└────────────────┬───────────────────────────────────────┘
                 │ JSON 내보내기
                 ▼
┌────────────────────────────────────────────────────────┐
│                  저장소                                 │
│  ┌────────────────────┐  ┌──────────────────────────┐ │
│  │ 로컬 JSON          │  │ Firebase Firestore       │ │
│  │ assets/questions/  │  │ /training_contents       │ │
│  │ - 검사용 (50개)    │  │ - 학습용 (15,000개+)     │ │
│  │ - 빠른 로딩        │  │ - 확장 가능              │ │
│  └────────────────────┘  └──────────────────────────┘ │
└────────────────┬───────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────┐
│            QuestionLoaderService                       │
│  ┌──────────────────────────────────────────────────┐ │
│  │ - loadFromLocalJson()                            │ │
│  │ - loadFromFirebase()                             │ │
│  │ - loadByModule()                                 │ │
│  │ - loadByDifficultyRange()                        │ │
│  │ - loadHybrid() (로컬 우선 → Firebase 폴백)       │ │
│  └──────────────────────────────────────────────────┘ │
└────────────────┬───────────────────────────────────────┘
                 │ TrainingContentModel
                 ▼
┌────────────────────────────────────────────────────────┐
│                 게임 위젯 (V2)                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │ - SameSoundGameV2                                │ │
│  │ - SyllableClapGameV2                             │ │
│  │ - CardMatchGameV2                                │ │
│  │ ... (47개 게임)                                   │ │
│  └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

### 데이터 흐름

```
1. 제작자
   ↓ 구글 시트 작성
2. Apps Script
   ↓ JSON 변환
3. JSON 파일 또는 Firebase
   ↓ 로딩
4. QuestionLoaderService
   ↓ 파싱
5. TrainingContentModel
   ↓ 사용
6. 게임 위젯
   ↓ 렌더링
7. 아동 화면
```

---

## 🔄 상태 관리

### Riverpod Provider 패턴

```dart
// 1. Provider 정의
final questionLoaderServiceProvider = Provider<QuestionLoaderService>((ref) {
  return QuestionLoaderService();
});

// 2. FutureProvider로 비동기 데이터
final sameSoundQuestionsProvider = FutureProvider<TrainingContentModel>((ref) async {
  final service = ref.read(questionLoaderServiceProvider);
  return await service.loadFromLocalJson('same_sound.json');
});

// 3. 위젯에서 사용
class SameSoundGameV2 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(sameSoundQuestionsProvider);
    
    return questionsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
      data: (content) => GameScreen(content: content),
    );
  }
}
```

---

## 🔥 Firebase 구조

### Firestore 컬렉션

```
/training_contents/{contentId}
├── contentId: string
├── moduleId: string
├── type: string
├── pattern: string
├── items: array
└── difficulty: object

/user_progress/{childId}
├── childId: string
├── modules: map
└── totalStats: object

/learning_sessions/{sessionId}
├── sessionId: string
├── childId: string
├── results: object
└── difficultyProgression: object
```

**자세한 내용:** `FIREBASE_SCHEMA.md` 참조

---

## 📦 주요 패키지

### 의존성

```yaml
dependencies:
  # 라우팅
  go_router: ^13.0.0
  
  # 상태 관리
  flutter_riverpod: ^2.6.1
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.2
  
  # 게임 엔진
  flame: ^1.16.0
  flame_audio: ^2.1.7
  
  # 오디오
  audioplayers: ^6.0.0
  
  # 기타
  equatable: ^2.0.7
  flutter_svg: ^2.2.3
```

---

## 🎮 게임 통합 패턴

### Before (하드코딩)

```dart
class SameSoundGame extends StatefulWidget {
  List<SoundQuestion> _generateQuestions(int level) {
    switch (level) {
      case 1:
        return [
          SoundQuestion(
            sounds: ['🥁 북', '🎹 피아노', '🥁 북'],
            correctIndices: {0, 2},
          ),
          // ... 하드코딩
        ];
    }
  }
}
```

### After (JSON 기반)

```dart
class SameSoundGameV2 extends StatefulWidget {
  final QuestionLoaderService _loader = QuestionLoaderService();
  TrainingContentModel? _content;

  Future<void> _loadQuestions() async {
    _content = await _loader.loadFromLocalJson('same_sound.json');
  }
  
  @override
  Widget build(BuildContext context) {
    final currentItem = _content!.items[_currentIndex];
    
    return Row(
      children: currentItem.options.map((option) {
        return SoundCard(
          label: option.label,
          audioPath: option.audioPath,
          onTap: () => _onSelect(option),
        );
      }).toList(),
    );
  }
}
```

---

## 🔐 보안 고려사항

### Firebase Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 문항 데이터 (읽기 전용)
    match /training_contents/{contentId} {
      allow read: if request.auth != null;
      allow write: if false; // 관리자만
    }
    
    // 사용자 진도 (본인만)
    match /user_progress/{childId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.parentId;
    }
  }
}
```

---

## 📈 성능 최적화

### 1. 로딩 전략

```dart
// 로컬 우선, Firebase 폴백
final content = await questionLoader.loadHybrid(
  localFileName: 'same_sound.json',
  firebaseContentId: 'phonological_same_sound_001',
);
```

### 2. 캐싱

```dart
// 메모리 캐싱
final cachedContent = await questionLoader.loadWithCache(contentId);

// 캐시 클리어
questionLoader.clearCache();
```

### 3. 난이도 필터링

```dart
// 필요한 난이도만 로드
final filteredItems = content.items.where((item) {
  final level = item.itemData?['level'] as int? ?? 1;
  return level >= minLevel && level <= maxLevel;
}).toList();
```

---

## 🧪 테스트 전략

### 단위 테스트

```dart
test('QuestionLoaderService loads local JSON', () async {
  final service = QuestionLoaderService();
  final content = await service.loadFromLocalJson('same_sound.json');
  
  expect(content.contentId, 'phonological_same_sound_v1');
  expect(content.items.length, greaterThan(0));
});
```

### 통합 테스트

```dart
testWidgets('SameSoundGameV2 displays questions', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 로딩 대기
  await tester.pumpAndSettle();
  
  // 문항 표시 확인
  expect(find.text('같은 소리를 찾아주세요!'), findsOneWidget);
  expect(find.byType(SoundCard), findsNWidgets(3));
});
```

---

## 📚 관련 문서

| 문서 | 설명 |
|------|------|
| `AGENTS.md` | 프로젝트 가이드라인 (최우선) |
| `PROJECT_STRUCTURE.md` | 폴더 구조 |
| `QUESTION_MANAGEMENT_GUIDE.md` | **문항 관리 시스템 통합 가이드** ⭐ |
| `FIREBASE_SCHEMA.md` | Firestore 스키마 |
| `GOOGLE_SHEETS_TEMPLATE.md` | 문항 제작 템플릿 |
| `STATE_MANAGEMENT_GUIDE.md` | Riverpod 사용법 |

---

## 🚀 향후 계획

### Phase 1: MVP (완료)
- ✅ 기본 아키텍처
- ✅ Firebase 연동
- ✅ 검사 시스템
- ✅ **문항 관리 시스템** ⭐

### Phase 2: 베타 (진행 중)
- ⏳ 게임 확장 (10개 → 50개)
- ⏳ 문항 대량 제작 (30개 → 5,000개)
- ⏳ 학습 관리 시스템

### Phase 3: 정식 출시
- ⬜ 15,000개+ 문항
- ⬜ AI 기반 난이도 조정
- ⬜ 소셜 기능
- ⬜ 결제 시스템

---

**작성일:** 2025-12-06  
**마지막 업데이트:** 2025-12-06  
**버전:** 2.0.0 (문항 관리 시스템 추가)
