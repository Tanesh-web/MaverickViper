<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Student" %>
<%@ page import="com.maverickviper.model.TestAttempt" %>
<%@ page import="com.maverickviper.model.LoginActivity" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    List<Student> students = (List<Student>) request.getAttribute("students");
    String searchQuery = (String) request.getAttribute("searchQuery");

    Student detailStudent = (Student) request.getAttribute("detailStudent");
    Map<String, Object> studentStats = (Map<String, Object>) request.getAttribute("studentStats");
    List<TestAttempt> studentAttempts = (List<TestAttempt>) request.getAttribute("studentAttempts");
    List<LoginActivity> studentLogins = (List<LoginActivity>) request.getAttribute("studentLogins");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Management | MAVERICK VIPER</title>
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

        .main-content {
            margin-left: 270px;
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

        .search-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
        }

        .search-bar input {
            flex: 1;
            padding: 12px 18px;
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            color: var(--text-white);
            font-size: 14px;
            outline: none;
        }

        .search-bar input:focus {
            border-color: var(--crimson);
        }

        .search-bar button, .search-bar a {
            padding: 12px 22px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        .table-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 25px;
            overflow-x: auto;
            margin-bottom: 30px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            text-align: left;
            padding: 12px 14px;
            color: var(--text-sec);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid var(--burgundy);
        }

        td {
            padding: 14px;
            font-size: 14px;
            border-bottom: 1px solid rgba(100, 28, 53, 0.3);
            color: var(--text-white);
        }

        tr:last-child td {
            border-bottom: none;
        }

        .badge-acc {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 12px;
            background: rgba(168, 50, 80, 0.2);
            color: var(--text-white);
            border: 1px solid var(--crimson);
        }

        .btn-view {
            display: inline-block;
            padding: 6px 14px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
        }

        .btn-view:hover {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        /* Detail Modal / Panel */
        .detail-panel {
            background: var(--bg-sec);
            border: 1px solid var(--crimson);
            border-radius: 14px;
            padding: 30px;
            margin-bottom: 30px;
            animation: fadeIn 0.3s ease;
        }

        .detail-panel h2 {
            font-size: 22px;
            margin-bottom: 6px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .close-link {
            color: var(--text-sec);
            font-size: 13px;
            text-decoration: none;
        }

        .close-link:hover {
            color: var(--text-white);
        }

        .detail-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin: 20px 0;
        }

        .d-card {
            background: var(--bg-card);
            padding: 15px;
            border-radius: 8px;
            border: 1px solid var(--burgundy);
        }

        .d-label {
            font-size: 11px;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        .d-val {
            font-size: 22px;
            font-weight: 800;
            margin-top: 4px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media(max-width: 900px) {
            .sidebar {
                display: none;
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
            .detail-stats-grid {
                grid-template-columns: repeat(2, 1fr);
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
        <li><a href="admin-dashboard"><span>⚡</span> Overview</a></li>
        <li><a href="admin-students" class="active"><span>👥</span> Students</a></li>
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
        <h1>Student Management</h1>
        <p>Monitor registered candidates, track learning activity, examine scores and individual history.</p>
    </div>

    <!-- Individual Student Detail Panel if Selected -->
    <% if (detailStudent != null) { %>
        <div class="detail-panel">
            <h2>
                <span>Student Dossier: <%= detailStudent.getFullName() %></span>
                <a href="admin-students" class="close-link">✕ Close Details</a>
            </h2>
            <p style="color: var(--text-sec); font-size: 14px;">
                Email: <strong><%= detailStudent.getEmail() %></strong> | 
                Registered: <%= detailStudent.getCreatedAt() != null ? detailStudent.getCreatedAt().toString().substring(0, 16) : "-" %> |
                Last Active: <%= detailStudent.getLastLogin() != null ? detailStudent.getLastLogin().toString().substring(0, 16) : "Never" %>
            </p>

            <div class="detail-stats-grid">
                <div class="d-card">
                    <div class="d-label">Tests Completed</div>
                    <div class="d-val"><%= studentStats != null ? studentStats.get("totalTests") : 0 %></div>
                </div>
                <div class="d-card">
                    <div class="d-label">Questions Attempted</div>
                    <div class="d-val"><%= studentStats != null ? studentStats.get("totalAttempted") : 0 %></div>
                </div>
                <div class="d-card">
                    <div class="d-label">Correct Answers</div>
                    <div class="d-val" style="color: var(--correct);"><%= studentStats != null ? studentStats.get("totalCorrect") : 0 %></div>
                </div>
                <div class="d-card">
                    <div class="d-label">Overall Accuracy</div>
                    <div class="d-val" style="color: var(--crimson);"><%= studentStats != null ? studentStats.get("overallAccuracy") : 0.0 %>%</div>
                </div>
            </div>

            <!-- Test attempts history for this student -->
            <h3 style="font-size: 16px; margin: 25px 0 12px;">Test Attempts History</h3>
            <% if (studentAttempts != null && !studentAttempts.isEmpty()) { %>
                <table style="margin-bottom: 20px;">
                    <thead>
                        <tr>
                            <th>Test Name</th>
                            <th>Date</th>
                            <th>Attempted</th>
                            <th>Correct</th>
                            <th>Incorrect</th>
                            <th>Score</th>
                            <th>Accuracy</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (TestAttempt att : studentAttempts) { %>
                            <tr>
                                <td><%= att.getTestName() %></td>
                                <td><%= att.getStartedAt() != null ? att.getStartedAt().toString().substring(0, 16) : "-" %></td>
                                <td><%= att.getAttempted() %> / <%= att.getTotalQuestions() %></td>
                                <td style="color: var(--correct); font-weight: bold;"><%= att.getCorrect() %></td>
                                <td style="color: var(--wrong); font-weight: bold;"><%= att.getIncorrect() %></td>
                                <td><%= att.getScore() %></td>
                                <td><strong><%= att.getAccuracy() %>%</strong></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p style="color: var(--text-sec); font-size: 13px; margin-bottom: 20px;">No tests attempted by this student yet.</p>
            <% } %>

            <!-- Login History for this student -->
            <h3 style="font-size: 16px; margin: 15px 0 12px;">Student Login Logs</h3>
            <% if (studentLogins != null && !studentLogins.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Login Time</th>
                            <th>Logout Time</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (LoginActivity l : studentLogins) { %>
                            <tr>
                                <td><%= l.getLoginTime() != null ? l.getLoginTime().toString().substring(0, 16) : "-" %></td>
                                <td><%= l.getLogoutTime() != null ? l.getLogoutTime().toString().substring(0, 16) : "Active / In-session" %></td>
                                <td><span style="color: var(--correct); font-weight: 600;"><%= l.getStatus() %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <p style="color: var(--text-sec); font-size: 13px;">No login sessions recorded.</p>
            <% } %>
        </div>
    <% } %>

    <!-- Search Bar -->
    <form action="admin-students" method="get" class="search-bar">
        <input type="text" name="search" placeholder="Search students by name or email address..." value="<%= searchQuery != null ? searchQuery : "" %>">
        <button type="submit">Search</button>
        <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
            <a href="admin-students" style="background: var(--bg-card); border: 1px solid var(--burgundy);">Clear</a>
        <% } %>
    </form>

    <!-- Students Table -->
    <div class="table-card">
        <% if (students != null && !students.isEmpty()) { %>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student Name</th>
                        <th>Email Address</th>
                        <th>Joined Date</th>
                        <th>Last Login</th>
                        <th>Tests Taken</th>
                        <th>Accuracy</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Student s : students) { %>
                        <tr>
                            <td>#<%= s.getStudentId() %></td>
                            <td style="font-weight: 700;"><%= s.getFullName() %></td>
                            <td style="color: var(--text-sec);"><%= s.getEmail() %></td>
                            <td><%= s.getCreatedAt() != null ? s.getCreatedAt().toString().substring(0, 10) : "-" %></td>
                            <td><%= s.getLastLogin() != null ? s.getLastLogin().toString().substring(0, 16) : "Never" %></td>
                            <td><%= s.getTestsAttempted() %> Tests</td>
                            <td><span class="badge-acc"><%= Math.round(s.getOverallAccuracy() * 10.0) / 10.0 %>%</span></td>
                            <td>
                                <a href="admin-students?studentId=<%= s.getStudentId() %>" class="btn-view">View Dossier</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <p style="color: var(--text-sec); text-align: center; padding: 30px;">No matching students found.</p>
        <% } %>
    </div>
</main>

</body>
</html>
