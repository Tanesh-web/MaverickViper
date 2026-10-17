<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Question" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    Question editQ = (Question) request.getAttribute("editQuestion");

    String keyword = (String) request.getAttribute("keyword");
    String selectedWeek = (String) request.getAttribute("selectedWeek");
    String selectedCategory = (String) request.getAttribute("selectedCategory");

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Question Management | MAVERICK VIPER</title>
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

        .btn-add {
            padding: 11px 20px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            border-radius: 8px;
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
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

        /* Filter bar */
        .filter-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }

        .filter-card input, .filter-card select {
            padding: 10px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 6px;
            color: var(--text-white);
            font-size: 13.5px;
            outline: none;
        }

        .filter-card input[type="text"] {
            flex: 1;
            min-width: 200px;
        }

        .filter-card button {
            padding: 10px 18px;
            background: var(--crimson);
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: 700;
            font-size: 13.5px;
            cursor: pointer;
        }

        .filter-card a {
            color: var(--text-sec);
            font-size: 13px;
            text-decoration: none;
        }

        /* Form Card */
        .editor-card {
            background: var(--bg-sec);
            border: 1px solid var(--crimson);
            border-radius: 14px;
            padding: 30px;
            margin-bottom: 30px;
            animation: fadeIn 0.3s ease;
        }

        .editor-card h2 {
            font-size: 20px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        .form-grid-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
        }

        label {
            display: block;
            margin: 14px 0 6px;
            font-size: 12.5px;
            font-weight: 600;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        input[type="text"], input[type="number"], textarea, select {
            width: 100%;
            padding: 11px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 7px;
            color: var(--text-white);
            font-size: 14px;
            outline: none;
        }

        input:focus, textarea:focus, select:focus {
            border-color: var(--crimson);
        }

        textarea {
            resize: vertical;
            min-height: 80px;
        }

        .radio-options {
            display: flex;
            gap: 15px;
            margin-top: 8px;
        }

        .radio-pill {
            display: flex;
            align-items: center;
            gap: 6px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 700;
        }

        .radio-pill input {
            accent-color: var(--crimson);
        }

        .btn-submit-q {
            margin-top: 25px;
            padding: 13px 26px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: white;
            border: none;
            border-radius: 7px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
        }

        /* Question Item Cards */
        .q-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            transition: all 0.2s;
        }

        .q-card:hover {
            border-color: var(--crimson);
        }

        .q-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .q-meta {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .badge-week {
            background: rgba(168, 50, 80, 0.2);
            border: 1px solid var(--crimson);
            color: var(--text-white);
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }

        .badge-cat {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-sec);
            padding: 3px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 600;
        }

        .q-text {
            font-size: 16px;
            font-weight: 700;
            line-height: 1.5;
            margin-bottom: 18px;
        }

        .options-list {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }

        .opt-item {
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13.5px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            display: flex;
            gap: 8px;
        }

        .opt-item.correct {
            background: rgba(22, 163, 74, 0.15);
            border-color: var(--correct);
            color: #86EFAC;
            font-weight: 700;
        }

        .opt-letter {
            font-weight: 800;
            color: var(--crimson);
        }

        .opt-item.correct .opt-letter {
            color: #86EFAC;
        }

        .q-explanation {
            background: var(--bg-main);
            border-left: 3px solid var(--crimson);
            padding: 10px 14px;
            border-radius: 0 6px 6px 0;
            font-size: 13px;
            color: var(--text-sec);
            margin-top: 12px;
        }

        .q-actions {
            display: flex;
            gap: 10px;
        }

        .btn-edit {
            padding: 6px 14px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            color: var(--text-white);
            border-radius: 6px;
            font-size: 12px;
            text-decoration: none;
            font-weight: 600;
        }

        .btn-edit:hover {
            border-color: var(--crimson);
            color: var(--crimson);
        }

        .btn-del {
            padding: 6px 14px;
            background: rgba(220, 38, 38, 0.15);
            border: 1px solid var(--wrong);
            color: #FCA5A5;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
        }

        .btn-del:hover {
            background: var(--wrong);
            color: white;
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
            .options-list {
                grid-template-columns: 1fr;
            }
            .form-grid-2, .form-grid-4 {
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
        <li><a href="admin-questions" class="active"><span>❓</span> Questions Bank</a></li>
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
            <h1>Question Bank Management</h1>
            <p>Manage, search, correct keys and update NPTEL multiple choice questions.</p>
        </div>
        <button class="btn-add" onclick="toggleEditor()">+ Add Question Manually</button>
    </div>

    <% if ("added".equals(success)) { %>
        <div class="alert alert-success">Question added successfully to the repository!</div>
    <% } else if ("updated".equals(success)) { %>
        <div class="alert alert-success">Question and answer key updated successfully! (Past attempt snapshots remain safely preserved)</div>
    <% } else if ("deleted".equals(success)) { %>
        <div class="alert alert-success">Question deleted from repository.</div>
    <% } %>

    <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">Please fill in the question text, all 4 options, and select the correct answer.</div>
    <% } else if (error != null) { %>
        <div class="alert alert-error">An error occurred while saving the question.</div>
    <% } %>

    <!-- Question Editor Panel (For Add or Edit) -->
    <div id="editorPanel" class="editor-card" style="<%= editQ != null ? "display:block;" : "display:none;" %>">
        <h2>
            <span><%= editQ != null ? "Edit Question #" + editQ.getQuestionId() : "Add New Question" %></span>
            <button type="button" onclick="closeEditor()" style="background:none; border:none; color:var(--text-sec); font-size:18px; cursor:pointer;">✕</button>
        </h2>

        <form action="admin-questions" method="post">
            <input type="hidden" name="action" value="<%= editQ != null ? "update" : "create" %>">
            <% if (editQ != null) { %>
                <input type="hidden" name="questionId" value="<%= editQ.getQuestionId() %>">
            <% } %>

            <div class="form-grid-2">
                <div>
                    <label for="weekNumber">NPTEL Week</label>
                    <select name="weekNumber" id="weekNumber" required>
                        <% if (weeks != null) {
                            for (Week w : weeks) { %>
                                <option value="<%= w.getWeekNumber() %>" <%= (editQ != null && editQ.getWeekNumber() == w.getWeekNumber()) ? "selected" : "" %>>
                                    Week <%= w.getWeekNumber() %> - <%= w.getWeekName() %>
                                </option>
                        <%  }
                           } %>
                    </select>
                </div>

                <div>
                    <label for="category">Question Category</label>
                    <select name="category" id="category" required>
                        <option value="WEEKWISE" <%= (editQ != null && "WEEKWISE".equalsIgnoreCase(editQ.getCategory())) ? "selected" : "" %>>Week-wise Assignment MCQ</option>
                        <option value="NPTEL_MOCK_TEST" <%= (editQ != null && "NPTEL_MOCK_TEST".equalsIgnoreCase(editQ.getCategory())) ? "selected" : "" %>>NPTEL Mock Test MCQ</option>
                    </select>
                </div>
            </div>

            <label for="questionText">Question Text</label>
            <textarea name="questionText" id="questionText" required placeholder="Enter the complete question prompt here..."><%= editQ != null ? editQ.getQuestionText() : "" %></textarea>

            <div class="form-grid-2">
                <div>
                    <label for="optionA">Option A</label>
                    <input type="text" name="optionA" id="optionA" required placeholder="Option A text" value="<%= editQ != null ? editQ.getOptionA() : "" %>">
                </div>
                <div>
                    <label for="optionB">Option B</label>
                    <input type="text" name="optionB" id="optionB" required placeholder="Option B text" value="<%= editQ != null ? editQ.getOptionB() : "" %>">
                </div>
                <div>
                    <label for="optionC">Option C</label>
                    <input type="text" name="optionC" id="optionC" required placeholder="Option C text" value="<%= editQ != null ? editQ.getOptionC() : "" %>">
                </div>
                <div>
                    <label for="optionD">Option D</label>
                    <input type="text" name="optionD" id="optionD" required placeholder="Option D text" value="<%= editQ != null ? editQ.getOptionD() : "" %>">
                </div>
            </div>

            <label>Correct Answer Key (Select Option Letter)</label>
            <div class="radio-options">
                <label class="radio-pill">
                    <input type="radio" name="correctOption" value="A" required <%= (editQ != null && "A".equalsIgnoreCase(editQ.getCorrectOption())) ? "checked" : "" %>> Option A
                </label>
                <label class="radio-pill">
                    <input type="radio" name="correctOption" value="B" <%= (editQ != null && "B".equalsIgnoreCase(editQ.getCorrectOption())) ? "checked" : "" %>> Option B
                </label>
                <label class="radio-pill">
                    <input type="radio" name="correctOption" value="C" <%= (editQ != null && "C".equalsIgnoreCase(editQ.getCorrectOption())) ? "checked" : "" %>> Option C
                </label>
                <label class="radio-pill">
                    <input type="radio" name="correctOption" value="D" <%= (editQ != null && "D".equalsIgnoreCase(editQ.getCorrectOption())) ? "checked" : "" %>> Option D
                </label>
            </div>

            <label for="explanation">Explanation / Solution Note (Optional)</label>
            <textarea name="explanation" id="explanation" placeholder="Provide background explanation or reference for the correct answer..."><%= (editQ != null && editQ.getExplanation() != null) ? editQ.getExplanation() : "" %></textarea>

            <button type="submit" class="btn-submit-q"><%= editQ != null ? "Save Updated Question" : "Add Question to Bank" %></button>
        </form>
    </div>

    <!-- Filter & Search Toolbar -->
    <form action="admin-questions" method="get" class="filter-card">
        <input type="text" name="search" placeholder="Search keywords in questions or options..." value="<%= keyword != null ? keyword : "" %>">

        <select name="week">
            <option value="ALL">All Course Weeks</option>
            <% if (weeks != null) {
                for (Week w : weeks) { %>
                    <option value="<%= w.getWeekNumber() %>" <%= (selectedWeek != null && selectedWeek.equals(String.valueOf(w.getWeekNumber()))) ? "selected" : "" %>>
                        Week <%= w.getWeekNumber() %>
                    </option>
            <%  }
               } %>
        </select>

        <select name="category">
            <option value="ALL">All Categories</option>
            <option value="WEEKWISE" <%= "WEEKWISE".equalsIgnoreCase(selectedCategory) ? "selected" : "" %>>Week-wise MCQs</option>
            <option value="NPTEL_MOCK_TEST" <%= "NPTEL_MOCK_TEST".equalsIgnoreCase(selectedCategory) ? "selected" : "" %>>NPTEL Mock Test MCQs</option>
        </select>

        <button type="submit">Filter</button>
        <a href="admin-questions">Reset Filters</a>
    </form>

    <!-- Questions Listing -->
    <div style="margin-bottom: 15px; font-size: 14px; color: var(--text-sec);">
        Showing <strong><%= questions != null ? questions.size() : 0 %></strong> questions in repository
    </div>

    <% if (questions != null && !questions.isEmpty()) {
        int idx = 1;
        for (Question q : questions) { %>
            <div class="q-card">
                <div class="q-header">
                    <div class="q-meta">
                        <span class="badge-week">Week <%= q.getWeekNumber() %></span>
                        <span class="badge-cat"><%= q.getCategory() %></span>
                        <span style="color: var(--text-sec); font-size: 12px;">ID: #<%= q.getQuestionId() %></span>
                    </div>

                    <div class="q-actions">
                        <a href="admin-questions?editId=<%= q.getQuestionId() %>" class="btn-edit">Edit</a>
                        <form action="admin-questions" method="post" style="display:inline;" onsubmit="return confirm('Delete Question #<%= q.getQuestionId() %>?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="questionId" value="<%= q.getQuestionId() %>">
                            <button type="submit" class="btn-del">Delete</button>
                        </form>
                    </div>
                </div>

                <div class="q-text">
                    <%= idx++ %>. <%= q.getQuestionText() %>
                </div>

                <div class="options-list">
                    <div class="opt-item <%= "A".equalsIgnoreCase(q.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">A.</span> <%= q.getOptionA() %>
                    </div>
                    <div class="opt-item <%= "B".equalsIgnoreCase(q.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">B.</span> <%= q.getOptionB() %>
                    </div>
                    <div class="opt-item <%= "C".equalsIgnoreCase(q.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">C.</span> <%= q.getOptionC() %>
                    </div>
                    <div class="opt-item <%= "D".equalsIgnoreCase(q.getCorrectOption()) ? "correct" : "" %>">
                        <span class="opt-letter">D.</span> <%= q.getOptionD() %>
                    </div>
                </div>

                <% if (q.getExplanation() != null && !q.getExplanation().trim().isEmpty()) { %>
                    <div class="q-explanation">
                        <strong>Explanation:</strong> <%= q.getExplanation() %>
                    </div>
                <% } %>
            </div>
    <%  }
       } else { %>
        <div class="q-card" style="text-align: center; padding: 45px 20px;">
            <p style="color: var(--text-sec); font-size: 15px; margin-bottom: 15px;">No questions found matching your filter criteria.</p>
            <p style="color: var(--text-sec); font-size: 13px;">Use the <strong>Bulk MCQ Upload</strong> button to upload questions from Word, Excel, CSV or text paste!</p>
        </div>
    <% } %>
</main>

<script>
    function toggleEditor() {
        const p = document.getElementById('editorPanel');
        p.style.display = p.style.display === 'none' ? 'block' : 'none';
        if (p.style.display === 'block') {
            p.scrollIntoView({ behavior: 'smooth' });
        }
    }

    function closeEditor() {
        document.getElementById('editorPanel').style.display = 'none';
    }
</script>

</body>
</html>
