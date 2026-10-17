<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Student" %>
<%@ page import="com.maverickviper.model.LoginActivity" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    if (adminUsername == null) adminUsername = "Admin";

    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");
    Integer totalWeeks = (Integer) request.getAttribute("totalWeeks");
    Integer totalTests = (Integer) request.getAttribute("totalTests");
    Integer totalAttempts = (Integer) request.getAttribute("totalAttempts");

    List<Student> recentStudents = (List<Student>) request.getAttribute("recentStudents");
    List<LoginActivity> recentLogins = (List<LoginActivity>) request.getAttribute("recentLogins");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | MAVERICK VIPER</title>
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
            width: 270px;
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
            overflow-y: auto;
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
            color: var(--crimson);
            text-transform: uppercase;
            font-weight: 700;
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

        .logout-btn:hover {
            background: var(--wrong);
            color: white;
        }

        /* Main Content */
        .main-content {
            margin-left: 270px;
            flex: 1;
            padding: 35px 45px;
        }

        .header-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
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

        .quick-actions {
            display: flex;
            gap: 12px;
        }

        .btn-quick {
            display: inline-block;
            padding: 10px 18px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-quick-primary {
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            box-shadow: 0 4px 12px rgba(168, 50, 80, 0.3);
        }

        .btn-quick-secondary {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
        }

        .btn-quick:hover {
            transform: translateY(-1px);
        }

        /* Metric Grid */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 18px;
            margin-bottom: 35px;
        }

        .metric-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 20px;
            transition: transform 0.2s;
        }

        .metric-card:hover {
            transform: translateY(-2px);
            border-color: var(--crimson);
        }

        .metric-label {
            color: var(--text-sec);
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        .metric-value {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-white);
        }

        /* Management Modules Grid */
        .modules-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 40px;
        }

        .module-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 22px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: all 0.2s;
        }

        .module-card:hover {
            transform: translateY(-2px);
            border-color: var(--crimson);
            box-shadow: 0 8px 25px rgba(0,0,0,0.4);
        }

        .module-card .icon {
            font-size: 28px;
            margin-bottom: 12px;
        }

        .module-card h3 {
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .module-card p {
            color: var(--text-sec);
            font-size: 12.5px;
            line-height: 1.5;
            margin-bottom: 18px;
            flex: 1;
        }

        .btn-card {
            display: block;
            text-align: center;
            padding: 9px 14px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 6px;
            font-size: 12.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-card:hover {
            background: var(--crimson);
            border-color: var(--crimson);
        }

        /* Two Column Split */
        .split-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }

        .table-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 25px;
            overflow-x: auto;
        }

        .table-card h2 {
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .table-card h2 a {
            color: var(--crimson);
            font-size: 12.5px;
            text-decoration: none;
            font-weight: 600;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 10px 12px;
            color: var(--text-sec);
            font-size: 11.5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--burgundy);
        }

        td {
            padding: 12px;
            font-size: 13.5px;
            border-bottom: 1px solid rgba(100, 28, 53, 0.3);
            color: var(--text-white);
        }

        tr:last-child td {
            border-bottom: none;
        }

        .badge-status {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            background: rgba(22, 163, 74, 0.2);
            color: #86EFAC;
            border: 1px solid var(--correct);
        }

        .empty-text {
            color: var(--text-sec);
            font-size: 13px;
            padding: 20px 0;
            text-align: center;
        }

        @media(max-width: 1200px) {
            .metrics-grid {
                grid-template-columns: repeat(3, 1fr);
            }
            .modules-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .split-grid {
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
            .metrics-grid {
                grid-template-columns: 1fr;
            }
            .modules-grid {
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
        <li><a href="admin-dashboard" class="active"><span>⚡</span> Overview</a></li>
        <li><a href="admin-students"><span>👥</span> Students</a></li>
        <li><a href="admin-weeks"><span>📅</span> Week Management</a></li>
        <li><a href="admin-questions"><span>❓</span> Questions Bank</a></li>
        <li><a href="bulk-question-upload"><span>📤</span> Bulk MCQ Upload</a></li>
        <li><a href="admin-tests"><span>📝</span> Test Management</a></li>
        <li><a href="admin-login-activity"><span>🔐</span> Login Activity</a></li>
        <li><a href="admin-courses"><span>📚</span> Course Settings</a></li>
    </ul>

    <div class="user-block">
        <div class="user-info">
            <div class="name"><%= adminUsername %></div>
            <div class="role">Administrator</div>
        </div>
        <a href="admin-logout" class="logout-btn">Logout</a>
    </div>
</aside>

<main class="main-content">
    <div class="header-title">
        <div>
            <h1>Admin Control Center</h1>
            <p>Comprehensive management for NPTEL: Foundation of Digital Business</p>
        </div>
        <div class="quick-actions">
            <a href="bulk-question-upload" class="btn-quick btn-quick-primary">+ Bulk Upload MCQs</a>
            <a href="admin-questions?action=new" class="btn-quick btn-quick-secondary">+ Add Question</a>
        </div>
    </div>

    <!-- Live Metric Counters -->
    <div class="metrics-grid">
        <div class="metric-card">
            <div class="metric-label">Registered Students</div>
            <div class="metric-value"><%= totalStudents != null ? totalStudents : 0 %></div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Total MCQs</div>
            <div class="metric-value"><%= totalQuestions != null ? totalQuestions : 0 %></div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Dynamic Weeks</div>
            <div class="metric-value"><%= totalWeeks != null ? totalWeeks : 0 %></div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Test Templates</div>
            <div class="metric-value"><%= totalTests != null ? totalTests : 0 %></div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Completed Attempts</div>
            <div class="metric-value"><%= totalAttempts != null ? totalAttempts : 0 %></div>
        </div>
    </div>

    <!-- Management Modules -->
    <div class="modules-grid">
        <div class="module-card">
            <div>
                <div class="icon">👥</div>
                <h3>Student Management</h3>
                <p>View registered students, login dates, search candidates, and examine individual performance.</p>
            </div>
            <a href="admin-students" class="btn-card">Manage Students →</a>
        </div>

        <div class="module-card">
            <div>
                <div class="icon">📅</div>
                <h3>Week Management</h3>
                <p>Add new weeks, edit titles, and organize syllabus structure dynamically (Week 0 to 12+).</p>
            </div>
            <a href="admin-weeks" class="btn-card">Manage Weeks →</a>
        </div>

        <div class="module-card">
            <div>
                <div class="icon">❓</div>
                <h3>Question Bank</h3>
                <p>Add, edit, correct answer keys, modify options and explanations with attempt snapshot preservation.</p>
            </div>
            <a href="admin-questions" class="btn-card">Manage MCQs →</a>
        </div>

        <div class="module-card">
            <div>
                <div class="icon">📤</div>
                <h3>Bulk MCQ Upload</h3>
                <p>Upload Word (.docx), Excel (.xlsx), CSV or Paste Text directly with interactive preview & validation.</p>
            </div>
            <a href="bulk-question-upload" class="btn-card">Bulk Upload →</a>
        </div>
    </div>

    <!-- Split: Recent Students & Recent Login Activity -->
    <div class="split-grid">
        <!-- Recent Students -->
        <div class="table-card">
            <h2>
                <span>Registered Students</span>
                <a href="admin-students">View All →</a>
            </h2>

            <% if (recentStudents != null && !recentStudents.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Email</th>
                            <th>Tests</th>
                            <th>Accuracy</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Student s : recentStudents) { %>
                            <tr>
                                <td style="font-weight: 700;"><%= s.getFullName() %></td>
                                <td style="color: var(--text-sec);"><%= s.getEmail() %></td>
                                <td><%= s.getTestsAttempted() %></td>
                                <td><strong><%= Math.round(s.getOverallAccuracy() * 10.0) / 10.0 %>%</strong></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-text">No students registered yet.</div>
            <% } %>
        </div>

        <!-- Recent Login Activity -->
        <div class="table-card">
            <h2>
                <span>Recent Login Activity</span>
                <a href="admin-login-activity">Full Log →</a>
            </h2>

            <% if (recentLogins != null && !recentLogins.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Student</th>
                            <th>Login Time</th>
                            <th>Logout Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (LoginActivity a : recentLogins) { %>
                            <tr>
                                <td style="font-weight: 700;"><%= a.getStudentName() %></td>
                                <td><%= a.getLoginTime() != null ? a.getLoginTime().toString().substring(0, 16) : "-" %></td>
                                <td><%= a.getLogoutTime() != null ? a.getLogoutTime().toString().substring(0, 16) : "Active" %></td>
                                <td><span class="badge-status"><%= a.getStatus() %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-text">No login activity recorded yet.</div>
            <% } %>
        </div>
    </div>
</main>

</body>
</html>
