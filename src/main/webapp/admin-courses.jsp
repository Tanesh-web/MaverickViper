<%@page import="java.util.List"%>
<%
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.html");
        return;
    }

    List<String[]> courses =
        (List<String[]>) request.getAttribute("courses");

    String adminUsername =
        (String) session.getAttribute("adminUsername");

    String message = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Courses | Maverick Viper</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }

        body {
            background: #160b10;
            color: #f8edf1;
            padding: 30px;
        }

        .container {
            max-width: 1050px;
            margin: auto;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 35px;
            flex-wrap: wrap;
            gap: 15px;
        }

        h1 {
            color: #f2c5d3;
            margin-bottom: 8px;
        }

        .subtitle {
            color: #bdaab1;
        }

        a {
            color: #f2a9c0;
            text-decoration: none;
        }

        .panel {
            background: #26141d;
            border: 1px solid #573044;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
        }

        h2 {
            color: #f2c5d3;
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin: 15px 0 8px;
            color: #e8d6dd;
        }

        input, textarea {
            width: 100%;
            padding: 13px;
            border: 1px solid #684052;
            border-radius: 7px;
            background: #170d12;
            color: white;
            outline: none;
        }

        textarea {
            min-height: 90px;
            resize: vertical;
        }

        button {
            margin-top: 20px;
            padding: 12px 24px;
            border: none;
            border-radius: 7px;
            background: #8e294e;
            color: white;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background: #ad3763;
        }

        .success {
            color: #79e6a2;
            margin-bottom: 15px;
        }

        .error {
            color: #ff9292;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }

        th, td {
            padding: 14px;
            border-bottom: 1px solid #573044;
            text-align: left;
            vertical-align: top;
        }

        th {
            color: #f2c5d3;
        }

        td {
            color: #e8dce1;
        }

        .empty {
            color: #bdaab1;
            padding: 20px 0;
        }

        @media (max-width: 650px) {
            body {
                padding: 15px;
            }

            .panel {
                padding: 17px;
                overflow-x: auto;
            }

            table {
                min-width: 600px;
            }
        }
    </style>
</head>

<body>
<div class="container">

    <header>
        <div>
            <h1>Manage Courses</h1>
            <p class="subtitle">
                Welcome, <%= adminUsername == null ? "Admin" : adminUsername %>
            </p>
        </div>
        <a href="admin-dashboard">Back to Dashboard</a>
    </header>

    <section class="panel">
        <h2>Add New Course</h2>

        <% if ("added".equals(message)) { %>
            <p class="success">Course added successfully!</p>
        <% } %>

        <% if ("empty".equals(error)) { %>
            <p class="error">Please enter a course name.</p>
        <% } %>

        <form action="admin-courses" method="post">

            <label>Course Name</label>
            <input type="text" name="courseName"
                   placeholder="Example: Foundations of Digital Business"
                   required>

            <label>Course Code (Optional)</label>
            <input type="text" name="courseCode"
                   placeholder="Enter NPTEL course code">

            <label>Course Description (Optional)</label>
            <textarea name="description"
                      placeholder="Enter a short course description"></textarea>

            <button type="submit">Add Course</button>
        </form>
    </section>

    <section class="panel">
        <h2>Available Courses</h2>

        <% if (courses == null || courses.isEmpty()) { %>
            <p class="empty">No courses added yet.</p>
        <% } else { %>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Course Name</th>
                        <th>Course Code</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (String[] course : courses) { %>
                        <tr>
                            <td><%= course[0] %></td>
                            <td><%= course[1] %></td>
                            <td><%= course[2] %></td>
                            <td><%= course[3] %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>

        <% } %>
    </section>

</div>
</body>
</html>