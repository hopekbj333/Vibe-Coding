/**
 * 검사 로직 관리 클래스
 */
class Assessment {
    constructor() {
        this.questions = null;
        this.currentPhase = 'intro'; // intro, practice-intro, practice, main, result
        this.currentQuestionIndex = -1;
        this.currentPhaseIndex = -1; // 연습문제 또는 본 문항 인덱스
        this.answers = [];
        this.loadQuestions();
    }

    /**
     * 문항 데이터 로드
     */
    async loadQuestions() {
        try {
            const response = await fetch('data/questions.json');
            this.questions = await response.json();
            console.log('문항 데이터 로드 완료', this.questions);
        } catch (error) {
            console.error('문항 데이터 로드 실패', error);
            alert('문항 데이터를 불러올 수 없습니다.');
        }
    }

    /**
     * 현재 문항 가져오기
     */
    getCurrentQuestion() {
        if (!this.questions) return null;

        if (this.currentPhase === 'practice') {
            return this.questions.examples[this.currentPhaseIndex];
        } else if (this.currentPhase === 'main') {
            return this.questions.main[this.currentPhaseIndex];
        }

        return null;
    }

    /**
     * 다음 문항으로 이동
     */
    nextQuestion() {
        if (this.currentPhase === 'practice') {
            this.currentPhaseIndex++;
            if (this.currentPhaseIndex >= this.questions.examples.length) {
                // 연습문제 완료 → 본 문항 시작
                this.currentPhase = 'main';
                this.currentPhaseIndex = 0;
            }
        } else if (this.currentPhase === 'main') {
            this.currentPhaseIndex++;
            if (this.currentPhaseIndex >= this.questions.main.length) {
                // 검사 완료
                this.currentPhase = 'result';
            }
        }

        this.currentQuestionIndex++;
    }

    /**
     * 답변 저장
     */
    saveAnswer(questionId, answer, isCorrect = null) {
        this.answers.push({
            questionId,
            answer,
            isCorrect,
            timestamp: new Date().toISOString()
        });
    }

    /**
     * 결과 요약 생성
     */
    getResultSummary() {
        const practiceAnswers = this.answers.filter(a => a.questionId.startsWith('ex_'));
        const mainAnswers = this.answers.filter(a => a.questionId.startsWith('del_'));

        const practiceCorrect = practiceAnswers.filter(a => a.isCorrect === true).length;
        const mainCorrect = mainAnswers.filter(a => a.isCorrect === true).length;

        return {
            practice: {
                total: practiceAnswers.length,
                correct: practiceCorrect
            },
            main: {
                total: mainAnswers.length,
                correct: mainCorrect
            },
            total: {
                total: this.answers.length,
                correct: practiceCorrect + mainCorrect
            }
        };
    }

    /**
     * 정답 확인 (유사도 기반)
     */
    checkAnswer(recognizedText, correctAnswer) {
        const recognized = recognizedText.trim().toLowerCase();
        const correct = correctAnswer.trim().toLowerCase();

        // 완전 일치
        if (recognized === correct) {
            return true;
        }

        // 유사도 계산 (Levenshtein distance 기반)
        const similarity = this.calculateSimilarity(recognized, correct);
        return similarity >= 0.8; // 80% 이상 유사하면 정답
    }

    /**
     * 문자열 유사도 계산
     */
    calculateSimilarity(s1, s2) {
        if (s1 === s2) return 1.0;
        if (s1.length === 0 || s2.length === 0) return 0.0;

        const distance = this.levenshteinDistance(s1, s2);
        const maxLength = Math.max(s1.length, s2.length);
        return 1.0 - (distance / maxLength);
    }

    /**
     * Levenshtein distance 계산
     */
    levenshteinDistance(s1, s2) {
        if (s1 === s2) return 0;
        if (s1.length === 0) return s2.length;
        if (s2.length === 0) return s1.length;

        const matrix = [];
        for (let i = 0; i <= s2.length; i++) {
            matrix[i] = [i];
        }
        for (let j = 0; j <= s1.length; j++) {
            matrix[0][j] = j;
        }

        for (let i = 1; i <= s2.length; i++) {
            for (let j = 1; j <= s1.length; j++) {
                if (s2.charAt(i - 1) === s1.charAt(j - 1)) {
                    matrix[i][j] = matrix[i - 1][j - 1];
                } else {
                    matrix[i][j] = Math.min(
                        matrix[i - 1][j - 1] + 1,
                        matrix[i][j - 1] + 1,
                        matrix[i - 1][j] + 1
                    );
                }
            }
        }

        return matrix[s2.length][s1.length];
    }
}
