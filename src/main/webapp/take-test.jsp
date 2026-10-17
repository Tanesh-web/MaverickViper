<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.html");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");
    if (totalQuestions == null) totalQuestions = 0;

    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Center | MAVERICK VIPER</title>
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

        .instant-feedback-banner {
            background: linear-gradient(135deg, rgba(22, 163, 74, 0.15), rgba(100, 28, 53, 0.25));
            border: 1px solid var(--correct);
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .banner-icon {
            font-size: 36px;
        }

        .banner-text h3 {
            color: #86EFAC;
            font-size: 16px;
            margin-bottom: 4px;
            font-weight: 800;
        }

        .banner-text p {
            color: var(--text-white);
            font-size: 13.5px;
            line-height: 1.5;
        }

        .alert-error {
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            padding: 14px 18px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .test-modes-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 25px;
        }

        .test-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 30px 26px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s;
        }

        .test-card:hover {
            transform: translateY(-3px);
            border-color: var(--crimson);
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
        }

        .test-icon {
            font-size: 38px;
            margin-bottom: 15px;
        }

        .test-card h2 {
            font-size: 20px;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .test-card p {
            color: var(--text-sec);
            font-size: 13.5px;
            line-height: 1.6;
            margin-bottom: 22px;
            flex: 1;
        }

        .mode-features {
            list-style: none;
            margin-bottom: 25px;
        }

        .mode-features li {
            font-size: 12.5px;
            color: var(--text-sec);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .mode-features li span {
            color: #86EFAC;
            font-weight: bold;
        }

        .btn-start {
            display: block;
            text-align: center;
            padding: 13px 20px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 15px rgba(168, 50, 80, 0.3);
        }

        .btn-start:hover {
            opacity: 0.95;
            box-shadow: 0 6px 20px rgba(168, 50, 80, 0.45);
        }

        select, input[type="number"] {
            width: 100%;
            padding: 11px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 7px;
            color: var(--text-white);
            font-size: 13.5px;
            margin-bottom: 18px;
            outline: none;
        }

        select:focus, input:focus {
            border-color: var(--crimson);
        }

        @media(max-width: 1100px) {
            .test-modes-grid { grid-template-columns: 1fr; }
        }

        @media(max-width: 900px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; padding: 20px; }
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
        <li><a href="read-mcqs"><span>📖</span> Read MCQs</a></li>
        <li><a href="take-test" class="active"><span>✍️</span> Give Test</a></li>
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
        <h1>Examination Center</h1>
        <p>Select your testing mode. Practice under real exam conditions with instantaneous feedback.</p>
    </div>

    <!-- Mandatory Feature Highlight Banner -->
    <div class="instant-feedback-banner">
        <div class="banner-icon">⚡</div>
        <div class="banner-text">
            <h3>Instant Answer Feedback Active Across All Modes</h3>
            <p>Every test mode provides immediate verification! Selecting an option immediately shows whether you answered <strong>Correctly (Green)</strong> or <strong>Incorrectly (Red)</strong>, locks your choice, and saves your progress to your performance dossier.</p>
        </div>
    </div>

    <% if ("no_questions".equals(error)) { %>
        <div class="alert-error">No questions are currently available for the selected test. Please try another test mode or week.</div>
    <% } %>

    <div class="test-modes-grid">
        <!-- MODE A: ALL MCQ TEST -->
        <div class="test-card">
            <div>
                <div class="test-icon">🏆</div>
                <h2>Mode A: All MCQ Test</h2>
                <p>Combines all week-wise questions and NPTEL mock test MCQs into one comprehensive full-syllabus examination.</p>

                <ul class="mode-features">
                    <li><span>✓</span> Full repository coverage (<%= totalQuestions %> MCQs)</li>
                    <li><span>✓</span> Instant correct/wrong answer reveal</li>
                    <li><span>✓</span> Real-time question lock on answer</li>
                    <li><span>✓</span> Detailed post-test review analysis</li>
                </ul>
            </div>

            <a href="take-test?mode=ALL_MCQ" class="btn-start">Start All MCQ Test →</a>
        </div>

        <!-- MODE B: WEEK-WISE TEST -->
        <div class="test-card">
            <form action="take-test" method="get">
                <input type="hidden" name="mode" value="WEEK_WISE">
                <div>
                    <div class="test-icon">📅</div>
                    <h2>Mode B: Week-Wise Test</h2>
                    <p>Focus on individual syllabus weeks. Tests you strictly on the selected module topics and weekly assignment questions.</p>

                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-sec); margin-bottom:6px; text-transform:uppercase;">
                        Choose NPTEL Week:
                    </label>
                    <select name="week" required>
                        <% if (weeks != null) {
                            for (Week w : weeks) { %>
                                <option value="<%= w.getWeekNumber() %>">
                                    Week <%= w.getWeekNumber() %>: <%= w.getWeekName() %> (<%= w.getQuestionCount() %> MCQs)
                                </option>
                        <%  }
                           } %>
                    </select>

                    <ul class="mode-features">
                        <li><span>✓</span> Module-specific focused practice</li>
                        <li><span>✓</span> Dynamic weeks (Week 0 to 12+)</li>
                        <li><span>✓</span> Instant answer evaluation</li>
                    </ul>
                </div>

                <button type="submit" class="btn-start">Start Week-Wise Test →</button>
            </form>
        </div>

        <!-- MODE C: SHUFFLE QUESTIONS TEST -->
        <div class="test-card">
            <form action="take-test" method="get">
                <input type="hidden" name="mode" value="SHUFFLE">
                <div>
                    <div class="test-icon">🎲</div>
                    <h2>Mode C: Shuffle Test</h2>
                    <p>Randomly samples non-duplicate questions from across the entire question bank. Randomizes order and option choices for maximum exam readiness.</p>

                    <label style="display:block; font-size:12px; font-weight:700; color:var(--text-sec); margin-bottom:6px; text-transform:uppercase;">
                        Number of Random Questions:
                    </label>
                    <input type="number" name="count" value="25" min="5" max="200" required>

                    <label style="display:flex; align-items:center; gap:8px; font-size:13px; color:var(--text-white); margin-bottom:18px; cursor:pointer;">
                        <input type="checkbox" name="shuffleOptions" value="true" checked style="width:18px; height:18px; accent-color:var(--crimson);">
                        Shuffle Option Positions (A, B, C, D)
                    </label>

                    <ul class="mode-features">
                        <li><span>✓</span> Randomized question sequence</li>
                        <li><span>✓</span> Option letter mapping preserved</li>
                        <li><span>✓</span> Zero duplicate questions in session</li>
                    </ul>
                </div>

                <button type="submit" class="btn-start">Launch Shuffle Exam →</button>
            </form>
        </div>
    </div>
</main>

</body>
</html>
