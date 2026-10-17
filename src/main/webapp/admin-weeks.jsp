<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    Week editWeek = (Week) request.getAttribute("editWeek");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dynamic Week Management | MAVERICK VIPER</title>
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
            grid-template-columns: 360px 1fr;
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
            margin: 15px 0 6px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        input {
            width: 100%;
            padding: 12px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            color: var(--text-white);
            font-size: 14px;
            outline: none;
        }

        input:focus {
            border-color: var(--crimson);
        }

        .btn-submit {
            margin-top: 22px;
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

        .btn-cancel {
            display: block;
            text-align: center;
            margin-top: 10px;
            color: var(--text-sec);
            font-size: 13px;
            text-decoration: none;
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

        .badge-count {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 12px;
            background: rgba(168, 50, 80, 0.2);
            color: var(--text-white);
            border: 1px solid var(--crimson);
        }

        .action-btns {
            display: flex;
            gap: 8px;
        }

        .btn-sm-edit {
            padding: 5px 10px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 5px;
            font-size: 12px;
            text-decoration: none;
        }

        .btn-sm-edit:hover {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        .btn-sm-del {
            padding: 5px 10px;
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            border-radius: 5px;
            font-size: 12px;
            cursor: pointer;
        }

        .btn-sm-del:hover {
            background: var(--wrong);
            color: white;
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
        <li><a href="admin-weeks" class="active"><span>📅</span> Week Management</a></li>
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
        <h1>Dynamic Week Management</h1>
        <p>Define syllabus weeks dynamically. Add future weeks (Week 13, Week 14, etc.) without code modification.</p>
    </div>

    <% if ("added".equals(success)) { %>
        <div class="alert alert-success">Week created successfully!</div>
    <% } else if ("updated".equals(success)) { %>
        <div class="alert alert-success">Week details updated successfully!</div>
    <% } else if ("deleted".equals(success)) { %>
        <div class="alert alert-success">Week deleted safely.</div>
    <% } %>

    <% if ("has_questions".equals(error)) { %>
        <div class="alert alert-error">Cannot delete this week because questions are currently assigned to it. Reassign or delete questions first.</div>
    <% } else if ("week_exists".equals(error)) { %>
        <div class="alert alert-error">A week with this week number already exists.</div>
    <% } else if ("invalid_number".equals(error)) { %>
        <div class="alert alert-error">Week number must be a valid non-negative integer (e.g. 0, 1, 2...).</div>
    <% } else if (error != null) { %>
        <div class="alert alert-error">An error occurred while saving week data.</div>
    <% } %>

    <div class="grid-layout">
        <!-- Form to Add or Edit Week -->
        <div class="form-card">
            <h2><%= editWeek != null ? "Edit Week #" + editWeek.getWeekNumber() : "Add New Week" %></h2>
            <form action="admin-weeks" method="post">
                <input type="hidden" name="action" value="<%= editWeek != null ? "update" : "create" %>">
                <% if (editWeek != null) { %>
                    <input type="hidden" name="weekId" value="<%= editWeek.getWeekId() %>">
                <% } %>

                <label for="weekNumber">Week Number</label>
                <input type="number" id="weekNumber" name="weekNumber" min="0" max="100" required 
                       placeholder="0 for Week 0, 1 for Week 1..." value="<%= editWeek != null ? editWeek.getWeekNumber() : "" %>">

                <label for="weekName">Week Title / Description</label>
                <input type="text" id="weekName" name="weekName" required 
                       placeholder="e.g. Week 1 - Digital Business Concepts" value="<%= editWeek != null ? editWeek.getWeekName() : "" %>">

                <button type="submit" class="btn-submit"><%= editWeek != null ? "Save Changes" : "Create Week" %></button>
                <% if (editWeek != null) { %>
                    <a href="admin-weeks" class="btn-cancel">Cancel Edit</a>
                <% } %>
            </form>
        </div>

        <!-- Available Weeks Table -->
        <div class="table-card">
            <h2>Dynamic Course Weeks (<%= weeks != null ? weeks.size() : 0 %>)</h2>
            <table>
                <thead>
                    <tr>
                        <th>Week #</th>
                        <th>Week Title</th>
                        <th>Questions</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (weeks != null && !weeks.isEmpty()) {
                        for (Week w : weeks) { %>
                            <tr>
                                <td style="font-weight: 800; color: var(--crimson);">Week <%= w.getWeekNumber() %></td>
                                <td><%= w.getWeekName() %></td>
                                <td>
                                    <a href="admin-questions?week=<%= w.getWeekNumber() %>" class="badge-count" style="text-decoration:none;">
                                        <%= w.getQuestionCount() %> MCQs
                                    </a>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <a href="admin-weeks?editId=<%= w.getWeekId() %>" class="btn-sm-edit">Edit</a>
                                        <% if (w.getQuestionCount() == 0) { %>
                                            <form action="admin-weeks" method="post" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete Week <%= w.getWeekNumber() %>?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="weekId" value="<%= w.getWeekId() %>">
                                                <button type="submit" class="btn-sm-del">Delete</button>
                                            </form>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                    <%  }
                       } else { %>
                        <tr>
                            <td colspan="4" style="text-align:center; color: var(--text-sec); padding:30px;">No weeks defined yet.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

</body>
</html>
