/**
 * 메인 애플리케이션 로직
 */

// 전역 변수
let assessment = null;
let audioRecorder = null;
let speechRecognizer = null;
let currentRecordingBlobUrl = null;
let currentAudioPlayer = null;

// 초기화
document.addEventListener('DOMContentLoaded', () => {
    assessment = new Assessment();
    audioRecorder = new AudioRecorder();
    speechRecognizer = new SpeechRecognizer();
    
    // 음성 인식 초기화
    if (!speechRecognizer.initialize()) {
        console.warn('음성 인식 기능을 사용할 수 없습니다');
    }

    // 이벤트 리스너 설정
    setupEventListeners();
});

/**
 * 이벤트 리스너 설정
 */
function setupEventListeners() {
    // 시작 버튼
    document.getElementById('start-btn').addEventListener('click', () => {
        showScreen('practice-intro-screen');
        playPracticeIntro();
    });

    // 연습문제 시작 버튼
    document.getElementById('practice-start-btn').addEventListener('click', () => {
        startPracticeQuestions();
    });

    // 녹음 버튼
    document.getElementById('record-btn').addEventListener('click', toggleRecording);

    // 다음 버튼
    document.getElementById('next-btn').addEventListener('click', goToNextQuestion);

    // 재생 버튼
    document.getElementById('play-btn').addEventListener('click', togglePlayback);

    // 다시 시작 버튼
    document.getElementById('restart-btn').addEventListener('click', () => {
        location.reload();
    });
}

/**
 * 화면 전환
 */
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
}

/**
 * 연습문제 안내 멘트 재생
 */
function playPracticeIntro() {
    const speaker = document.getElementById('practice-intro-speaker');
    speaker.classList.add('active');

    // TTS로 안내 멘트 재생 (간단한 예시)
    const utterance = new SpeechSynthesisUtterance(
        '지금부터 어떤 낱말을 들려 드립니다. 그리고 이 낱말에서 특정 소리를 빼고 남은 소리를 말해 달라고 할 것입니다. 예를 들어, 공책에서 공을 빼고 남은 소리를 말해 주세요. 이렇게 요청하면 공책에서 공을 빼고 책만 말하면 됩니다. 그럼 실제로 연습해 봅시다.'
    );
    utterance.lang = 'ko-KR';
    utterance.rate = 0.7;
    
    utterance.onend = () => {
        speaker.classList.remove('active');
    };

    speechSynthesis.speak(utterance);
}

/**
 * 연습문제 시작
 */
function startPracticeQuestions() {
    assessment.currentPhase = 'practice';
    assessment.currentPhaseIndex = 0;
    assessment.currentQuestionIndex = 0;
    
    showScreen('question-screen');
    updateQuestionDisplay();
    updateQuestionNavigation();
}

/**
 * 문항 표시 업데이트
 */
function updateQuestionDisplay() {
    const question = assessment.getCurrentQuestion();
    if (!question) return;

    // 제목 업데이트
    const title = document.getElementById('question-title');
    if (assessment.currentPhase === 'practice') {
        title.textContent = `연습문제${assessment.currentPhaseIndex + 1}`;
    } else {
        title.textContent = `문항 ${assessment.currentPhaseIndex + 1}`;
    }

    // 문항 멘트 재생
    playQuestionAudio(question.question);

    // UI 초기화
    resetQuestionUI();
}

/**
 * 문항 멘트 재생
 */
function playQuestionAudio(text) {
    const speaker = document.getElementById('question-speaker');
    speaker.classList.add('active');

    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'ko-KR';
    utterance.rate = 0.7;

    utterance.onend = () => {
        speaker.classList.remove('active');
    };

    speechSynthesis.speak(utterance);
}

/**
 * 문항 UI 초기화
 */
function resetQuestionUI() {
    document.getElementById('recording-time').style.display = 'none';
    document.getElementById('recognition-result').style.display = 'none';
    document.getElementById('recording-complete').style.display = 'none';
    document.getElementById('answer-feedback').style.display = 'none';
    document.getElementById('playback-section').style.display = 'none';
    document.getElementById('next-btn').style.display = 'none';
    
    const recordBtn = document.getElementById('record-btn');
    recordBtn.classList.remove('recording');
    document.getElementById('mic-icon').style.display = 'block';
    document.getElementById('stop-icon').style.display = 'none';
}

/**
 * 녹음 토글
 */
async function toggleRecording() {
    const recordBtn = document.getElementById('record-btn');
    
    if (!audioRecorder.isRecording) {
        // 녹음 시작
        const question = assessment.getCurrentQuestion();
        const isPractice = assessment.currentPhase === 'practice';

        const success = await audioRecorder.startRecording(
            (seconds) => {
                // 녹음 시간 업데이트
                const timeDisplay = document.getElementById('recording-time');
                timeDisplay.textContent = formatTime(seconds);
                timeDisplay.style.display = 'block';
            },
            (blobUrl, duration) => {
                // 녹음 완료
                currentRecordingBlobUrl = blobUrl;
                onRecordingComplete(blobUrl, duration, isPractice);
            }
        );

        if (success) {
            recordBtn.classList.add('recording');
            document.getElementById('mic-icon').style.display = 'none';
            document.getElementById('stop-icon').style.display = 'block';

            // 연습문제인 경우 음성 인식도 시작
            if (isPractice) {
                startSpeechRecognition();
            }
        } else {
            alert('녹음을 시작할 수 없습니다.\n\n1. 브라우저 주소창에서 마이크 권한을 허용해주세요.\n2. HTTPS로 접속했는지 확인해주세요.');
        }
    } else {
        // 녹음 중지
        audioRecorder.stopRecording();
        speechRecognizer.stop();

        recordBtn.classList.remove('recording');
        document.getElementById('mic-icon').style.display = 'block';
        document.getElementById('stop-icon').style.display = 'none';
        document.getElementById('recording-time').style.display = 'none';
    }
}

/**
 * 음성 인식 시작
 */
function startSpeechRecognition() {
    const recognitionResult = document.getElementById('recognition-result');
    recognitionResult.style.display = 'block';

    speechRecognizer.onResult = (text, isFinal) => {
        document.getElementById('recognized-text').textContent = text;
    };

    speechRecognizer.onError = (error) => {
        console.error('음성 인식 오류', error);
    };

    speechRecognizer.start();
}

/**
 * 녹음 완료 처리
 */
function onRecordingComplete(blobUrl, duration, isPractice) {
    document.getElementById('recording-complete').style.display = 'block';

    // 연습문제인 경우 정답 확인
    if (isPractice && duration > 0) {
        // 음성 인식 결과 확인
        setTimeout(() => {
            const recognizedText = speechRecognizer.getRecognizedText();
            checkAnswer(recognizedText, isPractice);
        }, 1000);
    } else {
        // 본 문항은 정답 확인 없이 다음으로 이동 가능
        document.getElementById('next-btn').style.display = 'block';
    }

    // 녹음 재생 버튼 표시 (연습문제만)
    if (isPractice && duration > 0) {
        document.getElementById('playback-section').style.display = 'block';
    }
}

/**
 * 정답 확인
 */
function checkAnswer(recognizedText, isPractice) {
    if (!recognizedText) {
        return;
    }

    const question = assessment.getCurrentQuestion();
    const isCorrect = assessment.checkAnswer(recognizedText, question.correctAnswer);

    // 답변 저장
    assessment.saveAnswer(question.itemId, recognizedText, isCorrect);

    // 피드백 표시
    const feedback = document.getElementById('answer-feedback');
    feedback.style.display = 'block';
    
    if (isCorrect) {
        feedback.className = 'answer-feedback correct';
        document.getElementById('feedback-text').textContent = '정답입니다!';
    } else {
        feedback.className = 'answer-feedback incorrect';
        document.getElementById('feedback-text').textContent = '다시 생각해보세요';
    }

    document.getElementById('recognized-answer').textContent = `인식된 답변: ${recognizedText}`;

    // 다음 버튼 표시
    document.getElementById('next-btn').style.display = 'block';
}

/**
 * 다음 문항으로 이동
 */
function goToNextQuestion() {
    assessment.nextQuestion();

    if (assessment.currentPhase === 'result') {
        showResultScreen();
    } else {
        updateQuestionDisplay();
        updateQuestionNavigation();
    }
}

/**
 * 특정 문항으로 이동
 */
function navigateToQuestion(targetIndex) {
    if (targetIndex < 0) return;

    const totalExamples = assessment.questions.examples.length;
    const totalMain = assessment.questions.main.length;
    const total = totalExamples + totalMain;

    if (targetIndex >= total) return;

    // 현재 문항 인덱스 업데이트
    assessment.currentQuestionIndex = targetIndex;

    // 연습문제인지 본 문항인지 판단
    if (targetIndex < totalExamples) {
        // 연습문제
        assessment.currentPhase = 'practice';
        assessment.currentPhaseIndex = targetIndex;
    } else {
        // 본 문항
        assessment.currentPhase = 'main';
        assessment.currentPhaseIndex = targetIndex - totalExamples;
    }

    // 녹음 중이면 중지
    if (audioRecorder.isRecording) {
        audioRecorder.stopRecording();
    }
    if (speechRecognizer.isRecognizing) {
        speechRecognizer.stop();
    }

    // 화면 업데이트
    updateQuestionDisplay();
    updateQuestionNavigation();
    
    // UI 초기화
    resetQuestionUI();
    
    console.log(`문항 ${targetIndex + 1}로 이동 완료`);
}

/**
 * 문항 네비게이션 업데이트
 */
function updateQuestionNavigation() {
    const container = document.getElementById('question-numbers');
    container.innerHTML = '';

    const totalExamples = assessment.questions.examples.length;
    const totalMain = assessment.questions.main.length;
    const total = totalExamples + totalMain;

    for (let i = 0; i < total; i++) {
        const btn = document.createElement('button');
        btn.className = 'question-number';
        btn.textContent = i + 1;

        if (i === assessment.currentQuestionIndex) {
            btn.classList.add('current');
        }

        // 완료된 문항 표시
        if (i < assessment.currentQuestionIndex) {
            btn.classList.add('completed');
        }

        // 클릭 이벤트
        btn.addEventListener('click', () => {
            navigateToQuestion(i);
        });

        container.appendChild(btn);
    }
}

/**
 * 녹음 재생 토글
 */
function togglePlayback() {
    if (!currentRecordingBlobUrl) return;

    if (currentAudioPlayer && !currentAudioPlayer.paused) {
        // 재생 중지
        currentAudioPlayer.pause();
        currentAudioPlayer.currentTime = 0;
        currentAudioPlayer = null;
    } else {
        // 재생 시작
        currentAudioPlayer = new Audio(currentRecordingBlobUrl);
        currentAudioPlayer.play();
        
        currentAudioPlayer.onended = () => {
            currentAudioPlayer = null;
        };
    }
}

/**
 * 결과 화면 표시
 */
function showResultScreen() {
    showScreen('result-screen');
    
    const summary = assessment.getResultSummary();
    const summaryDiv = document.getElementById('result-summary');
    
    summaryDiv.innerHTML = `
        <h3>검사 결과 요약</h3>
        <p><strong>연습문제:</strong> ${summary.practice.correct} / ${summary.practice.total}</p>
        <p><strong>본 문항:</strong> ${summary.main.correct} / ${summary.main.total}</p>
        <p><strong>전체:</strong> ${summary.total.correct} / ${summary.total.total}</p>
    `;
}

/**
 * 시간 포맷팅
 */
function formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}
