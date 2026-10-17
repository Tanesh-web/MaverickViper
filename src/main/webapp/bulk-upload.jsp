<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.ParsedQuestion" %>
<%@ page import="com.maverickviper.model.Week" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    String adminUsername = (String) session.getAttribute("adminUsername");
    List<Week> weeks = (List<Week>) request.getAttribute("weeks");
    List<ParsedQuestion> previewQuestions = (List<ParsedQuestion>) session.getAttribute("previewQuestions");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    int totalDetected = previewQuestions != null ? previewQuestions.size() : 0;
    int validCount = 0;
    int invalidCount = 0;
    int duplicateCount = 0;

    if (previewQuestions != null) {
        for (ParsedQuestion pq : previewQuestions) {
            if (pq.isValid() && !pq.isDuplicate()) validCount++;
            if (!pq.isValid()) invalidCount++;
            if (pq.isDuplicate()) duplicateCount++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bulk MCQ Upload System | MAVERICK VIPER</title>
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

        /* Step Card */
        .step-card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 30px;
            margin-bottom: 30px;
        }

        .step-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--burgundy);
            padding-bottom: 12px;
        }

        .step-num {
            background: var(--crimson);
            color: white;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 14px;
        }

        .step-title {
            font-size: 18px;
            font-weight: 800;
        }

        /* Method Tabs */
        .method-tabs {
            display: flex;
            gap: 15px;
            margin-bottom: 25px;
        }

        .method-tab {
            flex: 1;
            padding: 14px;
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            font-weight: 700;
            font-size: 14px;
            transition: all 0.2s;
        }

        .method-tab.active {
            background: rgba(168, 50, 80, 0.25);
            border-color: var(--crimson);
            color: var(--text-white);
        }

        label {
            display: block;
            margin: 15px 0 6px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-sec);
            text-transform: uppercase;
        }

        textarea, select, input[type="file"], input[type="text"] {
            width: 100%;
            padding: 12px 14px;
            background: var(--bg-main);
            border: 1px solid var(--burgundy);
            border-radius: 8px;
            color: var(--text-white);
            font-size: 14px;
            outline: none;
        }

        textarea {
            font-family: 'Consolas', 'Courier New', monospace;
            min-height: 200px;
            resize: vertical;
            line-height: 1.5;
        }

        textarea:focus, select:focus, input:focus {
            border-color: var(--crimson);
        }

        .form-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .btn-parse {
            margin-top: 22px;
            padding: 14px 28px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(168, 50, 80, 0.3);
        }

        /* Format Helper */
        .format-helper {
            background: var(--bg-main);
            border-left: 3px solid var(--crimson);
            padding: 15px 18px;
            border-radius: 0 8px 8px 0;
            margin-top: 15px;
            font-size: 13px;
            line-height: 1.6;
            color: var(--text-sec);
        }

        .format-helper code {
            color: #86EFAC;
            font-family: monospace;
        }

        /* Preview Section */
        .metrics-banner {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }

        .m-card {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 10px;
            padding: 16px;
            text-align: center;
        }

        .m-num {
            font-size: 26px;
            font-weight: 800;
            margin-top: 4px;
        }

        /* Preview Item Card */
        .preview-item {
            background: var(--bg-sec);
            border: 1px solid var(--burgundy);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 18px;
        }

        .preview-item.invalid {
            border-color: var(--wrong);
            background: rgba(220, 38, 38, 0.05);
        }

        .preview-item.duplicate {
            border-color: #EAB308;
        }

        .badge-status {
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: 700;
        }

        .badge-valid { background: rgba(22, 163, 74, 0.2); color: #86EFAC; border: 1px solid var(--correct); }
        .badge-invalid { background: rgba(220, 38, 38, 0.2); color: #FCA5A5; border: 1px solid var(--wrong); }
        .badge-dup { background: rgba(234, 179, 8, 0.2); color: #FDE047; border: 1px solid #EAB308; }

        .commit-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--bg-card);
            border: 1px solid var(--crimson);
            padding: 20px 25px;
            border-radius: 12px;
            margin-top: 25px;
        }

        .btn-commit {
            padding: 14px 32px;
            background: #16A34A;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 800;
            cursor: pointer;
            box-shadow: 0 4px 15px rgba(22, 163, 74, 0.3);
        }

        .btn-commit:hover {
            background: #15803D;
        }

        @media(max-width: 900px) {
            .sidebar { display: none; }
            .main-content { margin-left: 0; padding: 20px; }
            .form-grid-2, .method-tabs, .metrics-banner { grid-template-columns: 1fr; }
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
        <li><a href="bulk-question-upload" class="active"><span>📤</span> Bulk MCQ Upload</a></li>
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
        <h1>Bulk MCQ Upload System</h1>
        <p>Import hundreds of NPTEL questions via Text Paste, Word (.docx), Excel (.xlsx) or CSV with preview & validation.</p>
    </div>

    <% if (success != null) { %>
        <div class="alert alert-success"><%= success %></div>
    <% } %>

    <% if (error != null) { %>
        <div class="alert alert-error"><%= error %></div>
    <% } %>

    <!-- STEP 1 & 2: Select Method & Provide Input -->
    <% if (previewQuestions == null) { %>
        <div class="step-card">
            <div class="step-header">
                <span class="step-num">1</span>
                <span class="step-title">Select Import Method & Source Data</span>
            </div>

            <form action="bulk-question-upload" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="parse">
                <input type="hidden" name="importType" id="importType" value="TEXT">

                <div class="method-tabs">
                    <div class="method-tab active" id="tabText" onclick="selectMethod('TEXT')">
                        📝 Paste Questions Directly
                    </div>
                    <div class="method-tab" id="tabDocx" onclick="selectMethod('DOCX')">
                        📄 Word Document (.docx)
                    </div>
                    <div class="method-tab" id="tabXlsx" onclick="selectMethod('XLSX')">
                        📊 Excel Workbook (.xlsx)
                    </div>
                    <div class="method-tab" id="tabCsv" onclick="selectMethod('CSV')">
                        📑 CSV Delimited (.csv)
                    </div>
                </div>

                <div class="form-grid-2">
                    <div>
                        <label for="defaultWeek">Fallback NPTEL Week (if not specified per question)</label>
                        <select name="defaultWeek" id="defaultWeek">
                            <% if (weeks != null) {
                                for (Week w : weeks) { %>
                                    <option value="<%= w.getWeekNumber() %>">Week <%= w.getWeekNumber() %> - <%= w.getWeekName() %></option>
                            <%  }
                               } %>
                        </select>
                    </div>

                    <div>
                        <label for="defaultCategory">Default Question Category</label>
                        <select name="defaultCategory" id="defaultCategory">
                            <option value="WEEKWISE">Week-wise Assignment MCQs</option>
                            <option value="NPTEL_MOCK_TEST">NPTEL Mock Test MCQs</option>
                        </select>
                    </div>
                </div>

                <!-- Text Area Input -->
                <div id="sectionText" style="margin-top: 15px;">
                    <label for="rawText">Paste Questions Text Here</label>
                    <textarea name="rawText" id="rawText" placeholder="Week: 0&#10;&#10;Q1. What is digital business?&#10;A. Traditional business only&#10;B. Online shopping only&#10;C. Digital transformation of business&#10;D. Cloud computing&#10;Correct Answer: C"></textarea>

                    <div class="format-helper">
                        <strong>Supported Formats:</strong> Both standard and compact formats are supported:<br>
                        <code>Week: 0</code> (optional header to switch weeks)<br>
                        <code>Q1. Question text here</code><br>
                        <code>A. Option one</code><br>
                        <code>B. Option two</code><br>
                        <code>C. Option three</code><br>
                        <code>D. Option four</code><br>
                        <code>Correct Answer: C</code> (or Ans: C, Answer: C)<br>
                        <code>Explanation: (Optional explanation text)</code>
                    </div>
                </div>

                <!-- File Upload Input -->
                <div id="sectionFile" style="display:none; margin-top: 15px;">
                    <label for="file">Select File</label>
                    <input type="file" name="file" id="file" accept=".docx,.xlsx,.csv">
                    <p style="color:var(--text-sec); font-size:13px; margin-top:8px;">Supported extensions: <strong>.docx</strong> (Word Document), <strong>.xlsx</strong> (Excel Workbook), <strong>.csv</strong> (Comma / Tab delimited).</p>
                </div>

                <button type="submit" class="btn-parse">Parse & Preview Questions →</button>
            </form>
        </div>
    <% } %>

    <!-- STEP 3-7: PREVIEW TABLE & INLINE EDITING -->
    <% if (previewQuestions != null) { %>
        <div class="step-card">
            <div class="step-header">
                <span class="step-num">2</span>
                <span class="step-title">Parsed Questions Preview & Validation</span>
            </div>

            <!-- Preview Metric Counters -->
            <div class="metrics-banner">
                <div class="m-card">
                    <div style="color:var(--text-sec); font-size:12px;">Total Detected</div>
                    <div class="m-num"><%= totalDetected %></div>
                </div>
                <div class="m-card">
                    <div style="color:#86EFAC; font-size:12px;">Valid Questions</div>
                    <div class="m-num" style="color:var(--correct);"><%= validCount %></div>
                </div>
                <div class="m-card">
                    <div style="color:#FCA5A5; font-size:12px;">Invalid Questions</div>
                    <div class="m-num" style="color:var(--wrong);"><%= invalidCount %></div>
                </div>
                <div class="m-card">
                    <div style="color:#FDE047; font-size:12px;">Potential Duplicates</div>
                    <div class="m-num" style="color:#EAB308;"><%= duplicateCount %></div>
                </div>
            </div>

            <form action="bulk-question-upload" method="post">
                <input type="hidden" name="action" value="commit">

                <% int qIdx = 1;
                   for (ParsedQuestion pq : previewQuestions) { %>
                    <div class="preview-item <%= !pq.isValid() ? "invalid" : "" %> <%= pq.isDuplicate() ? "duplicate" : "" %>">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                            <div style="display:flex; gap:10px; align-items:center;">
                                <strong style="font-size:16px;">Item #<%= qIdx++ %></strong>
                                <% if (pq.isValid()) { %>
                                    <span class="badge-status badge-valid">✓ Valid</span>
                                <% } else { %>
                                    <span class="badge-status badge-invalid">✗ <%= pq.getValidationError() %></span>
                                <% } %>
                                <% if (pq.isDuplicate()) { %>
                                    <span class="badge-status badge-dup">⚠️ Duplicate Prompt</span>
                                <% } %>
                            </div>

                            <div style="display:flex; gap:12px;">
                                <div style="display:flex; align-items:center; gap:6px;">
                                    <span style="font-size:12px; color:var(--text-sec);">Week:</span>
                                    <input type="number" name="weekNum" value="<%= pq.getWeekNumber() %>" style="width:65px; padding:6px 8px; font-size:13px;" required>
                                </div>
                                <div style="display:flex; align-items:center; gap:6px;">
                                    <span style="font-size:12px; color:var(--text-sec);">Category:</span>
                                    <select name="category" style="width:130px; padding:6px 8px; font-size:12px;">
                                        <option value="WEEKWISE" <%= "WEEKWISE".equalsIgnoreCase(pq.getCategory()) ? "selected" : "" %>>Week-wise</option>
                                        <option value="NPTEL_MOCK_TEST" <%= "NPTEL_MOCK_TEST".equalsIgnoreCase(pq.getCategory()) ? "selected" : "" %>>Mock Test</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Editable Question Text -->
                        <div style="margin-bottom:12px;">
                            <label style="font-size:11px; margin-bottom:4px;">Question Prompt</label>
                            <input type="text" name="qText" value="<%= pq.getQuestionText() %>" required style="font-weight:600;">
                        </div>

                        <!-- Editable 4 Options -->
                        <div class="form-grid-2">
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Option A</label>
                                <input type="text" name="optA" value="<%= pq.getOptionA() %>" required>
                            </div>
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Option B</label>
                                <input type="text" name="optB" value="<%= pq.getOptionB() %>" required>
                            </div>
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Option C</label>
                                <input type="text" name="optC" value="<%= pq.getOptionC() %>" required>
                            </div>
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Option D</label>
                                <input type="text" name="optD" value="<%= pq.getOptionD() %>" required>
                            </div>
                        </div>

                        <div class="form-grid-2" style="margin-top:10px;">
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Correct Answer Letter (A, B, C, or D)</label>
                                <input type="text" name="correctOpt" value="<%= pq.getCorrectOption() %>" maxlength="1" required style="width:70px; text-transform:uppercase; font-weight:800; text-align:center;">
                            </div>
                            <div>
                                <label style="font-size:11px; margin-bottom:4px;">Explanation Note (Optional)</label>
                                <input type="text" name="explanation" value="<%= pq.getExplanation() != null ? pq.getExplanation() : "" %>" placeholder="Reference or explanation">
                            </div>
                        </div>
                    </div>
                <% } %>

                <div class="commit-bar">
                    <div>
                        <span style="font-size:15px; font-weight:700;">Ready to save valid questions to database?</span>
                        <div style="color:var(--text-sec); font-size:13px; margin-top:3px;">
                            Only valid questions with 4 options and valid answer key (A, B, C, D) will be committed in a single transaction.
                        </div>
                    </div>

                    <div style="display:flex; gap:12px; align-items:center;">
                        <a href="bulk-question-upload?mode=reset" style="color:var(--text-sec); font-size:13px; text-decoration:none;">Discard & Re-upload</a>
                        <button type="submit" class="btn-commit">Commit <%= validCount %> Questions to Database →</button>
                    </div>
                </div>
            </form>
        </div>
    <% } %>
</main>

<script>
    function selectMethod(method) {
        document.getElementById('importType').value = method;
        ['tabText', 'tabDocx', 'tabXlsx', 'tabCsv'].forEach(t => document.getElementById(t).classList.remove('active'));

        if (method === 'TEXT') {
            document.getElementById('tabText').classList.add('active');
            document.getElementById('sectionText').style.display = 'block';
            document.getElementById('sectionFile').style.display = 'none';
        } else {
            document.getElementById('sectionText').style.display = 'none';
            document.getElementById('sectionFile').style.display = 'block';
            if (method === 'DOCX') document.getElementById('tabDocx').classList.add('active');
            if (method === 'XLSX') document.getElementById('tabXlsx').classList.add('active');
            if (method === 'CSV') document.getElementById('tabCsv').classList.add('active');
        }
    }
</script>

</body>
</html>
