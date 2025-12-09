# Firebase Firestore 스키마 설계

## 📋 개요

이 문서는 문해력 기초 검사 앱의 Firebase Firestore 데이터베이스 구조를 정의합니다.

**주요 컬렉션:**
- `training_contents` - 학습 문항 (15,000개+)
- `assessment_questions` - 검사 문항 (50개, 백업용)
- `user_progress` - 학습 진도
- `learning_sessions` - 학습 세션 기록

---

## 🗂️ 컬렉션 구조

### 1. training_contents (학습 문항)

**경로:** `/training_contents/{contentId}`

**용도:** 학습용 대량 문항 저장 (15,000개 이상)

**필드:**

```typescript
{
  contentId: string;              // 문항 ID (예: "phonological_same_sound_001")
  moduleId: string;               // 모듈 ID (예: "phonological_basic")
  type: string;                   // 타입 (phonological, sensory, executive 등)
  pattern: string;                // 게임 패턴 (multipleChoice, matching, rhythmTap 등)
  title: string;                  // 제목 (관리자용)
  instruction: string;            // 지시문 (텍스트)
  instructionAudioPath?: string;  // 지시 음성 경로
  
  items: Array<{                  // 문제 항목들
    itemId: string;
    question: string;
    questionAudioPath?: string;
    questionImagePath?: string;
    options: Array<{
      optionId: string;
      label: string;
      imagePath?: string;
      audioPath?: string;
      optionData?: object;
    }>;
    correctAnswer: string;
    explanation?: string;
    explanationAudioPath?: string;
    itemData?: object;
  }>;
  
  difficulty: {                   // 난이도 파라미터
    level: number;                // 1~5
    minLevel: number;
    maxLevel: number;
    adjustmentThreshold: number;
    difficultyFactors: object;
  };
  
  metadata?: {                    // 메타데이터
    version: string;
    createdAt: string;
    lastUpdated: string;
    author: string;
    tags: string[];
    estimatedDuration: number;    // 예상 소요 시간 (초)
    minAge: number;
    maxAge: number;
  };
}
```

**인덱스:**
- `moduleId` (ASC)
- `type` (ASC)
- `difficulty.level` (ASC)
- `metadata.tags` (ARRAY_CONTAINS)

**예제:**

```json
{
  "contentId": "phonological_same_sound_001",
  "moduleId": "phonological_basic",
  "type": "phonological",
  "pattern": "multipleChoice",
  "title": "같은 소리 찾기 - 악기 소리",
  "instruction": "3개의 소리 중 같은 2개를 찾아 터치하세요",
  "items": [...],
  "difficulty": {
    "level": 1,
    "minLevel": 1,
    "maxLevel": 3,
    "adjustmentThreshold": 3,
    "difficultyFactors": {
      "soundType": "instrument"
    }
  },
  "metadata": {
    "version": "1.0.0",
    "createdAt": "2025-12-06",
    "tags": ["phonological", "sound_discrimination"]
  }
}
```

---

### 2. assessment_questions (검사 문항)

**경로:** `/assessment_questions/{questionId}`

**용도:** 표준화된 검사 문항 50개 (백업용, 주로 로컬 JSON 사용)

**필드:**

```typescript
{
  questionId: string;             // 문항 ID (예: "q4_sound_identification")
  type: string;                   // QuestionType enum
  category: string;               // phonological, sensory, executive
  promptText: string;
  promptAudioUrl: string;
  optionsImageUrl?: string[];
  optionsText?: string[];
  soundUrls?: string[];
  soundLabels?: string[];
  correctAnswer: any;
  timeLimitSeconds: number;
  
  metadata: {
    standardized: boolean;        // 표준화 여부
    normData?: object;            // 규준 데이터
    ageRange: {
      min: number;
      max: number;
    };
  };
}
```

---

### 3. user_progress (학습 진도)

**경로:** `/user_progress/{childId}`

**용도:** 아동별 학습 진도 추적

**필드:**

```typescript
{
  childId: string;
  
  // 모듈별 진도
  modules: {
    [moduleId: string]: {
      currentLevel: number;
      completedContents: string[];    // contentId 배열
      totalContents: number;
      correctCount: number;
      incorrectCount: number;
      lastAccessedAt: Timestamp;
      progressPercentage: number;
    };
  };
  
  // 전체 통계
  totalStats: {
    totalSessions: number;
    totalCorrect: number;
    totalIncorrect: number;
    totalPlayTime: number;            // 초
    averageAccuracy: number;
    streak: number;                   // 연속 학습 일수
    lastActiveDate: string;           // YYYY-MM-DD
  };
  
  // 강약점 분석
  strengthsAndWeaknesses: {
    strengths: string[];              // 잘하는 영역
    weaknesses: string[];             // 보완 필요 영역
    recommendations: string[];        // 추천 콘텐츠
  };
  
  updatedAt: Timestamp;
}
```

**인덱스:**
- `childId` (ASC)
- `updatedAt` (DESC)

---

### 4. learning_sessions (학습 세션)

**경로:** `/learning_sessions/{sessionId}`

**용도:** 개별 학습 세션 기록

**필드:**

```typescript
{
  sessionId: string;
  childId: string;
  contentId: string;
  moduleId: string;
  
  startedAt: Timestamp;
  completedAt: Timestamp;
  duration: number;                   // 초
  
  results: {
    totalQuestions: number;
    correctCount: number;
    incorrectCount: number;
    accuracy: number;
    
    itemResults: Array<{
      itemId: string;
      isCorrect: boolean;
      responseTime: number;           // 밀리초
      attemptCount: number;
      answeredAt: Timestamp;
    }>;
  };
  
  difficultyProgression: {
    startLevel: number;
    endLevel: number;
    adjustments: Array<{
      itemId: string;
      beforeLevel: number;
      afterLevel: number;
      reason: string;
    }>;
  };
  
  feedback: {
    characterMood: string;            // happy, neutral, sad
    encouragementMessage: string;
    badges?: string[];
  };
}
```

**인덱스:**
- `childId` (ASC), `startedAt` (DESC) (복합 인덱스)
- `moduleId` (ASC), `startedAt` (DESC) (복합 인덱스)
- `contentId` (ASC)

---

### 5. question_metadata (문항 메타데이터)

**경로:** `/question_metadata/{contentId}`

**용도:** 문항 사용 통계 및 품질 관리

**필드:**

```typescript
{
  contentId: string;
  
  usage: {
    totalAttempts: number;
    totalCorrect: number;
    totalIncorrect: number;
    averageResponseTime: number;      // 밀리초
    averageAccuracy: number;
  };
  
  quality: {
    difficultyScore: number;          // 0~1 (실제 난이도)
    discriminationIndex: number;      // -1~1 (변별도)
    reliability: number;              // 0~1 (신뢰도)
    lastReviewed: Timestamp;
    flagged: boolean;                 // 문제 있는 문항 표시
    flagReason?: string;
  };
  
  feedback: {
    totalReports: number;
    reportedIssues: Array<{
      issueType: string;
      userId: string;
      reportedAt: Timestamp;
      description: string;
    }>;
  };
}
```

---

## 📊 데이터 조회 패턴

### 패턴 1: 난이도별 문항 로드

```dart
// 특정 모듈의 특정 난이도 문항 로드
final querySnapshot = await FirebaseFirestore.instance
    .collection('training_contents')
    .where('moduleId', isEqualTo: 'phonological_basic')
    .where('difficulty.level', isGreaterThanOrEqualTo: 2)
    .where('difficulty.level', isLessThanOrEqualTo: 4)
    .limit(20)
    .get();
```

### 패턴 2: 태그 기반 검색

```dart
// 특정 태그를 가진 문항 검색
final querySnapshot = await FirebaseFirestore.instance
    .collection('training_contents')
    .where('metadata.tags', arrayContains: 'sound_discrimination')
    .limit(10)
    .get();
```

### 패턴 3: 학습 진도 업데이트

```dart
// 학습 완료 후 진도 업데이트
await FirebaseFirestore.instance
    .collection('user_progress')
    .doc(childId)
    .update({
      'modules.$moduleId.completedContents': FieldValue.arrayUnion([contentId]),
      'modules.$moduleId.correctCount': FieldValue.increment(correctCount),
      'modules.$moduleId.lastAccessedAt': FieldValue.serverTimestamp(),
    });
```

---

## 🔐 보안 규칙

### training_contents (읽기 전용)

```javascript
match /training_contents/{contentId} {
  allow read: if request.auth != null;
  allow write: if false; // 관리자만 콘솔에서 작성
}
```

### user_progress (본인만)

```javascript
match /user_progress/{childId} {
  allow read, write: if request.auth != null 
    && request.auth.uid == resource.data.parentId;
}
```

### learning_sessions (본인만)

```javascript
match /learning_sessions/{sessionId} {
  allow read, write: if request.auth != null 
    && request.auth.uid == resource.data.parentId;
}
```

---

## 📈 데이터 확장 전략

### Phase 1: MVP (현재)
- 로컬 JSON: 검사 문항 50개
- Firebase: POC 문항 100개

### Phase 2: 정식 출시
- Firebase: 학습 문항 5,000개
- 5개 분야 × 10개 유형 × 100개

### Phase 3: 완전체
- Firebase: 학습 문항 15,000개+
- 5개 분야 × 10개 유형 × 300개+
- 지속적 확장

---

## 🛠️ 마이그레이션 계획

### 로컬 JSON → Firebase

```dart
// 1회성 마이그레이션 스크립트
Future<void> migrateLocalToFirebase() async {
  final loaderService = QuestionLoaderService();
  final batch = FirebaseFirestore.instance.batch();
  
  // 로컬 JSON 파일 목록
  final files = ['same_sound.json', 'syllable_clap.json', ...];
  
  for (final fileName in files) {
    final content = await loaderService.loadFromLocalJson(fileName);
    
    final docRef = FirebaseFirestore.instance
        .collection('training_contents')
        .doc(content.contentId);
    
    batch.set(docRef, content.toJson());
  }
  
  await batch.commit();
}
```

---

## 📝 관련 문서

- `QUESTION_MANAGEMENT_GUIDE.md` - 문항 관리 가이드
- `question_loader_service.dart` - 로딩 서비스 구현
- `training_content_model.dart` - 데이터 모델

---

**작성일:** 2025-12-06  
**작성자:** AI Assistant  
**버전:** 1.0.0
