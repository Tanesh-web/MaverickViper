<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Question" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.html");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    Integer currentIndex = (Integer) request.getAttribute("currentIndex");
    if (currentIndex == null) currentIndex = 0;

    String mode = (String) request.getAttribute("mode");
    Integer activeWeek = (Integer) request.getAttribute("activeWeek");

    int totalQuestions = (questions != null) ? questions.size() : 0;
    Question currentQ = (totalQuestions > 0 && currentIndex < totalQuestions) ? questions.get(currentIndex) : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Read MCQs | MAVERICK VIPER</title>
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

        .sidebar {
            width: 260px;
            background: var(--bg-sec);
            border-right: 1px solid var(--burgundy);
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            z-index: 100;
        }

        .sidebar-brand {
            padding: 25px 22px;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 1.5px;
            border-bottom: 1px solid var(--burgundy);
        }

        .sidebar-brand span {
            color: var(--crimson);
        }

        .nav-links {
            list-style: none;
            padding: 20px 0;
            flex: 1;
        }

        .nav-links li a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 13px 22px;
            color: var(--text-sec);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.2s;
            border-left: 3px solid transparent;
        }

        .nav-links li a:hover, .nav-links li a.active {
            color: var(--text-white);
            background: var(--bg-card);
            border-left-color: var(--crimson);
        }

        .user-block {
            padding: 20px;
            border-top: 1px solid var(--burgundy);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .user-info .name {
            font-size: 14px;
            font-weight: 700;
            color: var(--text-white);
        }

        .user-info .role {
            font-size: 11px;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        .logout-btn {
            background: rgba(220, 38, 38, 0.2);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            padding: 6px 12px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
        }

        .main-content {
            margin-left: 260px;
            flex: 1;
            padding: 35px 45px;
        }

        .header-title {
            margin-bottom: 25px;
        }

        .header-title h1 {
            font-size: 28px;
            font-weight: 800;
        }

        .header-title p {
            color: var(--text-sec);
            font-size: 14px;
            margin-top: 4px;
        }

        /* Reading Filter Tabs */
        .mode-tabs {
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .tab-btn {
            padding: 10px 18px;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            color: var(--text-sec);
            text-decoration: none;
            border-radius: 8px;
            font-size: 13.5px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .tab-btn.active {
            background: rgba(168, 50, 80, 0.25);
            border-color: var(--crimson);
            color: var(--text-white);
        }

        /* Dynamic Week Selector Dropdown / Bar */
        .week-bar {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 10px;
            padding: 12px 18px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .week-bar label {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        .week-pill {
            padding: 6px 14px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-sec);
            text-decoration: none;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .week-pill.active {
            background: var(--crimson);
            color: white;
            border-color: var(--crimson);
        }

        /* Reader Layout */
        .reader-layout {
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 25px;
        }

        .question-box {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 35px;
        }

        .meta-tags {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        .tag-pill {
            background: rgba(168, 50, 80, 0.2);
            border: 1px solid var(--crimson);
            color: var(--text-white);
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
        }

        .q-prompt {
            font-size: 18px;
            font-weight: 700;
            line-height: 1.6;
            margin-bottom: 25px;
        }

        .options-container {
            display: flex;
            flex-direction: column;
            gap: 14px;
            margin-bottom: 30px;
        }

        .read-option {
            padding: 15px 18px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 15px;
            transition: all 0.2s;
        }

        .read-option.correct {
            background: rgba(22, 163, 74, 0.15);
            border-color: var(--correct);
            color: #86EFAC;
            font-weight: 700;
            box-shadow: 0 0 15px rgba(22, 163, 74, 0.2);
        }

        .opt-letter {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 13px;
            color: var(--crimson);
            flex-shrink: 0;
        }

        .read-option.correct .opt-letter {
            background: var(--correct);
            color: white;
            border-color: var(--correct);
        }

        .correct-indicator {
            margin-left: auto;
            color: var(--correct);
            font-size: 13px;
            font-weight: 800;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .explanation-box {
            background: var(--bg-main);
            border-left: 4px solid var(--correct);
            padding: 16px 20px;
            border-radius: 0 8px 8px 0;
            margin-bottom: 30px;
            font-size: 14px;
            line-height: 1.6;
        }

        .explanation-box strong {
            color: #86EFAC;
            display: block;
            margin-bottom: 6px;
        }

        /* Navigation Buttons */
        .nav-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid var(--burgundy);
            padding-top: 25px;
        }

        .btn-nav {
            padding: 12px 24px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            text-decoration: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-nav:hover {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        .btn-nav.disabled {
            opacity: 0.4;
            pointer-events: none;
        }

        /* Palette Box */
        .palette-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 22px;
            height: fit-content;
        }

        .palette-card h3 {
            font-size: 15px;
            font-weight: 700;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--burgundy);
        }

        .palette-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 8px;
            max-height: 380px;
            overflow-y: auto;
            padding-right: 5px;
        }

        .palette-item {
            aspect-ratio: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            border-radius: 6px;
            transition: all 0.2s;
        }

        .palette-item:hover {
            border-color: var(--crimson);
        }

        .palette-item.current {
            background: var(--crimson);
            border-color: var(--crimson);
            color: white;
        }

        .study-note {
            margin-top: 20px;
            padding: 12px;
            background: rgba(168, 50, 80, 0.15);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            font-size: 12px;
            color: var(--text-sec);
            line-height: 1.4;
        }

        @media(max-width: 950px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; padding: 20px; }
            .reader-layout { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-brand">
        MAVERICK <span>VIPER</span>
    </div>

    <ul class="nav-links">
        <li><a href="dashboard"><span>📊</span> Dashboard</a></li>
        <li><a href="read-mcqs" class="active"><span>📖</span> Read MCQs</a></li>
        <li><a href="take-test"><span>✍️</span> Give Test</a></li>
        <li><a href="student-performance"><span>📈</span> Performance</a></li>
        <li><a href="student-profile"><span>👤</span> Profile</a></li>
    </ul>

    <div class="user-block">
        <div class="user-info">
            <div class="name"><%= studentName != null ? studentName : "Student" %></div>
            <div class="role">NPTEL Candidate</div>
        </div>
        <a href="logout" class="logout-btn">Logout</a>
    </div>
</aside>

<main class="main-content">
    <div class="header-title">
        <h1>Read MCQs (Study Mode)</h1>
        <p>Browse through questions with revealed correct answers to study concepts and reinforce learning without affecting test statistics.</p>
    </div>

    <!-- Mode Select Tabs -->
    <div class="mode-tabs">
        <a href="read-mcqs?mode=all" class="tab-btn <%= "all".equalsIgnoreCase(mode) ? "active" : "" %>">
            📚 All NPTEL Questions (<%= "all".equalsIgnoreCase(mode) ? totalQuestions : "All" %>)
        </a>
        <a href="read-mcqs?mode=week" class="tab-btn <%= "week".equalsIgnoreCase(mode) ? "active" : "" %>">
            📅 Read Week-Wise MCQs
        </a>
        <a href="read-mcqs?mode=mock" class="tab-btn <%= "mock".equalsIgnoreCase(mode) ? "active" : "" %>">
            🎯 NPTEL Mock Test MCQs
        </a>
    </div>

    <!-- Dynamic Week Selector Bar (if in week mode or switching weeks) -->
    <% if ("week".equalsIgnoreCase(mode) && weeks != null && !weeks.isEmpty()) { %>
        <div class="week-bar">
            <label>Select Syllabus Week:</label>
            <% for (Week w : weeks) { %>
                <a href="read-mcqs?mode=week&week=<%= w.getWeekNumber() %>" class="week-pill <%= (activeWeek != null && activeWeek == w.getWeekNumber()) ? "active" : "" %>">
                    Week <%= w.getWeekNumber() %>
                </a>
            <% } %>
        </div>
    <% } %>

    <% if (currentQ != null) { %>
        <div class="reader-layout">
            <div class="question-box">
                <div class="meta-tags">
                    <span class="tag-pill">Week <%= currentQ.getWeekNumber() %></span>
                    <span class="tag-pill" style="background:var(--bg-sec); border-color:var(--burgundy);"><%= currentQ.getCategory() %></span>
                    <span style="color:var(--text-sec); font-size:13px; margin-left:auto;">
                        Question <%= currentIndex + 1 %> of <%= totalQuestions %>
                    </span>
                </div>

                <div class="q-prompt">
                    <%= (currentIndex + 1) %>. <%= currentQ.getQuestionText() %>
                </div>

                <div class="options-container">
                    <div class="read-option <%= "A".equalsIgnoreCase(currentQ.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">A</span>
                        <span><%= currentQ.getOptionA() %></span>
                        <% if ("A".equalsIgnoreCase(currentQ.getCorrectOption())) { %>
                            <span class="correct-indicator">✓ Correct Option</span>
                        <% } %>
                    </div>

                    <div class="read-option <%= "B".equalsIgnoreCase(currentQ.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">B</span>
                        <span><%= currentQ.getOptionB() %></span>
                        <% if ("B".equalsIgnoreCase(currentQ.getCorrectOption())) { %>
                            <span class="correct-indicator">✓ Correct Option</span>
                        <% } %>
                    </div>

                    <div class="read-option <%= "C".equalsIgnoreCase(currentQ.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">C</span>
                        <span><%= currentQ.getOptionC() %></span>
                        <% if ("C".equalsIgnoreCase(currentQ.getCorrectOption())) { %>
                            <span class="correct-indicator">✓ Correct Option</span>
                        <% } %>
                    </div>

                    <div class="read-option <%= "D".equalsIgnoreCase(currentQ.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">D</span>
                        <span><%= currentQ.getOptionD() %></span>
                        <% if ("D".equalsIgnoreCase(currentQ.getCorrectOption())) { %>
                            <span class="correct-indicator">✓ Correct Option</span>
                        <% } %>
                    </div>
                </div>

                <% if (currentQ.getExplanation() != null && !currentQ.getExplanation().trim().isEmpty()) { %>
                    <div class="explanation-box">
                        <strong>Solution / Reference Explanation:</strong>
                        <%= currentQ.getExplanation() %>
                    </div>
                <% } %>

                <!-- Navigation Controls -->
                <div class="nav-controls">
                    <%
                        String baseNavUrl = "read-mcqs?mode=" + (mode != null ? mode : "all") + (activeWeek != null ? "&week=" + activeWeek : "");
                    %>
                    <a href="<%= baseNavUrl %>&q=<%= currentIndex %>" class="btn-nav <%= currentIndex == 0 ? "disabled" : "" %>">
                        ← Previous Question
                    </a>

                    <span style="color:var(--text-sec); font-size:14px; font-weight:600;">
                        <%= currentIndex + 1 %> / <%= totalQuestions %>
                    </span>

                    <a href="<%= baseNavUrl %>&q=<%= currentIndex + 2 %>" class="btn-nav <%= currentIndex >= totalQuestions - 1 ? "disabled" : "" %>">
                        Next Question →
                    </a>
                </div>
            </div>

            <!-- Question Navigation Palette -->
            <div class="palette-card">
                <h3>Question Navigator (<%= totalQuestions %>)</h3>
                <div class="palette-grid">
                    <% for (int i = 0; i < totalQuestions; i++) { %>
                        <a href="<%= baseNavUrl %>&q=<%= i + 1 %>" class="palette-item <%= i == currentIndex ? "current" : "" %>">
                            <%= i + 1 %>
                        </a>
                    <% } %>
                </div>

                <div class="study-note">
                    💡 <strong>Study Mode:</strong> Correct answers are highlighted in Green. Reading does not record attempts or alter your performance profile.
                </div>
            </div>
        </div>
    <% } else { %>
        <div class="question-box" style="text-align: center; padding: 60px 20px;">
            <div style="font-size: 40px; margin-bottom: 15px;">📚</div>
            <h2>No Questions Available For This Selection</h2>
            <p style="color: var(--text-sec); margin-top: 8px; font-size: 14px;">
                No questions have been uploaded yet for this week or category. Once added via Admin Bulk Upload, they will immediately appear here.
            </p>
        </div>
    <% } %>
</main>

</body>
</html>
