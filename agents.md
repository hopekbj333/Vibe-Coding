# 🤖 Agents Guide: Literacy Assessment Project

이 파일은 `literacy-assessment` 프로젝트의 AI 에이전트 및 개발자를 위한 공통 가이드라인입니다.  
모든 작업은 **이 문서를 최우선 기준**으로 수행해야 합니다.

---

## 1. 🚀 프로젝트 개요 (Project Identity)

*   **앱 이름**: 문해력 기초 검사 (Literacy Assessment)
*   **한줄 소개**: 한글 학습의 전제 조건인 **음운처리능력**(음운인식능력, 음운처리능력)을 검사하는 디지털 검사 및 훈련 서비스.
*   **검사 체계**: 35개 능력 (음운인식능력 15개 + 음운처리능력 20개)
*   **검사 방식**: 스토리형 검사 (35문항)
*   **핵심 타깃**: 경계선지능 아동(느린 학습자), 한글 미해득 유아 (만 6~7세).
*   **기술 스택**:
    *   **Frontend**: Flutter (App/Web 통합)
    *   **Game Engine**: Flame Engine (학습 콘텐츠용)
    *   **State Management**: Riverpod (Code Generation 기반 권장)
    *   **Routing**: GoRouter
    *   **Backend**: Firebase (Auth, Firestore, Storage, Functions)
    *   **Architecture**: Feature-first + Clean Architecture

---

## 2. 🧠 핵심 철학 및 UX 원칙 (Core Philosophy)

이 프로젝트는 일반적인 앱과 다릅니다. **"글을 못 읽는 아이"**가 사용자임을 항상 기억해야 합니다.

1.  **Zero-Text Interface for Kids**:
    *   아동용 화면에는 텍스트를 절대 사용하지 않거나 최소화합니다.
    *   모든 지시는 **음성(TTS/녹음)**으로 제공하며, 버튼은 **이미지/아이콘**이어야 합니다.
2.  **Cognitive Ease (인지적 편안함)**:
    *   화면당 **하나의 정보/질문**만 제시합니다.
    *   애니메이션과 전환 속도는 일반 앱보다 **1.5배 느리게** 설정합니다.
    *   복잡한 메뉴나 네비게이션을 피합니다.
3.  **Gamification (놀이 요소)**:
    *   '검사'가 아닌 '여행'처럼 느껴지게 합니다.
    *   즉각적인 피드백(시각/청각)을 제공합니다.
4.  **Mode Separation (모드 분리)**:
    *   **아동 모드**: 전체 화면, 뒤로가기 제한, PIN 잠금 해제 필요.
    *   **부모/교사 모드**: 관리자 기능, 리포트 확인, 일반적인 UI 허용.

---

## 3. 🏗 아키텍처 및 구조 (Architecture)

### 3.1 디렉토리 구조 (Feature-first)
`lib/` 하위 구조는 기능을 기준으로 분리합니다.

```
lib/
├── config/             # 앱 설정 (Router, Theme, Env)
├── core/               # 공통 모듈 (Widgets, Utils, Assets, Design System)
└── features/           # 기능별 모듈
    ├── auth/           # 인증
    ├── child/          # 아동 관리 (프로필)
    ├── assessment/     # 검사 (핵심 기능)
    │   ├── framework/  # 검사 실행 공통 엔진
    │   └── modules/    # 개별 검사 항목 (phonological, sensory, executive)
    ├── home/           # 홈 화면
    └── training/       # 학습/훈련 (Milestone 2)
```

### 3.2 Feature 내부 구조 (Clean Architecture)
각 Feature 폴더 내부는 레이어별로 나눕니다 (필요 시 단순화 가능하지만, 원칙을 따름).

```
feature_name/
├── data/               # API, DTO, RepositoryImpl
├── domain/             # Entity, Usecase, Repository Interface
└── presentation/       # Pages, Widgets, Providers (Riverpod)
```

### 3.3 상태 관리 (Riverpod)
*   **Providers**: `g.dart`를 생성하는 `@riverpod` 어노테이션 사용을 권장합니다.
*   **불변성**: State는 `freezed` 등을 활용해 불변 객체(Immutable)로 관리합니다.

---

## 4. 📏 코딩 컨벤션 (Coding Standards)

1.  **파일명**: `snake_case` (예: `assessment_screen.dart`)
2.  **클래스명**: `PascalCase` (예: `AssessmentScreen`)
3.  **변수/함수명**: `camelCase` (예: `startAssessment`)
4.  **주석**: 복잡한 로직에는 반드시 한국어 주석을 답니다. 특히 검사 로직의 '의도'를 설명해야 합니다.
5.  **상수 관리**: 문자열, 색상, 스타일은 하드코딩하지 않고 `core/constants` 또는 `core/theme`에서 관리합니다.
6.  **에셋 경로**: `AssetManager` 클래스를 통해 안전하게 접근합니다. (문자열 직접 입력 지양)

---

## 5. 📅 프로젝트 현황 및 로드맵 (Status & Roadmap)

### ✅ 현재 상태 (Current Status)
*   **Milestone 1 완료**: 기초 인프라, Firebase 연동, 사용자 관리(로그인/회원가입), 아동 프로필 관리, 모드 전환 시스템.
*   **검사 체계 확정**: 35개 능력 체계 확정 (음운인식능력 15개 + 음운처리능력 20개)
*   **스토리형 검사 구현 완료**: 35문항 스토리형 검사 기능 구현 완료
*   **진행 중**: 검사 기능 안정화 및 개선

### 🎯 다음 목표 (Next Steps)
1.  **검사 실행 프레임워크 (WP 1.3)**: 문항이 로드되고, 정답/오답을 처리하고, 다음 문항으로 넘어가는 공통 엔진.
2.  **검사 모듈 구현 (WP 1.4 ~ 1.6)**:
    *   음운 인식 (소리 듣고 고르기 등)
    *   감각 처리 (순서 기억하기 등)
    *   인지 제어 (따라 말하기 등)
3.  **학습 콘텐츠 시스템 (Milestone 2)**: Flame Engine 기반 훈련 게임.

---

## 6. 🛑 AI 에이전트 작업 수칙 (Rules for Agent)

1.  **언어**: 모든 대화와 설명은 **한국어**로 합니다.
2.  **문맥 유지**: 항상 `agents.md`, `PROJECT_STRUCTURE.md`를 참고하여 현재 프로젝트 구조에 맞는 코드를 작성하세요.
3.  **사용자 관점**: 코드를 짤 때 "이것이 6살 아이가 쓰기에 적합한가?"를 자문하세요. (버튼 크기, 피드백 속도 등)
4.  **파일 수정 전 확인**: 기존 코드를 덮어쓰기 전에 `read_file`로 내용을 확인하고, 기존 로직을 불필요하게 파괴하지 마세요.
5.  **에러 처리**: 아동이 오작동(마구 누르기 등)을 할 수 있음을 가정하고 예외 처리를 꼼꼼하게 하세요.
6.  **소통**: 구현 방향이 모호하면 사용자에게 질문하여 명확히 한 후 진행하세요.
7.  **⚠️ 완성 문항 보호 (CRITICAL)**: 사용자가 '완성'이라고 표시하거나 승인한 문항/기능/코드는 **사용자의 명시적 승인 없이 절대로 수정하지 않습니다**. 
    * 완성된 문항의 버그 수정이라도 사용자에게 먼저 확인을 받아야 합니다.
    * 완성된 코드의 리팩토링이나 개선 작업도 사용자 승인이 필요합니다.
    * 이 규칙은 프로젝트의 안정성과 신뢰성을 보장하기 위한 최우선 규칙입니다.

---

## 7. 📋 WP 완료 후 정리 규칙 (Post-WP Documentation)

각 Work Package(WP)를 완료한 후, **시나리오 기준 정리 표**를 반드시 제공합니다.

### 7.1 정리 형식

**1) 시나리오별 구현 현황 표:**

| 시나리오 | 게임명/기능명 | 파일 경로 | 게임 패턴/기술 | 상태 |
|---------|-------------|----------|--------------|------|
| S X.Y.Z | 기능 이름 | `파일명.dart` | 사용된 패턴 | ✅/🔄/❌ |

**2) 파일 구조:**
```
lib/features/해당_feature/
├── 파일1.dart  # 시나리오 설명
├── 파일2.dart  # 시나리오 설명
└── ...
```

**3) 주요 테스트 시나리오 표:**

| 시나리오 | 테스트 방법 | 예상 결과 |
|---------|------------|----------|
| 시나리오명 | 구체적 조작 방법 | 기대 동작 |

### 7.2 예시 (WP 3.1)

```markdown
## ✅ WP 3.1: 음운 인식 4~5단계 훈련 - 시나리오별 구현 현황

| 시나리오 | 게임명 | 파일 | 게임 패턴 | 상태 |
|---------|--------|------|----------|------|
| S 3.1.1 | 초성 분리 게임 | `onset_separation_game.dart` | 객관식 | ✅ |
| S 3.1.2 | 음소 합성 게임 | `phoneme_synthesis_game.dart` | 객관식 + 애니메이션 | ✅ |
| ... | ... | ... | ... | ... |
```

### 7.3 목적
- **추적성**: 기획 문서(WP md)와 실제 코드 간 매핑 확인
- **테스트**: QA 시 시나리오별 테스트 체크리스트로 활용
- **인수인계**: 새로운 개발자/에이전트가 빠르게 파악 가능

---

## 8. 📁 WP 문서 관리 규칙 (WP Document Management)

### 8.1 마일스톤/WP 문서 구조

```
프로젝트_루트/
├── milestone1.md               # 마일스톤 1 전체 개요
├── milestone2.md               # 마일스톤 2 전체 개요
├── milestone2_WP2.1_xxx.md     # WP별 상세 문서
├── milestone2_WP2.2_xxx.md
├── milestone3.md               # 마일스톤 3 전체 개요
├── milestone3_WP3.1_xxx.md     # WP별 상세 문서
└── ...
```

### 8.2 WP 문서 명명 규칙
- 형식: `milestone{N}_WP{N}.{M}_{영문약어}.md`
- 예시: `milestone3_WP3.1_phoneme.md`

### 8.3 WP 문서 작성 시점
- **마일스톤 시작 전**: 전체 개요 문서(`milestoneN.md`)를 기반으로 WP별 상세 문서 생성
- **WP 시작 전**: 해당 WP 문서를 읽고 시나리오 파악 후 작업 시작

---
*Last Updated: 2025-12-04*

