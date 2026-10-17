<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.TestModel" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    List<TestModel> tests = (List<TestModel>) request.getAttribute("tests");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Management | MAVERICK VIPER</title>
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

        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .alert-success {
            background: rgba(22, 163, 74, 0.15);
            border: 1px solid var(--correct);
            color: #86EFAC;
        }

        .alert-error {
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
        }

        .grid-layout {
            display: grid;
            grid-template-columns: 380px 1fr;
            gap: 25px;
        }

        .form-card, .table-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 25px;
        }

        .form-card h2, .table-card h2 {
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--burgundy);
        }

        label {
            display: block;
            margin: 14px 0 6px;
            font-size: 12.5px;
            font-weight: 600;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        input[type="text"], input[type="number"], select {
            width: 100%;
            padding: 11px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            color: var(--text-white);
            font-size: 14px;
            outline: none;
        }

        input:focus, select:focus {
            border-color: var(--crimson);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 15px;
            cursor: pointer;
            color: var(--text-white);
            font-size: 13.5px;
            text-transform: none;
        }

        .checkbox-label input {
            width: 18px;
            height: 18px;
            accent-color: var(--crimson);
        }

        .btn-submit {
            margin-top: 25px;
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
        }

        .btn-submit:hover {
            opacity: 0.95;
            transform: translateY(-1px);
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

        .badge-type {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
            background: rgba(168, 50, 80, 0.2);
            color: var(--text-white);
            border: 1px solid var(--crimson);
        }

        .btn-del {
            padding: 5px 10px;
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            border-radius: 5px;
            font-size: 12px;
            cursor: pointer;
        }

        .btn-del:hover {
            background: var(--wrong);
            color: white;
        }

        .mandatory-note {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            padding: 12px 15px;
            border-radius: 8px;
            font-size: 12.5px;
            color: var(--text-sec);
            margin-top: 15px;
            line-height: 1.4;
        }

        .mandatory-note strong {
            color: #86EFAC;
        }

        @media(max-width: 950px) {
            .sidebar {
                display: none;
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
            .grid-layout {
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
        <li><a href="admin-dashboard"><span>⚡</span> Overview</a></li>
        <li><a href="admin-students"><span>👥</span> Students</a></li>
        <li><a href="admin-weeks"><span>📅</span> Week Management</a></li>
        <li><a href="admin-questions"><span>❓</span> Questions Bank</a></li>
        <li><a href="bulk-question-upload"><span>📤</span> Bulk MCQ Upload</a></li>
        <li><a href="admin-tests" class="active"><span>📝</span> Test Management</a></li>
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
        <h1>Test Template Management</h1>
        <p>Configure custom exams, test durations, marks, negative marking and question limits.</p>
    </div>

    <% if ("created".equals(success)) { %>
        <div class="alert alert-success">Test configuration created successfully!</div>
    <% } else if ("deleted".equals(success)) { %>
        <div class="alert alert-success">Test configuration removed.</div>
    <% } %>

    <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">Please provide a valid test name and select a test type.</div>
    <% } else if (error != null) { %>
        <div class="alert alert-error">Failed to save test configuration.</div>
    <% } %>

    <div class="grid-layout">
        <!-- Create Test Form -->
        <div class="form-card">
            <h2>Create New Test</h2>
            <form action="admin-tests" method="post">
                <label for="testName">Test Title</label>
                <input type="text" name="testName" id="testName" required placeholder="e.g. Week 1 Comprehensive Quiz">

                <label for="testType">Test Mode / Type</label>
                <select name="testType" id="testType" required onchange="handleTypeChange()">
                    <option value="ALL_MCQ">All MCQ Test (Full Question Bank)</option>
                    <option value="WEEK_WISE">Week-Wise Test (Specific Syllabus Week)</option>
                    <option value="SHUFFLE">Shuffle Questions Test (Randomized Order)</option>
                </select>

                <div id="weekSelectRow" style="display:none;">
                    <label for="weekId">Select Week</label>
                    <select name="weekId" id="weekId">
                        <% if (weeks != null) {
                            for (Week w : weeks) { %>
                                <option value="<%= w.getWeekId() %>">Week <%= w.getWeekNumber() %>: <%= w.getWeekName() %></option>
                        <%  }
                           } %>
                    </select>
                </div>

                <div class="form-row">
                    <div>
                        <label for="durationMinutes">Duration (Min)</label>
                        <input type="number" name="durationMinutes" id="durationMinutes" value="30" min="5" max="300" required>
                    </div>
                    <div>
                        <label for="totalQuestions">Max Questions</label>
                        <input type="number" name="totalQuestions" id="totalQuestions" value="25" min="1" max="500" required>
                    </div>
                </div>

                <div class="form-row">
                    <div>
                        <label for="marksPerQuestion">Marks / Question</label>
                        <input type="number" step="0.5" name="marksPerQuestion" id="marksPerQuestion" value="1.0" min="0.5" max="10" required>
                    </div>
                    <div>
                        <label for="negativeMarks">Negative Mark</label>
                        <input type="number" step="0.25" name="negativeMarks" id="negativeMarks" value="0.0" min="0" max="5">
                    </div>
                </div>

                <label class="checkbox-label">
                    <input type="checkbox" name="shuffleOptions"> Shuffle Option Choices (A, B, C, D)
                </label>

                <div class="mandatory-note">
                    ⚡ <strong>Mandatory Rule:</strong> Instant Answer Feedback after every question selection is automatically enabled for all test modes.
                </div>

                <button type="submit" class="btn-submit">Save Test Template</button>
            </form>
        </div>

        <!-- Available Tests Table -->
        <div class="table-card">
            <h2>Configured Tests (<%= tests != null ? tests.size() : 0 %>)</h2>
            <table>
                <thead>
                    <tr>
                        <th>Test Title</th>
                        <th>Type</th>
                        <th>Duration</th>
                        <th>Marks</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (tests != null && !tests.isEmpty()) {
                        for (TestModel t : tests) { %>
                            <tr>
                                <td style="font-weight: 700;"><%= t.getTestName() %></td>
                                <td><span class="badge-type"><%= t.getTestType() %></span></td>
                                <td><%= t.getDurationMinutes() %> min</td>
                                <td><%= t.getMarksPerQuestion() %> pt (Neg: <%= t.getNegativeMarks() %>)</td>
                                <td>
                                    <form action="admin-tests" method="post" style="display:inline;" onsubmit="return confirm('Delete this test template?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="testId" value="<%= t.getTestId() %>">
                                        <button type="submit" class="btn-del">Delete</button>
                                    </form>
                                </td>
                            </tr>
                    <%  }
                       } else { %>
                        <tr>
                            <td colspan="5" style="text-align:center; color: var(--text-sec); padding:30px;">
                                No custom test templates configured. Built-in All MCQ, Week-Wise, and Shuffle tests remain always available to students by default.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<script>
    function handleTypeChange() {
        const type = document.getElementById('testType').value;
        document.getElementById('weekSelectRow').style.display = (type === 'WEEK_WISE') ? 'block' : 'none';
    }
</script>

</body>
</html>
