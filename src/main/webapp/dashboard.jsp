<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Student" %>
<%@ page import="com.maverickviper.model.TestAttempt" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    Student student = (Student) request.getAttribute("student");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<TestAttempt> recentAttempts = (List<TestAttempt>) request.getAttribute("recentAttempts");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");

    String studentName = (student != null) ? student.getFullName() : (String) session.getAttribute("studentName");
    if (studentName == null) studentName = "Student";

    int weekCount = (weeks != null) ? weeks.size() : 0;
    int qCount = (totalQuestions != null) ? totalQuestions : 0;
    int testsCount = (stats != null && stats.get("totalTests") != null) ? (Integer) stats.get("totalTests") : 0;
    double accuracy = (stats != null && stats.get("overallAccuracy") != null) ? (Double) stats.get("overallAccuracy") : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard | MAVERICK VIPER</title>
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

        /* Sidebar */
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
            max-width: 130px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
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
            transition: all 0.2s;
        }

        .logout-btn:hover {
            background: var(--wrong);
            color: white;
        }

        /* Main Content */
        .main-content {
            margin-left: 260px;
            flex: 1;
            padding: 35px 45px;
        }

        .welcome-banner {
            background: linear-gradient(135deg, #321A26, #24121C);
            border: 1px solid var(--burgundy);
            border-radius: 16px;
            padding: 30px 35px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }

        .welcome-banner::after {
            content: "◈";
            position: absolute;
            right: 30px;
            bottom: -20px;
            font-size: 140px;
            color: rgba(168, 50, 80, 0.08);
            pointer-events: none;
        }

        .course-pill {
            display: inline-block;
            background: rgba(168, 50, 80, 0.2);
            border: 1px solid var(--crimson);
            color: var(--text-sec);
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 12px;
        }

        .welcome-banner h1 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .welcome-banner p {
            color: var(--text-sec);
            font-size: 15px;
            max-width: 650px;
            line-height: 1.6;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 35px;
        }

        .stat-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 22px;
            transition: transform 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            border-color: var(--crimson);
        }

        .stat-label {
            color: var(--text-sec);
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .stat-value {
            font-size: 30px;
            font-weight: 800;
            color: var(--text-white);
        }

        .stat-value span {
            color: var(--crimson);
            font-size: 18px;
        }

        /* Section Headings */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .section-header h2 {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        /* Action Cards Grid */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 22px;
            margin-bottom: 40px;
        }

        .action-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 28px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s;
        }

        .action-card:hover {
            transform: translateY(-3px);
            border-color: var(--crimson);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
        }

        .action-card .icon {
            font-size: 34px;
            margin-bottom: 15px;
        }

        .action-card h3 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .action-card p {
            color: var(--text-sec);
            font-size: 13.5px;
            line-height: 1.6;
            margin-bottom: 22px;
            flex: 1;
        }

        .btn-action {
            display: inline-block;
            text-align: center;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            padding: 12px 18px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-action:hover {
            opacity: 0.95;
            box-shadow: 0 4px 15px rgba(168, 50, 80, 0.35);
        }

        /* Table */
        .table-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 25px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px 16px;
            color: var(--text-sec);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--burgundy);
        }

        td {
            padding: 14px 16px;
            font-size: 14px;
            border-bottom: 1px solid rgba(100, 28, 53, 0.3);
            color: var(--text-white);
        }

        tr:last-child td {
            border-bottom: none;
        }

        .badge-score {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 12px;
            background: rgba(22, 163, 74, 0.2);
            color: #86EFAC;
            border: 1px solid var(--correct);
        }

        .btn-review {
            display: inline-block;
            padding: 6px 12px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
        }

        .btn-review:hover {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-sec);
            font-size: 14px;
        }

        @media(max-width: 1050px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .actions-grid {
                grid-template-columns: 1fr;
            }
        }

        @media(max-width: 768px) {
            .sidebar {
                display: none;
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<aside class="sidebar">
    <div class="sidebar-brand">
        MAVERICK <span>VIPER</span>
    </div>

    <ul class="nav-links">
        <li><a href="dashboard" class="active"><span>📊</span> Dashboard</a></li>
        <li><a href="read-mcqs"><span>📖</span> Read MCQs</a></li>
        <li><a href="take-test"><span>✍️</span> Give Test</a></li>
        <li><a href="student-performance"><span>📈</span> Performance</a></li>
        <li><a href="student-profile"><span>👤</span> Profile</a></li>
    </ul>

    <div class="user-block">
        <div class="user-info">
            <div class="name"><%= studentName %></div>
            <div class="role">NPTEL Candidate</div>
        </div>
        <a href="logout" class="logout-btn">Logout</a>
    </div>
</aside>

<main class="main-content">
    <div class="welcome-banner">
        <div class="course-pill">NPTEL Preparation Platform</div>
        <h1>Welcome Back, <%= studentName %>!</h1>
        <p>Master the <strong>Foundation of Digital Business</strong> course with our organized week-wise question bank, instant answer feedback practice tests, and comprehensive analytics.</p>
    </div>

    <!-- Quick Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label">Available Questions</div>
            <div class="stat-value"><%= qCount %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Course Weeks</div>
            <div class="stat-value"><%= weekCount %> <span>Weeks</span></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Tests Completed</div>
            <div class="stat-value"><%= testsCount %></div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Overall Accuracy</div>
            <div class="stat-value"><%= accuracy %><span>%</span></div>
        </div>
    </div>

    <!-- Three Main Sections -->
    <div class="section-header">
        <h2>Preparation Modes</h2>
    </div>

    <div class="actions-grid">
        <!-- 1. READ MCQs -->
        <div class="action-card">
            <div>
                <div class="icon">📖</div>
                <h3>1. Read MCQs</h3>
                <p>Browse through questions without affecting test records. View correct answers in green with step-by-step navigation across all weeks.</p>
            </div>
            <a href="read-mcqs" class="btn-action">Start Reading MCQs →</a>
        </div>

        <!-- 2. GIVE TEST -->
        <div class="action-card">
            <div>
                <div class="icon">✍️</div>
                <h3>2. Give Test</h3>
                <p>Take exams in 3 modes: All MCQ Test, Week-Wise Test, or Shuffle Test with <strong>Instant Answer Feedback</strong> on every question.</p>
            </div>
            <a href="take-test" class="btn-action">Enter Examination →</a>
        </div>

        <!-- 3. PERFORMANCE DASHBOARD -->
        <div class="action-card">
            <div>
                <div class="icon">📈</div>
                <h3>3. Performance Dashboard</h3>
                <p>Review comprehensive statistics, accuracy charts, week-by-week progress breakdowns, and historical test attempts.</p>
            </div>
            <a href="student-performance" class="btn-action">View Performance →</a>
        </div>
    </div>

    <!-- Recent Test History -->
    <div class="section-header">
        <h2>Recent Test Attempts</h2>
        <a href="student-performance" style="color: var(--crimson); text-decoration: none; font-size: 13px; font-weight: 700;">View Full History →</a>
    </div>

    <div class="table-card">
        <% if (recentAttempts != null && !recentAttempts.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>Test Name</th>
                        <th>Type</th>
                        <th>Date & Time</th>
                        <th>Questions</th>
                        <th>Score</th>
                        <th>Accuracy</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        int limit = Math.min(recentAttempts.size(), 5);
                        for (int i = 0; i < limit; i++) {
                            TestAttempt att = recentAttempts.get(i);
                    %>
                        <tr>
                            <td style="font-weight: 700;"><%= att.getTestName() %></td>
                            <td><span style="color: var(--text-sec); font-size: 12px;"><%= att.getTestType() %></span></td>
                            <td><%= att.getStartedAt() != null ? att.getStartedAt().toString().substring(0, 16) : "-" %></td>
                            <td><%= att.getAttempted() %> / <%= att.getTotalQuestions() %></td>
                            <td><span class="badge-score"><%= att.getScore() %> Marks</span></td>
                            <td><strong><%= att.getAccuracy() %>%</strong></td>
                            <td>
                                <a href="test-results?attemptId=<%= att.getAttemptId() %>" class="btn-review">Review</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <p>You haven't attempted any tests yet. Choose an exam mode under <strong>Give Test</strong> to test your knowledge with instant feedback!</p>
            </div>
        <% } %>
    </div>
</main>

</body>
</html>
