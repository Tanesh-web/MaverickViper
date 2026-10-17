<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Question" %>
<%@ page import="com.maverickviper.model.StudentAnswer" %>
<%@ page import="com.maverickviper.model.TestAttempt" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.html");
        return;
    }

    TestAttempt attempt = (TestAttempt) request.getAttribute("attempt");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Map<Integer, StudentAnswer> answersMap = (Map<Integer, StudentAnswer>) request.getAttribute("answersMap");

    int totalQuestions = (questions != null) ? questions.size() : 0;
    int attemptId = (attempt != null) ? attempt.getAttemptId() : 0;
    String testName = (attempt != null) ? attempt.getTestName() : "NPTEL Examination";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= testName %> | MAVERICK VIPER</title>
    <style>
        :root {
            --bg-main: #16090F;
            --bg-sec: #24121C;
            --bg-card: #321A26;
            --burgundy: #641C35;
            --crimson: #A83250;
            --text-white: #FFFFFF;
            --text-sec: #C9AEB8;
            --correct: #16A34A;
            --wrong: #DC2626;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        }

        body {
            background: var(--bg-main);
            color: var(--text-white);
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* Top Examination Bar */
        .exam-header {
            background: var(--bg-sec);
            border-bottom: 1px solid var(--burgundy);
            padding: 16px 35px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        .exam-title-group {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .exam-logo {
            font-size: 19px;
            font-weight: 800;
            letter-spacing: 1.5px;
        }

        .exam-logo span {
            color: var(--crimson);
        }

        .exam-name {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-white);
            border-left: 2px solid var(--burgundy);
            padding-left: 15px;
        }

        .exam-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .timer-box {
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            padding: 8px 16px;
            font-family: 'Consolas', monospace;
            font-size: 17px;
            font-weight: 800;
            color: #FDE047;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-submit-exam {
            padding: 10px 22px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 15px rgba(168, 50, 80, 0.3);
        }

        .btn-submit-exam:hover {
            opacity: 0.95;
            box-shadow: 0 6px 20px rgba(168, 50, 80, 0.5);
        }

        /* Layout */
        .exam-workspace {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 25px;
            padding: 30px 40px;
            flex: 1;
            max-width: 1500px;
            margin: 0 auto;
            width: 100%;
        }

        /* Question Stage */
        .stage-box {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 35px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .q-meta-line {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 22px;
        }

        .q-indicator {
            font-size: 14px;
            font-weight: 800;
            color: var(--crimson);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .q-status-badge {
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 20px;
            font-weight: 700;
        }

        .status-unanswered {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-sec);
        }

        .status-locked {
            background: rgba(22, 163, 74, 0.15);
            border: 1px solid var(--correct);
            color: #86EFAC;
        }

        .q-prompt-text {
            font-size: 19px;
            font-weight: 700;
            line-height: 1.6;
            margin-bottom: 30px;
            color: var(--text-white);
        }

        /* Options */
        .options-group {
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-bottom: 25px;
        }

        .option-button {
            background: var(--bg-sec);
            border: 2px solid var(--burgundy);
            border-radius: 10px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            cursor: pointer;
            transition: all 0.2s ease;
            text-align: left;
            position: relative;
        }

        .option-button:hover:not(.locked) {
            border-color: var(--crimson);
            background: #2D1422;
        }

        .option-letter {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 14px;
            color: var(--crimson);
            flex-shrink: 0;
            transition: all 0.2s;
        }

        .option-text {
            font-size: 15px;
            font-weight: 500;
            line-height: 1.4;
            color: var(--text-white);
            flex: 1;
        }

        /* MANDATORY INSTANT FEEDBACK HIGHLIGHTS */
        /* CORRECT OPTION: GREEN */
        .option-button.is-correct {
            background: rgba(22, 163, 74, 0.2) !important;
            border-color: var(--correct) !important;
            color: #86EFAC !important;
            box-shadow: 0 0 15px rgba(22, 163, 74, 0.25);
        }

        .option-button.is-correct .option-letter {
            background: var(--correct) !important;
            color: white !important;
            border-color: var(--correct) !important;
        }

        /* WRONG SELECTED OPTION: RED */
        .option-button.is-wrong {
            background: rgba(220, 38, 38, 0.2) !important;
            border-color: var(--wrong) !important;
            color: #FCA5A5 !important;
            box-shadow: 0 0 15px rgba(220, 38, 38, 0.25);
        }

        .option-button.is-wrong .option-letter {
            background: var(--wrong) !important;
            color: white !important;
            border-color: var(--wrong) !important;
        }

        .option-button.locked {
            cursor: default;
        }

        /* Instant Feedback Message Banner */
        .feedback-banner {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 25px;
            display: none;
            font-size: 14.5px;
            font-weight: 700;
            line-height: 1.5;
            animation: fadeIn 0.25s ease;
        }

        .feedback-banner.correct {
            display: block;
            background: rgba(22, 163, 74, 0.15);
            border: 1px solid var(--correct);
            color: #86EFAC;
        }

        .feedback-banner.wrong {
            display: block;
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
        }

        .explanation-text {
            font-size: 13px;
            font-weight: 400;
            color: var(--text-white);
            margin-top: 6px;
        }

        /* Stage Navigation Bottom */
        .stage-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid var(--burgundy);
            padding-top: 25px;
            margin-top: 15px;
        }

        .btn-page {
            padding: 12px 24px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-page:hover:not(:disabled) {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        .btn-page:disabled {
            opacity: 0.35;
            cursor: not-allowed;
        }

        /* Palette Card */
        .palette-panel {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 24px;
            height: fit-content;
        }

        .palette-panel h3 {
            font-size: 16px;
            font-weight: 800;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--burgundy);
        }

        .palette-legend {
            display: flex;
            gap: 15px;
            margin-bottom: 18px;
            font-size: 12px;
            color: var(--text-sec);
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .legend-dot {
            width: 12px;
            height: 12px;
            border-radius: 3px;
        }

        .legend-dot.answered { background: var(--correct); }
        .legend-dot.unanswered { background: #472635; }
        .legend-dot.current { background: var(--crimson); }

        .palette-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 8px;
            max-height: 420px;
            overflow-y: auto;
            padding-right: 5px;
        }

        .palette-btn {
            aspect-ratio: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #472635;
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            font-size: 13.5px;
            font-weight: 700;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .palette-btn:hover {
            border-color: var(--crimson);
        }

        .palette-btn.answered {
            background: rgba(22, 163, 74, 0.25);
            border-color: var(--correct);
            color: #86EFAC;
        }

        .palette-btn.current {
            background: var(--crimson) !important;
            border-color: var(--crimson) !important;
            color: white !important;
            box-shadow: 0 0 10px rgba(168, 50, 80, 0.6);
        }

        /* Modal */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; width: 100vw; height: 100vh;
            background: rgba(0, 0, 0, 0.8);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        .modal-box {
            background: var(--bg-sec);
            border: 1px solid var(--crimson);
            border-radius: 14px;
            padding: 35px;
            max-width: 480px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.7);
        }

        .modal-box h2 {
            font-size: 22px;
            margin-bottom: 12px;
        }

        .modal-box p {
            color: var(--text-sec);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .modal-btns {
            display: flex;
            gap: 15px;
            justify-content: center;
        }

        .btn-confirm {
            padding: 12px 28px;
            background: #16A34A;
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            cursor: pointer;
        }

        .btn-dismiss {
            padding: 12px 24px;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 8px;
            font-weight: 700;
            cursor: pointer;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-4px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media(max-width: 950px) {
            .exam-workspace { grid-template-columns: 1fr; padding: 20px; }
            .exam-header { padding: 12px 20px; }
            .exam-name { display: none; }
        }
    </style>
</head>
<body>

<!-- Top Exam Header -->
<header class="exam-header">
    <div class="exam-title-group">
        <div class="exam-logo">MAVERICK <span>VIPER</span></div>
        <div class="exam-name"><%= testName %></div>
    </div>

    <div class="exam-actions">
        <div class="timer-box">
            <span>⏱️</span>
            <span id="timerDisplay">30:00</span>
        </div>

        <button type="button" class="btn-submit-exam" onclick="confirmSubmit()">Submit Test</button>
    </div>
</header>

<!-- Main Workspace -->
<main class="exam-workspace">
    <!-- Active Question Stage -->
    <div class="stage-box">
        <% if (questions != null && !questions.isEmpty()) {
            for (int i = 0; i < questions.size(); i++) {
                Question q = questions.get(i);
                StudentAnswer sa = (answersMap != null) ? answersMap.get(q.getQuestionId()) : null;
                boolean isAnswered = (sa != null);
                String selectedOpt = isAnswered ? sa.getSelectedOption() : "";
                String correctOpt = isAnswered ? sa.getCorrectOptionSnapshot() : q.getCorrectOption();
                boolean isCorrect = isAnswered && sa.isCorrect();
        %>
            <div id="q_card_<%= i %>" class="question-card" style="<%= i == 0 ? "display:block;" : "display:none;" %>"
                 data-qid="<%= q.getQuestionId() %>"
                 data-answered="<%= isAnswered ? "true" : "false" %>"
                 data-correct-opt="<%= correctOpt %>">

                <div class="q-meta-line">
                    <span class="q-indicator">Question <%= i + 1 %> of <%= totalQuestions %></span>
                    <span id="badge_<%= i %>" class="q-status-badge <%= isAnswered ? "status-locked" : "status-unanswered" %>">
                        <%= isAnswered ? "Answer Locked" : "Unanswered" %>
                    </span>
                </div>

                <!-- Instant Feedback Banner -->
                <div id="feedback_<%= i %>" class="feedback-banner <%= isAnswered ? (isCorrect ? "correct" : "wrong") : "" %>">
                    <% if (isAnswered) { %>
                        <%= isCorrect ? "✓ Correct Answer!" : "✗ Incorrect Answer! Correct is Option " + correctOpt %>
                        <% if (sa.getExplanationSnapshot() != null && !sa.getExplanationSnapshot().trim().isEmpty()) { %>
                            <div class="explanation-text"><%= sa.getExplanationSnapshot() %></div>
                        <% } %>
                    <% } %>
                </div>

                <div class="q-prompt-text">
                    <%= (i + 1) %>. <%= q.getQuestionText() %>
                </div>

                <!-- 4 Options -->
                <div class="options-group">
                    <!-- Option A -->
                    <%
                        String clsA = "";
                        if (isAnswered) {
                            clsA += " locked";
                            if ("A".equalsIgnoreCase(correctOpt)) clsA += " is-correct";
                            if ("A".equalsIgnoreCase(selectedOpt) && !isCorrect) clsA += " is-wrong";
                        }
                    %>
                    <div id="opt_btn_<%= i %>_A" class="option-button <%= clsA %>" onclick="selectOption(<%= i %>, <%= q.getQuestionId() %>, 'A')">
                        <div class="option-letter">A</div>
                        <div class="option-text"><%= q.getOptionA() %></div>
                    </div>

                    <!-- Option B -->
                    <%
                        String clsB = "";
                        if (isAnswered) {
                            clsB += " locked";
                            if ("B".equalsIgnoreCase(correctOpt)) clsB += " is-correct";
                            if ("B".equalsIgnoreCase(selectedOpt) && !isCorrect) clsB += " is-wrong";
                        }
                    %>
                    <div id="opt_btn_<%= i %>_B" class="option-button <%= clsB %>" onclick="selectOption(<%= i %>, <%= q.getQuestionId() %>, 'B')">
                        <div class="option-letter">B</div>
                        <div class="option-text"><%= q.getOptionB() %></div>
                    </div>

                    <!-- Option C -->
                    <%
                        String clsC = "";
                        if (isAnswered) {
                            clsC += " locked";
                            if ("C".equalsIgnoreCase(correctOpt)) clsC += " is-correct";
                            if ("C".equalsIgnoreCase(selectedOpt) && !isCorrect) clsC += " is-wrong";
                        }
                    %>
                    <div id="opt_btn_<%= i %>_C" class="option-button <%= clsC %>" onclick="selectOption(<%= i %>, <%= q.getQuestionId() %>, 'C')">
                        <div class="option-letter">C</div>
                        <div class="option-text"><%= q.getOptionC() %></div>
                    </div>

                    <!-- Option D -->
                    <%
                        String clsD = "";
                        if (isAnswered) {
                            clsD += " locked";
                            if ("D".equalsIgnoreCase(correctOpt)) clsD += " is-correct";
                            if ("D".equalsIgnoreCase(selectedOpt) && !isCorrect) clsD += " is-wrong";
                        }
                    %>
                    <div id="opt_btn_<%= i %>_D" class="option-button <%= clsD %>" onclick="selectOption(<%= i %>, <%= q.getQuestionId() %>, 'D')">
                        <div class="option-letter">D</div>
                        <div class="option-text"><%= q.getOptionD() %></div>
                    </div>
                </div>

            </div>
        <%  }
           } %>

        <!-- Navigation Controls -->
        <div class="stage-footer">
            <button type="button" id="btnPrev" class="btn-page" onclick="prevQuestion()" disabled>← Previous</button>

            <span id="pageIndicator" style="font-size:14px; font-weight:700; color:var(--text-sec);">
                1 / <%= totalQuestions %>
            </span>

            <button type="button" id="btnNext" class="btn-page" onclick="nextQuestion()">Next →</button>
        </div>
    </div>

    <!-- Question Navigator Palette -->
    <aside class="palette-panel">
        <h3>Question Navigator</h3>

        <div class="palette-legend">
            <div class="legend-item"><div class="legend-dot current"></div> Current</div>
            <div class="legend-item"><div class="legend-dot answered"></div> Answered</div>
            <div class="legend-item"><div class="legend-dot unanswered"></div> Unanswered</div>
        </div>

        <div class="palette-grid">
            <% if (questions != null) {
                for (int i = 0; i < questions.size(); i++) {
                    Question q = questions.get(i);
                    boolean isAns = (answersMap != null && answersMap.containsKey(q.getQuestionId()));
            %>
                <button type="button" id="palette_btn_<%= i %>" 
                        class="palette-btn <%= i == 0 ? "current" : "" %> <%= isAns ? "answered" : "" %>"
                        onclick="jumpToQuestion(<%= i %>)">
                    <%= i + 1 %>
                </button>
            <%  }
               } %>
        </div>

        <div style="margin-top:20px; font-size:12px; color:var(--text-sec); line-height:1.5;">
            💡 <strong>Instant Feedback:</strong> Selecting an answer locks your choice and reveals the correct answer immediately. Previous answers and feedback remain preserved when navigating back and forth.
        </div>
    </aside>
</main>

<!-- Hidden Final Submit Form -->
<form id="submitTestForm" action="submit-test" method="post" style="display:none;">
    <input type="hidden" name="attemptId" value="<%= attemptId %>">
</form>

<!-- Confirmation Modal -->
<div id="confirmModal" class="modal-overlay">
    <div class="modal-box">
        <h2>Submit Examination?</h2>
        <p id="modalSummary">Are you sure you want to finalize your test and view your full performance score report?</p>
        <div class="modal-btns">
            <button type="button" class="btn-dismiss" onclick="closeModal()">Continue Test</button>
            <button type="button" class="btn-confirm" onclick="executeSubmit()">Confirm & Submit</button>
        </div>
    </div>
</div>

<script>
    const ATTEMPT_ID = <%= attemptId %>;
    const TOTAL_QUESTIONS = <%= totalQuestions %>;
    let currentIndex = 0;

    // Track answered state in client memory
    const answeredState = {};
    <% if (questions != null) {
        for (int i = 0; i < questions.size(); i++) {
            Question q = questions.get(i);
            boolean isAns = (answersMap != null && answersMap.containsKey(q.getQuestionId()));
            if (isAns) { %>
                answeredState[<%= i %>] = true;
    <%      }
        }
    } %>

    function updateNavButtons() {
        document.getElementById('btnPrev').disabled = (currentIndex === 0);
        document.getElementById('btnNext').disabled = (currentIndex === TOTAL_QUESTIONS - 1);
        document.getElementById('pageIndicator').textContent = (currentIndex + 1) + ' / ' + TOTAL_QUESTIONS;

        // Update palette current highlight
        for (let i = 0; i < TOTAL_QUESTIONS; i++) {
            const pBtn = document.getElementById('palette_btn_' + i);
            if (pBtn) {
                if (i === currentIndex) {
                    pBtn.classList.add('current');
                } else {
                    pBtn.classList.remove('current');
                }
            }
        }
    }

    function jumpToQuestion(targetIndex) {
        if (targetIndex < 0 || targetIndex >= TOTAL_QUESTIONS) return;

        // Hide current
        const curCard = document.getElementById('q_card_' + currentIndex);
        if (curCard) curCard.style.display = 'none';

        // Show target
        currentIndex = targetIndex;
        const targetCard = document.getElementById('q_card_' + currentIndex);
        if (targetCard) targetCard.style.display = 'block';

        updateNavButtons();
    }

    function nextQuestion() {
        if (currentIndex < TOTAL_QUESTIONS - 1) {
            jumpToQuestion(currentIndex + 1);
        }
    }

    function prevQuestion() {
        if (currentIndex > 0) {
            jumpToQuestion(currentIndex - 1);
        }
    }

    // MANDATORY INSTANT ANSWER FEEDBACK FUNCTION
    function selectOption(qIndex, questionId, selectedLetter) {
        if (answeredState[qIndex]) {
            return; // Already locked
        }

        // Lock immediately to prevent duplicate clicks
        answeredState[qIndex] = true;

        // Call backend server verification endpoint
        const formData = new URLSearchParams();
        formData.append('attemptId', ATTEMPT_ID);
        formData.append('questionId', questionId);
        formData.append('selectedOption', selectedLetter);

        fetch('api/check-answer', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                applyAnswerFeedback(qIndex, selectedLetter, data.correctOption, data.isCorrect, data.explanation);
            } else {
                console.error("Verification error:", data.error);
            }
        })
        .catch(err => {
            console.error("Network error:", err);
        });
    }

    function applyAnswerFeedback(qIndex, selectedOpt, correctOpt, isCorrect, explanation) {
        const letters = ['A', 'B', 'C', 'D'];

        // Apply lock and feedback styling to options
        letters.forEach(l => {
            const btn = document.getElementById('opt_btn_' + qIndex + '_' + l);
            if (btn) {
                btn.classList.add('locked');

                // If correct option: GREEN
                if (l.toUpperCase() === correctOpt.toUpperCase()) {
                    btn.classList.add('is-correct');
                }

                // If chosen wrong option: RED
                if (!isCorrect && l.toUpperCase() === selectedOpt.toUpperCase()) {
                    btn.classList.add('is-wrong');
                }
            }
        });

        // Show Instant Feedback Banner
        const banner = document.getElementById('feedback_' + qIndex);
        if (banner) {
            if (isCorrect) {
                banner.className = 'feedback-banner correct';
                banner.innerHTML = '✓ Correct Answer!' + (explanation ? '<div class="explanation-text">' + explanation + '</div>' : '');
            } else {
                banner.className = 'feedback-banner wrong';
                banner.innerHTML = '✗ Incorrect Answer! Correct is Option ' + correctOpt + (explanation ? '<div class="explanation-text">' + explanation + '</div>' : '');
            }
        }

        // Update badge
        const badge = document.getElementById('badge_' + qIndex);
        if (badge) {
            badge.className = 'q-status-badge status-locked';
            badge.textContent = 'Answer Locked';
        }

        // Update palette item to Answered
        const pBtn = document.getElementById('palette_btn_' + qIndex);
        if (pBtn) {
            pBtn.classList.add('answered');
        }
    }

    // Modal Confirmation & Submit
    function confirmSubmit() {
        let answeredCount = Object.keys(answeredState).length;
        let unansweredCount = TOTAL_QUESTIONS - answeredCount;
        document.getElementById('modalSummary').textContent = 
            `You have answered ${answeredCount} of ${TOTAL_QUESTIONS} questions (${unansweredCount} unanswered). Once submitted, your score will be calculated and saved.`;
        document.getElementById('confirmModal').style.display = 'flex';
    }

    function closeModal() {
        document.getElementById('confirmModal').style.display = 'none';
    }

    function executeSubmit() {
        document.getElementById('submitTestForm').submit();
    }

    // Countdown Timer (30 minutes default)
    let totalSeconds = 30 * 60;
    const timerDisplay = document.getElementById('timerDisplay');
    const countdown = setInterval(() => {
        totalSeconds--;
        if (totalSeconds <= 0) {
            clearInterval(countdown);
            executeSubmit(); // Auto-submit when time expires
        }
        const m = Math.floor(totalSeconds / 60);
        const s = totalSeconds % 60;
        timerDisplay.textContent = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
        if (totalSeconds < 300) {
            timerDisplay.style.color = '#DC2626'; // Alert in red when under 5 mins
        }
    }, 1000);

    // Initial setup
    updateNavButtons();
</script>

</body>
</html>
