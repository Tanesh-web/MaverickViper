<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.maverickviper.model.Student" %>
<%@ page import="java.util.Map" %>
<%
    Student student = (Student) request.getAttribute("student");
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile | MAVERICK VIPER</title>
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
            padding: 25px 20px;
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

        .header-title h1 {
            font-size: 28px;
            font-weight: 800;
            margin-bottom: 6px;
        }

        .header-title p {
            color: var(--text-sec);
            font-size: 14px;
            margin-bottom: 30px;
        }

        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 25px;
            font-size: 14px;
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

        .profile-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
        }

        .card {
            background: var(--bg-card);
            border: 1px solid var(--burgundy);
            border-radius: 14px;
            padding: 30px;
        }

        .card h2 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 20px;
            color: var(--text-white);
            border-bottom: 1px solid var(--burgundy);
            padding-bottom: 12px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid rgba(100, 28, 53, 0.4);
            font-size: 14px;
        }

        .detail-label {
            color: var(--text-sec);
            font-weight: 600;
        }

        .detail-value {
            font-weight: 600;
            color: var(--text-white);
        }

        .stat-badge {
            background: rgba(168, 50, 80, 0.2);
            border: 1px solid var(--crimson);
            padding: 3px 10px;
            border-radius: 6px;
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

        button {
            margin-top: 22px;
            padding: 13px 24px;
            background: linear-gradient(135deg, var(--burgundy), var(--crimson));
            color: var(--text-white);
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            width: 100%;
        }

        button:hover {
            opacity: 0.95;
            transform: translateY(-1px);
        }

        @media(max-width: 900px) {
            .sidebar {
                display: none;
            }
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
            .profile-grid {
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
        <li><a href="dashboard"><span>📊</span> Dashboard</a></li>
        <li><a href="read-mcqs"><span>📖</span> Read MCQs</a></li>
        <li><a href="take-test"><span>✍️</span> Give Test</a></li>
        <li><a href="student-performance"><span>📈</span> Performance</a></li>
        <li><a href="student-profile" class="active"><span>👤</span> Profile</a></li>
    </ul>

    <div class="user-block">
        <div class="user-info">
            <div class="name"><%= student != null ? student.getFullName() : "Student" %></div>
            <div class="role">NPTEL Candidate</div>
        </div>
        <a href="logout" class="logout-btn">Logout</a>
    </div>
</aside>

<main class="main-content">
    <div class="header-title">
        <h1>Student Profile</h1>
        <p>Manage your account settings and credentials for NPTEL: Foundation of Digital Business.</p>
    </div>

    <% if ("password_updated".equals(success)) { %>
        <div class="alert alert-success">Password updated successfully!</div>
    <% } %>

    <% if ("empty".equals(error)) { %>
        <div class="alert alert-error">Please fill in all password fields.</div>
    <% } else if ("mismatch".equals(error)) { %>
        <div class="alert alert-error">New password and confirmation password do not match.</div>
    <% } else if ("short_password".equals(error)) { %>
        <div class="alert alert-error">New password must be at least 6 characters long.</div>
    <% } else if ("wrong_current".equals(error)) { %>
        <div class="alert alert-error">Current password entered is incorrect.</div>
    <% } else if (error != null) { %>
        <div class="alert alert-error">An error occurred while updating your profile.</div>
    <% } %>

    <div class="profile-grid">
        <div class="card">
            <h2>Account Details</h2>

            <div class="detail-row">
                <span class="detail-label">Full Name</span>
                <span class="detail-value"><%= student != null ? student.getFullName() : "-" %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Email Address</span>
                <span class="detail-value"><%= student != null ? student.getEmail() : "-" %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Enrolled Course</span>
                <span class="detail-value">Foundation of Digital Business</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Account Created</span>
                <span class="detail-value"><%= (student != null && student.getCreatedAt() != null) ? student.getCreatedAt().toString().substring(0, 16) : "-" %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Last Logged In</span>
                <span class="detail-value"><%= (student != null && student.getLastLogin() != null) ? student.getLastLogin().toString().substring(0, 16) : "First Session" %></span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Tests Attempted</span>
                <span class="detail-value stat-badge"><%= stats != null ? stats.get("totalTests") : 0 %> Completed</span>
            </div>

            <div class="detail-row">
                <span class="detail-label">Overall Accuracy</span>
                <span class="detail-value stat-badge"><%= stats != null ? stats.get("overallAccuracy") : 0.0 %>%</span>
            </div>
        </div>

        <div class="card">
            <h2>Change Password</h2>
            <form action="student-profile" method="post">
                <label for="currentPassword">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" required placeholder="Enter current password">

                <label for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" required placeholder="At least 6 characters">

                <label for="confirmPassword">Confirm New Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-type new password">

                <button type="submit">Update Password</button>
            </form>
        </div>
    </div>
</main>

</body>
</html>
