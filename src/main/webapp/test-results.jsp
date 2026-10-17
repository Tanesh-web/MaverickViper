<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.TestAttempt" %>
<%@ page import="com.maverickviper.model.StudentAnswer" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    TestAttempt attempt = (TestAttempt) request.getAttribute("attempt");
    List<StudentAnswer> answers = (List<StudentAnswer>) request.getAttribute("answers");

    if (attempt == null) {
        response.sendRedirect("take-test");
        return;
    }

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    String formattedDate = (attempt.getCompletedAt() != null) ? sdf.format(attempt.getCompletedAt()) :
                           ((attempt.getStartedAt() != null) ? sdf.format(attempt.getStartedAt()) : "N/A");

    boolean isAdmin = (session.getAttribute("adminId") != null);
    String studentName = (String) session.getAttribute("studentName");
    if (studentName == null) studentName = "Student";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Results | <%= attempt.getTestName() %> | MAVERICK VIPER</title>
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
            min-height: 100vh;
        }

        /* Sidebar Navigation */
        .sidebar {
            width: 260px;
            background: var(--bg-sec);
            border-right: 1px solid var(--burgundy);
            padding: 28px 20px;
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
        }

        .logo {
            font-size: 22px;
            font-weight: 800;
            letter-spacing: 2px;
            margin-bottom: 4px;
        }

        .logo span {
            color: var(--crimson);
        }

        .course-tag {
            font-size: 11px;
            color: var(--text-sec);
            text-transform: uppercase;
            letter-spacing: 1.2px;
            margin-bottom: 35px;
            border-bottom: 1px solid var(--burgundy);
            padding-bottom: 16px;
        }

        .nav-links {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
            flex-grow: 1;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: var(--text-sec);
            text-decoration: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        .nav-link:hover, .nav-link.active {
            background: var(--bg-card);
            color: var(--text-white);
            border: 1px solid var(--burgundy);
        }

        .nav-link.active {
            border-left: 3px solid var(--crimson);
        }

        .user-block {
            padding-top: 20px;
            border-top: 1px solid var(--burgundy);
            font-size: 13px;
        }

        .user-name {
            font-weight: 700;
            color: var(--text-white);
        }

        .user-role {
            color: var(--text-sec);
            font-size: 11px;
            margin-bottom: 12px;
        }

        .logout-btn {
            display: block;
            text-align: center;
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            padding: 8px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: background 0.2s;
        }

        .logout-btn:hover {
            background: rgba(220, 38, 38, 0.3);
        }

        /* Main Content */
        .content {
            flex-grow: 1;
            padding: 35px 45px;
            overflow-y: auto;
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 30px;
        }

        .header-section h1 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .test-meta {
            font-size: 14px;
            color: var(--text-sec);
            display: flex;
            gap: 20px;
        }

        .header-actions {
            display: flex;
            gap: 12px;
        }

        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: #FFFFFF;
            border: none;
        }

        .btn-primary:hover {
            opacity: 0.95;
            transform: translateY(-1px);
        }

        .btn-secondary {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
        }

        .btn-secondary:hover {
            border-color: var(--crimson);
        }

        /* Performance Metrics Grid */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
            gap: 16px;
            margin-bottom: 35px;
        }

        .metric-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .metric-title {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-sec);
            font-weight: 600;
        }

        .metric-value {
            font-size: 26px;
            font-weight: 800;
            color: var(--text-white);
        }

        .metric-card.correct {
            border-left: 4px solid var(--correct);
        }
        .metric-card.correct .metric-value {
            color: #86EFAC;
        }

        .metric-card.wrong {
            border-left: 4px solid var(--wrong);
        }
        .metric-card.wrong .metric-value {
            color: #FCA5A5;
        }

        .metric-card.score {
            border-left: 4px solid var(--crimson);
            background: linear-gradient(135deg, rgba(100,28,53,0.3), rgba(168,50,80,0.15));
        }
        .metric-card.score .metric-value {
            color: #FFFFFF;
        }

        /* Review Section */
        .review-section {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 28px;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .review-title {
            font-size: 20px;
            font-weight: 700;
        }

        /* Filter Tabs */
        .filter-tabs {
            display: flex;
            gap: 8px;
            background: var(--bg-main);
            padding: 4px;
            border-radius: 8px;
            border: 1px solid var(--burgundy);
        }

        .tab-btn {
            background: transparent;
            border: none;
            color: var(--text-sec);
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .tab-btn:hover {
            color: var(--text-white);
        }

        .tab-btn.active {
            background: var(--burgundy);
            color: var(--text-white);
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }

        /* Answer Review Cards */
        .answers-list {
            display: flex;
            flex-direction: column;
            gap: 22px;
        }

        .review-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 22px 24px;
            transition: border-color 0.2s;
        }

        .review-card.status-correct {
            border-left: 4px solid var(--correct);
        }

        .review-card.status-wrong {
            border-left: 4px solid var(--wrong);
        }

        .review-card.status-unanswered {
            border-left: 4px solid #6B7280;
        }

        .q-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .q-num {
            font-size: 13px;
            font-weight: 700;
            color: var(--crimson);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .badge-status {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-status.correct {
            background: rgba(22, 163, 74, 0.2);
            border: 1px solid var(--correct);
            color: #86EFAC;
        }

        .badge-status.wrong {
            background: rgba(220, 38, 38, 0.2);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
        }

        .badge-status.unanswered {
            background: rgba(107, 114, 128, 0.2);
            border: 1px solid #6B7280;
            color: #D1D5DB;
        }

        .question-text {
            font-size: 16px;
            font-weight: 600;
            line-height: 1.5;
            margin-bottom: 18px;
            color: var(--text-white);
        }

        .options-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 10px;
            margin-bottom: 16px;
        }

        .opt-row {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 12px 16px;
            border-radius: 8px;
            background: var(--bg-sec);
            border: 1px solid transparent;
            font-size: 14px;
        }

        .opt-row.is-correct {
            background: rgba(22, 163, 74, 0.15);
            border-color: var(--correct);
            color: #FFFFFF;
        }

        .opt-row.is-selected-wrong {
            background: rgba(220, 38, 38, 0.15);
            border-color: var(--wrong);
            color: #FFFFFF;
        }

        .opt-letter {
            width: 28px;
            height: 28px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 800;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            flex-shrink: 0;
        }

        .opt-row.is-correct .opt-letter {
            background: var(--correct);
            border-color: var(--correct);
            color: #FFFFFF;
        }

        .opt-row.is-selected-wrong .opt-letter {
            background: var(--wrong);
            border-color: var(--wrong);
            color: #FFFFFF;
        }

        .opt-content {
            flex-grow: 1;
        }

        .opt-tag {
            font-size: 11px;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-left: 8px;
        }

        .opt-tag.correct-tag {
            background: var(--correct);
            color: #FFFFFF;
        }

        .opt-tag.wrong-tag {
            background: var(--wrong);
            color: #FFFFFF;
        }

        .explanation-box {
            background: var(--bg-sec);
            border-left: 3px solid var(--crimson);
            padding: 14px 18px;
            border-radius: 6px;
            font-size: 13px;
            line-height: 1.5;
            color: var(--text-sec);
            margin-top: 10px;
        }

        .explanation-box strong {
            color: var(--text-white);
            display: block;
            margin-bottom: 4px;
        }

        @media (max-width: 900px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; border-right: none; border-bottom: 1px solid var(--burgundy); }
            .content { padding: 20px; }
            .header-section { flex-direction: column; gap: 15px; }
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<aside class="sidebar">
    <div class="logo">MAVERICK <span>VIPER</span></div>
    <div class="course-tag">Foundation of Digital Business</div>

    <ul class="nav-links">
        <% if (isAdmin) { %>
            <li><a href="admin-dashboard" class="nav-link"><span>📊</span> Admin Overview</a></li>
            <li><a href="admin-students" class="nav-link"><span>👥</span> Students Dossier</a></li>
            <li><a href="admin-questions" class="nav-link"><span>❓</span> Question Bank</a></li>
            <li><a href="admin-weeks" class="nav-link"><span>📅</span> Dynamic Weeks</a></li>
        <% } else { %>
            <li><a href="dashboard" class="nav-link"><span>📊</span> Dashboard</a></li>
            <li><a href="read-mcqs" class="nav-link"><span>📖</span> Read MCQs</a></li>
            <li><a href="take-test" class="nav-link"><span>✍️</span> Give Test</a></li>
            <li><a href="student-performance" class="nav-link active"><span>📈</span> Performance</a></li>
            <li><a href="student-profile" class="nav-link"><span>👤</span> My Profile</a></li>
        <% } %>
    </ul>

    <div class="user-block">
        <div class="user-name"><%= studentName %></div>
        <div class="user-role"><%= isAdmin ? "ADMINISTRATOR" : "STUDENT" %></div>
        <a href="<%= isAdmin ? "admin-logout" : "logout" %>" class="logout-btn">Sign Out</a>
    </div>
</aside>

<!-- Main Results Content -->
<main class="content">
    <div class="header-section">
        <div>
            <h1>Performance Score Report</h1>
            <div class="test-meta">
                <span>📝 Test: <strong><%= attempt.getTestName() %></strong></span>
                <span>⏱️ Completed: <strong><%= formattedDate %></strong></span>
                <span>🏷️ Mode: <strong><%= attempt.getTestType() %></strong></span>
            </div>
        </div>

        <div class="header-actions">
            <% if (!isAdmin) { %>
                <a href="take-test" class="btn-action btn-secondary">← Take Another Test</a>
                <a href="student-performance" class="btn-action btn-primary">📈 Overall Analytics</a>
            <% } else { %>
                <a href="admin-students" class="btn-action btn-secondary">← Back to Students</a>
            <% } %>
        </div>
    </div>

    <!-- Metrics Summary Grid -->
    <div class="metrics-grid">
        <div class="metric-card score">
            <span class="metric-title">Score Obtained</span>
            <span class="metric-value"><%= attempt.getScore() %> / <%= attempt.getTotalQuestions() %></span>
        </div>

        <div class="metric-card">
            <span class="metric-title">Percentage</span>
            <span class="metric-value"><%= attempt.getPercentage() %>%</span>
        </div>

        <div class="metric-card">
            <span class="metric-title">Accuracy Rate</span>
            <span class="metric-value"><%= attempt.getAccuracy() %>%</span>
        </div>

        <div class="metric-card">
            <span class="metric-title">Total Questions</span>
            <span class="metric-value"><%= attempt.getTotalQuestions() %></span>
        </div>

        <div class="metric-card correct">
            <span class="metric-title">Correct Answers</span>
            <span class="metric-value">✓ <%= attempt.getCorrect() %></span>
        </div>

        <div class="metric-card wrong">
            <span class="metric-title">Incorrect Answers</span>
            <span class="metric-value">✗ <%= attempt.getIncorrect() %></span>
        </div>

        <div class="metric-card">
            <span class="metric-title">Unanswered</span>
            <span class="metric-value">⚪ <%= attempt.getUnanswered() %></span>
        </div>
    </div>

    <!-- Review Section -->
    <section class="review-section">
        <div class="review-header">
            <div class="review-title">Detailed Question Review & Explanations</div>

            <!-- Review Filter Tabs -->
            <div class="filter-tabs">
                <button type="button" class="tab-btn active" onclick="filterReview('ALL')">All (<%= answers != null ? answers.size() : 0 %>)</button>
                <button type="button" class="tab-btn" onclick="filterReview('CORRECT')">Correct (<%= attempt.getCorrect() %>)</button>
                <button type="button" class="tab-btn" onclick="filterReview('INCORRECT')">Incorrect (<%= attempt.getIncorrect() %>)</button>
                <button type="button" class="tab-btn" onclick="filterReview('UNANSWERED')">Unanswered (<%= attempt.getUnanswered() %>)</button>
            </div>
        </div>

        <!-- Answers List -->
        <div class="answers-list">
            <% if (answers != null && !answers.isEmpty()) {
                for (int i = 0; i < answers.size(); i++) {
                    StudentAnswer a = answers.get(i);
                    boolean isAnswered = (a.getSelectedOption() != null && !a.getSelectedOption().trim().isEmpty());
                    boolean isCorrect = a.isCorrect();
                    String cardStatus = isAnswered ? (isCorrect ? "CORRECT" : "INCORRECT") : "UNANSWERED";

                    String correctLetter = (a.getCorrectOptionSnapshot() != null) ? a.getCorrectOptionSnapshot().trim().toUpperCase() : "";
                    String selectedLetter = isAnswered ? a.getSelectedOption().trim().toUpperCase() : "";
            %>
                <div class="review-card status-<%= cardStatus.toLowerCase() %>" data-status="<%= cardStatus %>">
                    <div class="q-header-row">
                        <span class="q-num">Question <%= i + 1 %></span>
                        <% if (isCorrect) { %>
                            <span class="badge-status correct">✓ Correct</span>
                        <% } else if (isAnswered) { %>
                            <span class="badge-status wrong">✗ Incorrect</span>
                        <% } else { %>
                            <span class="badge-status unanswered">⚪ Unanswered</span>
                        <% } %>
                    </div>

                    <div class="question-text">
                        <%= a.getQuestionTextSnapshot() %>
                    </div>

                    <div class="options-container">
                        <!-- Option A -->
                        <%
                            boolean isA_Correct = "A".equalsIgnoreCase(correctLetter);
                            boolean isA_Selected = "A".equalsIgnoreCase(selectedLetter);
                            String clsA = isA_Correct ? "is-correct" : (isA_Selected && !isCorrect ? "is-selected-wrong" : "");
                        %>
                        <div class="opt-row <%= clsA %>">
                            <div class="opt-letter">A</div>
                            <div class="opt-content"><%= a.getOptionASnapshot() %></div>
                            <% if (isA_Correct) { %><span class="opt-tag correct-tag">Correct Answer</span><% } %>
                            <% if (isA_Selected && !isCorrect) { %><span class="opt-tag wrong-tag">Your Selection</span><% } %>
                        </div>

                        <!-- Option B -->
                        <%
                            boolean isB_Correct = "B".equalsIgnoreCase(correctLetter);
                            boolean isB_Selected = "B".equalsIgnoreCase(selectedLetter);
                            String clsB = isB_Correct ? "is-correct" : (isB_Selected && !isCorrect ? "is-selected-wrong" : "");
                        %>
                        <div class="opt-row <%= clsB %>">
                            <div class="opt-letter">B</div>
                            <div class="opt-content"><%= a.getOptionBSnapshot() %></div>
                            <% if (isB_Correct) { %><span class="opt-tag correct-tag">Correct Answer</span><% } %>
                            <% if (isB_Selected && !isCorrect) { %><span class="opt-tag wrong-tag">Your Selection</span><% } %>
                        </div>

                        <!-- Option C -->
                        <%
                            boolean isC_Correct = "C".equalsIgnoreCase(correctLetter);
                            boolean isC_Selected = "C".equalsIgnoreCase(selectedLetter);
                            String clsC = isC_Correct ? "is-correct" : (isC_Selected && !isCorrect ? "is-selected-wrong" : "");
                        %>
                        <div class="opt-row <%= clsC %>">
                            <div class="opt-letter">C</div>
                            <div class="opt-content"><%= a.getOptionCSnapshot() %></div>
                            <% if (isC_Correct) { %><span class="opt-tag correct-tag">Correct Answer</span><% } %>
                            <% if (isC_Selected && !isCorrect) { %><span class="opt-tag wrong-tag">Your Selection</span><% } %>
                        </div>

                        <!-- Option D -->
                        <%
                            boolean isD_Correct = "D".equalsIgnoreCase(correctLetter);
                            boolean isD_Selected = "D".equalsIgnoreCase(selectedLetter);
                            String clsD = isD_Correct ? "is-correct" : (isD_Selected && !isCorrect ? "is-selected-wrong" : "");
                        %>
                        <div class="opt-row <%= clsD %>">
                            <div class="opt-letter">D</div>
                            <div class="opt-content"><%= a.getOptionDSnapshot() %></div>
                            <% if (isD_Correct) { %><span class="opt-tag correct-tag">Correct Answer</span><% } %>
                            <% if (isD_Selected && !isCorrect) { %><span class="opt-tag wrong-tag">Your Selection</span><% } %>
                        </div>
                    </div>

                    <% if (a.getExplanationSnapshot() != null && !a.getExplanationSnapshot().trim().isEmpty()) { %>
                        <div class="explanation-box">
                            <strong>💡 Conceptual Explanation:</strong>
                            <%= a.getExplanationSnapshot() %>
                        </div>
                    <% } %>
                </div>
            <%  }
               } else { %>
                <div style="text-align:center; padding: 40px; color:var(--text-sec);">
                    No questions recorded for this test attempt.
                </div>
            <% } %>
        </div>
    </section>
</main>

<script>
    function filterReview(type) {
        // Update tab buttons
        const tabs = document.querySelectorAll('.tab-btn');
        tabs.forEach(t => t.classList.remove('active'));
        event.target.classList.add('active');

        // Filter cards
        const cards = document.querySelectorAll('.review-card');
        cards.forEach(card => {
            const status = card.getAttribute('data-status');
            if (type === 'ALL') {
                card.style.display = 'block';
            } else if (type === status) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }
</script>

</body>
</html>
