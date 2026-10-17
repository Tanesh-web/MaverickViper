<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.TestAttempt" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    boolean isAdmin = (session.getAttribute("adminId") != null);
    String studentName = (String) session.getAttribute("studentName");
    if (studentName == null) studentName = "Student";

    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    List<Map<String, Object>> weekStats = (List<Map<String, Object>>) request.getAttribute("weekStats");
    List<TestAttempt> attempts = (List<TestAttempt>) request.getAttribute("attempts");

    int totalTests = stats != null && stats.get("totalTests") != null ? (Integer) stats.get("totalTests") : 0;
    int totalQuestions = stats != null && stats.get("totalQuestions") != null ? (Integer) stats.get("totalQuestions") : 0;
    int totalAttempted = stats != null && stats.get("totalAttempted") != null ? (Integer) stats.get("totalAttempted") : 0;
    int totalCorrect = stats != null && stats.get("totalCorrect") != null ? (Integer) stats.get("totalCorrect") : 0;
    int totalIncorrect = stats != null && stats.get("totalIncorrect") != null ? (Integer) stats.get("totalIncorrect") : 0;
    double totalScore = stats != null && stats.get("totalScore") != null ? (Double) stats.get("totalScore") : 0.0;
    double overallAccuracy = stats != null && stats.get("overallAccuracy") != null ? (Double) stats.get("overallAccuracy") : 0.0;

    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Performance Dashboard | MAVERICK VIPER</title>
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

        /* Content Area */
        .content {
            flex-grow: 1;
            padding: 35px 45px;
            overflow-y: auto;
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .header-section h1 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .header-subtitle {
            color: var(--text-sec);
            font-size: 14px;
        }

        /* KPI Cards Grid */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
            gap: 20px;
            margin-bottom: 35px;
        }

        .kpi-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.25);
            position: relative;
            overflow: hidden;
        }

        .kpi-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: var(--crimson);
        }

        .kpi-title {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--text-sec);
            font-weight: 600;
        }

        .kpi-value {
            font-size: 30px;
            font-weight: 800;
            color: var(--text-white);
        }

        .kpi-sub {
            font-size: 12px;
            color: var(--text-sec);
        }

        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 35px;
        }

        .chart-card {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 24px;
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }

        .chart-title {
            font-size: 16px;
            font-weight: 700;
        }

        .chart-container {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 240px;
            position: relative;
        }

        /* History Table Section */
        .history-section {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 24px;
        }

        .history-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .history-title {
            font-size: 18px;
            font-weight: 700;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .data-table th {
            text-align: left;
            padding: 12px 14px;
            background: var(--bg-card);
            color: var(--text-sec);
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 1px;
            border-bottom: 1px solid var(--burgundy);
        }

        .data-table td {
            padding: 14px;
            border-bottom: 1px solid rgba(100, 28, 53, 0.4);
            color: var(--text-white);
        }

        .data-table tr:hover {
            background: rgba(50, 26, 38, 0.5);
        }

        .btn-review {
            display: inline-block;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: #FFFFFF;
            padding: 6px 14px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 700;
            font-size: 12px;
            transition: all 0.2s;
        }

        .btn-review:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .empty-history {
            text-align: center;
            padding: 40px;
            color: var(--text-sec);
        }

        @media (max-width: 900px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; border-right: none; border-bottom: 1px solid var(--burgundy); }
            .content { padding: 20px; }
            .charts-grid { grid-template-columns: 1fr; }
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
            <li><a href="admin-students" class="nav-link active"><span>👥</span> Students Dossier</a></li>
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

<!-- Content -->
<main class="content">
    <div class="header-section">
        <div>
            <h1>Performance Analytics Dashboard</h1>
            <div class="header-subtitle">Comprehensive metrics, accuracy progression, and examination history.</div>
        </div>

        <div>
            <a href="take-test" class="btn-review" style="padding: 10px 18px; font-size:14px;">✍️ Launch New Test</a>
        </div>
    </div>

    <!-- KPI Metric Cards -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <span class="kpi-title">Total Tests Attempted</span>
            <span class="kpi-value"><%= totalTests %></span>
            <span class="kpi-sub">Completed test evaluations</span>
        </div>

        <div class="kpi-card">
            <span class="kpi-title">Total Questions Answered</span>
            <span class="kpi-value"><%= totalAttempted %></span>
            <span class="kpi-sub">Out of <%= totalQuestions %> total encountered</span>
        </div>

        <div class="kpi-card">
            <span class="kpi-title">Overall Accuracy</span>
            <span class="kpi-value" style="color: <%= overallAccuracy >= 60 ? "#86EFAC" : "#FCA5A5" %>;"><%= overallAccuracy %>%</span>
            <span class="kpi-sub">Based on <%= totalAttempted %> answers</span>
        </div>

        <div class="kpi-card">
            <span class="kpi-title">Total Marks Scored</span>
            <span class="kpi-value"><%= totalScore %></span>
            <span class="kpi-sub"><%= totalCorrect %> correct / <%= totalIncorrect %> incorrect</span>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="charts-grid">
        <!-- Donut Chart: Correct vs Incorrect -->
        <div class="chart-card">
            <div class="chart-header">
                <span class="chart-title">Answer Breakdown (Correct vs Incorrect)</span>
            </div>
            <div class="chart-container">
                <% if (totalAttempted > 0) { %>
                    <canvas id="breakdownCanvas" width="220" height="220"></canvas>
                    <div style="margin-left: 25px; display: flex; flex-direction: column; gap: 12px; font-size: 13px;">
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span style="width:14px; height:14px; background:#16A34A; border-radius:3px; display:inline-block;"></span>
                            <span>Correct: <strong><%= totalCorrect %></strong> (<%= Math.round((double)totalCorrect / totalAttempted * 100) %>%)</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:8px;">
                            <span style="width:14px; height:14px; background:#DC2626; border-radius:3px; display:inline-block;"></span>
                            <span>Incorrect: <strong><%= totalIncorrect %></strong> (<%= Math.round((double)totalIncorrect / totalAttempted * 100) %>%)</span>
                        </div>
                    </div>
                <% } else { %>
                    <div style="color:var(--text-sec); font-size:14px;">No test attempts completed yet. Take a test to visualize your breakdown.</div>
                <% } %>
            </div>
        </div>

        <!-- Week-wise Performance Bar Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <span class="chart-title">Week-wise Accuracy Comparison</span>
            </div>
            <div class="chart-container" style="flex-direction:column; justify-content:center; gap:12px;">
                <% if (weekStats != null && !weekStats.isEmpty()) { %>
                    <div style="width:100%; display:flex; flex-direction:column; gap:10px;">
                        <% for (Map<String, Object> ws : weekStats) {
                            int w = (Integer) ws.get("weekNumber");
                            int ans = (Integer) ws.get("totalAnswered");
                            int corr = (Integer) ws.get("totalCorrect");
                            double acc = (Double) ws.get("accuracy");
                        %>
                            <div>
                                <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                                    <span><strong>Week <%= w %></strong> (<%= corr %>/<%= ans %> correct)</span>
                                    <span style="font-weight:700; color:<%= acc >= 60 ? "#86EFAC" : "#FCA5A5" %>;"><%= acc %>%</span>
                                </div>
                                <div style="width:100%; height:12px; background:var(--bg-main); border-radius:6px; overflow:hidden; border:1px solid var(--burgundy);">
                                    <div style="width:<%= acc %>%; height:100%; background:linear-gradient(90deg, var(--burgundy), var(--crimson)); border-radius:6px;"></div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div style="color:var(--text-sec); font-size:14px;">Complete week-wise tests to view weekly mastery metrics.</div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Test History Table -->
    <section class="history-section">
        <div class="history-header">
            <span class="history-title">Examination Attempt History</span>
        </div>

        <% if (attempts != null && !attempts.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Test Name</th>
                        <th>Type</th>
                        <th>Date & Time</th>
                        <th>Score</th>
                        <th>Percentage</th>
                        <th>Accuracy</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (int i = 0; i < attempts.size(); i++) {
                        TestAttempt ta = attempts.get(i);
                        String dateStr = (ta.getCompletedAt() != null) ? sdf.format(ta.getCompletedAt()) :
                                         ((ta.getStartedAt() != null) ? sdf.format(ta.getStartedAt()) : "N/A");
                    %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><strong><%= ta.getTestName() %></strong></td>
                            <td><span style="font-size:11px; padding:3px 8px; border-radius:4px; background:var(--bg-main); border:1px solid var(--burgundy);"><%= ta.getTestType() %></span></td>
                            <td style="color:var(--text-sec); font-size:13px;"><%= dateStr %></td>
                            <td><%= ta.getScore() %> / <%= ta.getTotalQuestions() %></td>
                            <td><strong><%= ta.getPercentage() %>%</strong></td>
                            <td style="color:<%= ta.getAccuracy() >= 60 ? "#86EFAC" : "#FCA5A5" %>;"><strong><%= ta.getAccuracy() %>%</strong></td>
                            <td>
                                <% if ("COMPLETED".equalsIgnoreCase(ta.getStatus())) { %>
                                    <a href="test-results?attemptId=<%= ta.getAttemptId() %>" class="btn-review">Review Answers</a>
                                <% } else { %>
                                    <a href="take-test?attemptId=<%= ta.getAttemptId() %>" class="btn-review" style="background:#4B5563;">Resume Test</a>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-history">
                <p>No examinations completed yet.</p>
                <p style="margin-top:8px; font-size:13px;">Begin your preparation by taking an All MCQ Test, Week-wise Test, or Shuffle Test.</p>
            </div>
        <% } %>
    </section>
</main>

<script>
    // Draw Donut Chart on Canvas
    <% if (totalAttempted > 0) { %>
    window.addEventListener('DOMContentLoaded', () => {
        const canvas = document.getElementById('breakdownCanvas');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 80;
        const thickness = 28;

        const total = <%= totalAttempted %>;
        const correct = <%= totalCorrect %>;
        const incorrect = <%= totalIncorrect %>;

        const correctAngle = (correct / total) * 2 * Math.PI;

        // Clear canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // Draw Correct Arc (Green)
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + correctAngle);
        ctx.lineWidth = thickness;
        ctx.strokeStyle = '#16A34A';
        ctx.stroke();

        // Draw Incorrect Arc (Red)
        if (incorrect > 0) {
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, -Math.PI / 2 + correctAngle, -Math.PI / 2 + 2 * Math.PI);
            ctx.lineWidth = thickness;
            ctx.strokeStyle = '#DC2626';
            ctx.stroke();
        }

        // Inner percentage text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 22px -apple-system, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('<%= Math.round(overallAccuracy) %>%', centerX, centerY - 6);

        ctx.fillStyle = '#C9AEB8';
        ctx.font = '11px -apple-system, sans-serif';
        ctx.fillText('Accuracy', centerX, centerY + 14);
    });
    <% } %>
</script>

</body>
</html>
