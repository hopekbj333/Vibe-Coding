# 구글 시트 문항 제작 템플릿

## 📋 개요

이 문서는 구글 시트를 사용하여 대량의 학습 문항을 제작하고, 
Apps Script를 통해 JSON 형식으로 내보내는 방법을 설명합니다.

---

## 📊 시트 구조

### 시트 1: Content Info (콘텐츠 정보)

| 필드명 | 설명 | 예시 |
|--------|------|------|
| contentId | 콘텐츠 ID | phonological_same_sound_batch1 |
| moduleId | 모듈 ID | phonological_basic |
| type | 콘텐츠 타입 | phonological |
| pattern | 게임 패턴 | multipleChoice |
| title | 제목 | 같은 소리 찾기 - 동물 소리 |
| instruction | 지시문 | 3개의 소리 중 같은 2개를 찾아 터치하세요 |
| instructionAudioPath | 음성 경로 | audio/instructions/same_sound.mp3 |
| difficultyLevel | 난이도 레벨 | 2 |
| version | 버전 | 1.0.0 |
| author | 작성자 | 홍길동 |

### 시트 2: Items (문항 목록)

| itemId | question | questionAudioPath | questionImagePath | correctAnswer | explanation | level | category | ... |
|--------|----------|-------------------|-------------------|---------------|-------------|-------|----------|-----|
| ss_021 | 같은 소리를 찾으세요 | audio/animals/dog.mp3 | | opt1,opt3 | 같은 강아지 소리를 찾았어요! | 2 | animal | ... |
| ss_022 | 같은 소리를 찾으세요 | audio/animals/cat.mp3 | | opt1,opt2 | 같은 고양이 소리를 찾았어요! | 2 | animal | ... |

### 시트 3: Options (선택지 목록)

| itemId | optionId | label | imagePath | audioPath | optionData |
|--------|----------|-------|-----------|-----------|------------|
| ss_021 | opt1 | 🐕 멍멍 | | audio/animals/dog.mp3 | {"soundType":"dog"} |
| ss_021 | opt2 | 🐱 야옹 | | audio/animals/cat.mp3 | {"soundType":"cat"} |
| ss_021 | opt3 | 🐕 멍멍 | | audio/animals/dog.mp3 | {"soundType":"dog"} |
| ss_022 | opt1 | 🐱 야옹 | | audio/animals/cat.mp3 | {"soundType":"cat"} |
| ss_022 | opt2 | 🐱 야옹 | | audio/animals/cat.mp3 | {"soundType":"cat"} |
| ss_022 | opt3 | 🐕 멍멍 | | audio/animals/dog.mp3 | {"soundType":"dog"} |

---

## 🔧 Apps Script 코드

### 1. JSON 내보내기 스크립트

구글 시트 메뉴: **확장 프로그램 > Apps Script**

```javascript
/**
 * 문항 데이터를 JSON으로 변환하여 다운로드합니다.
 */
function exportToJSON() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // 1. 콘텐츠 정보 읽기
  const infoSheet = ss.getSheetByName('Content Info');
  const contentInfo = readContentInfo(infoSheet);
  
  // 2. 문항 목록 읽기
  const itemsSheet = ss.getSheetByName('Items');
  const items = readItems(itemsSheet);
  
  // 3. 선택지 목록 읽기
  const optionsSheet = ss.getSheetByName('Options');
  const options = readOptions(optionsSheet);
  
  // 4. 문항에 선택지 연결
  items.forEach(item => {
    item.options = options.filter(opt => opt.itemId === item.itemId)
      .map(opt => {
        delete opt.itemId;
        return opt;
      });
  });
  
  // 5. 최종 JSON 구조 생성
  const jsonOutput = {
    contentId: contentInfo.contentId,
    moduleId: contentInfo.moduleId,
    type: contentInfo.type,
    pattern: contentInfo.pattern,
    title: contentInfo.title,
    instruction: contentInfo.instruction,
    instructionAudioPath: contentInfo.instructionAudioPath || null,
    
    difficulty: {
      level: parseInt(contentInfo.difficultyLevel) || 1,
      minLevel: 1,
      maxLevel: 5,
      adjustmentThreshold: 3,
      difficultyFactors: {}
    },
    
    items: items,
    
    metadata: {
      version: contentInfo.version || "1.0.0",
      createdAt: Utilities.formatDate(new Date(), "GMT+9", "yyyy-MM-dd"),
      lastUpdated: Utilities.formatDate(new Date(), "GMT+9", "yyyy-MM-dd"),
      author: contentInfo.author || "system",
      tags: [],
      estimatedDuration: items.length * 30,
      minAge: 6,
      maxAge: 10
    }
  };
  
  // 6. JSON 문자열 생성
  const jsonString = JSON.stringify(jsonOutput, null, 2);
  
  // 7. 결과 시트에 출력
  const outputSheet = getOrCreateSheet(ss, 'JSON Output');
  outputSheet.clear();
  outputSheet.getRange(1, 1).setValue(jsonString);
  
  // 8. 다운로드 가능한 URL 생성
  SpreadsheetApp.getUi().alert(
    'JSON 생성 완료',
    'JSON Output 시트를 확인하세요.\n파일명: ' + contentInfo.contentId + '.json',
    SpreadsheetApp.getUi().ButtonSet.OK
  );
}

/**
 * 콘텐츠 정보 읽기
 */
function readContentInfo(sheet) {
  const data = sheet.getDataRange().getValues();
  const info = {};
  
  // 첫 번째 열은 키, 두 번째 열은 값
  for (let i = 1; i < data.length; i++) {
    const key = data[i][0];
    const value = data[i][1];
    if (key) {
      info[key] = value;
    }
  }
  
  return info;
}

/**
 * 문항 목록 읽기
 */
function readItems(sheet) {
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const items = [];
  
  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    
    // 빈 행 건너뛰기
    if (!row[0]) continue;
    
    const item = {
      itemId: row[0] || '',
      question: row[1] || '',
      questionAudioPath: row[2] || null,
      questionImagePath: row[3] || null,
      correctAnswer: row[4] || '',
      explanation: row[5] || null,
      explanationAudioPath: row[6] || null,
      itemData: {
        level: parseInt(row[7]) || 1,
        category: row[8] || ''
      },
      options: [] // 나중에 채워짐
    };
    
    items.push(item);
  }
  
  return items;
}

/**
 * 선택지 목록 읽기
 */
function readOptions(sheet) {
  const data = sheet.getDataRange().getValues();
  const options = [];
  
  for (let i = 1; i < data.length; i++) {
    const row = data[i];
    
    // 빈 행 건너뛰기
    if (!row[0]) continue;
    
    const option = {
      itemId: row[0] || '', // 나중에 삭제됨
      optionId: row[1] || '',
      label: row[2] || '',
      imagePath: row[3] || null,
      audioPath: row[4] || null,
      optionData: row[5] ? JSON.parse(row[5]) : null
    };
    
    options.push(option);
  }
  
  return options;
}

/**
 * 시트 가져오기 또는 생성
 */
function getOrCreateSheet(ss, sheetName) {
  let sheet = ss.getSheetByName(sheetName);
  if (!sheet) {
    sheet = ss.insertSheet(sheetName);
  }
  return sheet;
}

/**
 * 메뉴 추가
 */
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('문항 관리')
    .addItem('JSON 내보내기', 'exportToJSON')
    .addItem('Firebase에 업로드', 'uploadToFirebase')
    .addItem('검증하기', 'validateData')
    .addToUi();
}

/**
 * 데이터 검증
 */
function validateData() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const itemsSheet = ss.getSheetByName('Items');
  const optionsSheet = ss.getSheetByName('Options');
  
  const items = readItems(itemsSheet);
  const options = readOptions(optionsSheet);
  
  const errors = [];
  
  // 각 문항에 선택지가 있는지 확인
  items.forEach(item => {
    const itemOptions = options.filter(opt => opt.itemId === item.itemId);
    if (itemOptions.length === 0) {
      errors.push(`${item.itemId}: 선택지가 없습니다.`);
    }
  });
  
  // 결과 표시
  if (errors.length === 0) {
    SpreadsheetApp.getUi().alert('검증 성공', '모든 데이터가 유효합니다.', SpreadsheetApp.getUi().ButtonSet.OK);
  } else {
    SpreadsheetApp.getUi().alert('검증 실패', errors.join('\n'), SpreadsheetApp.getUi().ButtonSet.OK);
  }
}

/**
 * Firebase에 직접 업로드 (선택 사항)
 * 주의: Firebase Admin SDK 설정 필요
 */
function uploadToFirebase() {
  SpreadsheetApp.getUi().alert(
    '기능 준비 중',
    '현재는 JSON 파일을 내보낸 후 수동으로 Firebase에 업로드해주세요.',
    SpreadsheetApp.getUi().ButtonSet.OK
  );
}
```

---

## 📝 사용 방법

### 1단계: 템플릿 복사

1. 구글 시트를 생성합니다
2. 3개의 시트를 만듭니다:
   - `Content Info`
   - `Items`
   - `Options`
3. 위의 구조대로 헤더를 작성합니다

### 2단계: 데이터 입력

1. **Content Info** 시트에 콘텐츠 정보 입력
2. **Items** 시트에 문항 데이터 입력
3. **Options** 시트에 선택지 데이터 입력

### 3단계: Apps Script 설정

1. 메뉴: **확장 프로그램 > Apps Script**
2. 위의 스크립트를 복사하여 붙여넣기
3. 저장 후 시트로 돌아가기
4. 새로고침 (F5)

### 4단계: JSON 내보내기

1. 메뉴: **문항 관리 > 검증하기** (선택 사항)
2. 메뉴: **문항 관리 > JSON 내보내기**
3. `JSON Output` 시트 확인
4. JSON 텍스트를 복사하여 `.json` 파일로 저장

### 5단계: 파일 저장

```
assets/questions/training/phonological_same_sound_batch1.json
```

---

## 🎯 활용 예시

### 예시 1: 같은 소리 찾기 100개

**Content Info:**
- contentId: `phonological_same_sound_batch1`
- 문항 수: 100개
- 난이도: 1~3 혼합

**Items:**
- ss_001 ~ ss_100

**Options:**
- 각 문항당 3개 선택지
- 총 300개 옵션

### 예시 2: 음절 쪼개기 200개

**Content Info:**
- contentId: `phonological_syllable_clap_batch1`
- 문항 수: 200개
- 난이도: 1~4 혼합

**Items:**
- sc_001 ~ sc_200

**Options:**
- 선택지 없음 (tap 게임)

---

## 📊 대량 제작 전략

### 단계별 목표

**Phase 1 (MVP):**
- 3개 게임 × 10개 문항 = 30개

**Phase 2 (베타):**
- 10개 게임 × 50개 문항 = 500개

**Phase 3 (정식 출시):**
- 50개 게임 × 100개 문항 = 5,000개

**Phase 4 (완전체):**
- 50개 게임 × 300개 문항 = 15,000개

### 효율적인 제작 방법

1. **템플릿 재사용**: 동일한 패턴의 게임은 템플릿 복사
2. **배치 작업**: 한 번에 50~100개씩 제작
3. **협업**: 여러 제작자가 동시 작업 (시트 공유)
4. **검증**: Apps Script로 자동 검증
5. **버전 관리**: 파일명에 batch 번호 포함

---

## 🔗 연관 문서

- `FIREBASE_SCHEMA.md` - Firestore 구조
- `QUESTION_MANAGEMENT_GUIDE.md` - 전체 가이드
- `question_loader_service.dart` - 로딩 서비스

---

## 📌 주의사항

1. **ID 중복 방지**: itemId는 고유해야 합니다
2. **경로 일관성**: 오디오/이미지 경로는 일관되게 작성
3. **JSON 문법**: optionData는 올바른 JSON 형식으로
4. **백업**: 정기적으로 시트 백업

---

**작성일:** 2025-12-06  
**작성자:** AI Assistant  
**버전:** 1.0.0
